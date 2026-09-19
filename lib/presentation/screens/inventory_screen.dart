import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import '../../core/authorization/role_permission.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/category_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/stock_movement_log_model.dart';
import '../../data/models/user_model.dart';

class InventoryScreen extends StatefulWidget {
  final UserModel currentUser;

  const InventoryScreen({super.key, required this.currentUser});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _filterStock = 'ALL'; // ALL, LOW, OUT
  bool _isLoading = true;
  StreamSubscription? _itemSubscription;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _initWatcher();
    _searchController.addListener(_applyFilter);
  }

  void _initWatcher() {
    final isar = context.read<Isar>();
    _itemSubscription = isar.itemModels.watchLazy().listen((_) {
      if (mounted) {
        _loadItems(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _itemSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool showLoading = true}) async {
    if (showLoading && _items.isEmpty) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();
    final items = await isar.itemModels.where().sortByName().findAll();

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesQuery = item.name.toLowerCase().contains(query) ||
            item.partNumber.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);

        if (!matchesQuery) return false;

        if (_filterStock == 'LOW') {
          return item.currentStock <= item.minStock && item.currentStock > 0;
        } else if (_filterStock == 'OUT') {
          return item.currentStock <= 0;
        }
        return true;
      }).toList();
    });
  }

  Future<void> _openItemForm([ItemModel? existingItem]) async {
    final canModify = RolePermission.canModifyStock(widget.currentUser.userRoleEnum);
    if (!canModify) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akses ditolak: Hanya Admin dan Owner yang dapat mengubah data stok."),
        ),
      );
      return;
    }

    final isar = context.read<Isar>();
    final categories = await isar.categoryModels.where().sortByName().findAll();
    if (categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Belum ada kategori. Tambahkan kategori dulu lewat menu Kelola Kategori.",
            ),
          ),
        );
      }
      return;
    }

    final isEdit = existingItem != null;
    final formKey = GlobalKey<FormState>();
    final partNumberCtrl = TextEditingController(text: existingItem?.partNumber ?? '');
    final nameCtrl = TextEditingController(text: existingItem?.name ?? '');
    final buyPriceCtrl = TextEditingController(text: existingItem?.buyPrice.toInt().toString() ?? '');
    final sellPriceCtrl = TextEditingController(text: existingItem?.sellPrice.toInt().toString() ?? '');
    final minStockCtrl = TextEditingController(text: existingItem?.minStock.toString() ?? '5');
    final stockCtrl = TextEditingController(text: existingItem?.currentStock.toString() ?? '0');

    // Cocokkan kategori barang yang sedang diedit dengan daftar kategori aktif.
    // Kalau tidak ketemu (data lama/legacy), tampilkan sebagai opsi tambahan
    // agar dropdown tidak error dan data lama tidak berubah tanpa disengaja.
    final dropdownOptions = List<CategoryModel>.from(categories);
    CategoryModel? selectedCategory;
    if (isEdit) {
      for (final c in categories) {
        if (c.name.toLowerCase() == existingItem.category.toLowerCase()) {
          selectedCategory = c;
          break;
        }
      }
      if (selectedCategory == null) {
        final legacyCategory = CategoryModel(
          id: -1,
          name: existingItem.category,
          code: '???',
        );
        dropdownOptions.insert(0, legacyCategory);
        selectedCategory = legacyCategory;
      }
    } else {
      selectedCategory = dropdownOptions.first;
    }

    void updateAutoPartNumber(CategoryModel cat) {
      if (!isEdit) {
        final nextSeq = cat.lastSequence + 1;
        partNumberCtrl.text = "${cat.code}-${nextSeq.toString().padLeft(4, '0')}";
      }
    }

    updateAutoPartNumber(selectedCategory);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? "Edit Sparepart" : "Tambah Sparepart Baru"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<CategoryModel>(
                          initialValue: selectedCategory,
                          decoration: const InputDecoration(labelText: "Kategori *"),
                          items: dropdownOptions.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c.id == -1 ? "${c.name} (lama)" : c.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setDialogState(() {
                              selectedCategory = val;
                              updateAutoPartNumber(val);
                            });
                          },
                          validator: (v) => v == null ? "Wajib dipilih" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: partNumberCtrl,
                          enabled: isEdit,
                          decoration: InputDecoration(
                            labelText: "Nomor Part / Kode Barang *",
                            hintText: isEdit ? "Misal: 06455-KVB-T01" : null,
                            helperText: isEdit
                                ? null
                                : "Digenerate otomatis dari kategori yang dipilih",
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nama Sparepart *",
                            hintText: "Misal: Kampas Rem Depan Vario",
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: buyPriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Harga Beli (Rp) *",
                                ),
                                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: sellPriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Harga Jual (Rp) *",
                                ),
                                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: minStockCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Min. Stok *",
                                ),
                                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: stockCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Stok Saat Ini *",
                                ),
                                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final isar = context.read<Isar>();
                      final buyPrice = double.tryParse(buyPriceCtrl.text) ?? 0.0;
                      final sellPrice = double.tryParse(sellPriceCtrl.text) ?? 0.0;
                      final minStock = int.tryParse(minStockCtrl.text) ?? 0;
                      final currentStock = int.tryParse(stockCtrl.text) ?? 0;
                      final category = selectedCategory!;

                      await isar.writeTxn(() async {
                        if (isEdit) {
                          final oldStock = existingItem.currentStock;
                          existingItem.partNumber = partNumberCtrl.text.trim();
                          existingItem.name = nameCtrl.text.trim();
                          existingItem.category = category.name;
                          existingItem.buyPrice = buyPrice;
                          existingItem.sellPrice = sellPrice;
                          existingItem.minStock = minStock;
                          existingItem.currentStock = currentStock;
                          existingItem.isSynced = false;
                          await isar.itemModels.put(existingItem);

                          if (oldStock != currentStock) {
                            // Catat log stock adjustment
                            await isar.stockMovementLogModels.put(
                              StockMovementLogModel(
                                itemId: existingItem.id,
                                changeQty: currentStock - oldStock,
                                movementType: 'ADJUSTMENT',
                                referenceNumber: 'OPNAME-${DateTime.now().millisecondsSinceEpoch}',
                                timestamp: DateTime.now(),
                                isSynced: false,
                              ),
                            );
                          }
                        } else {
                          // Kunci nomor urut & generate kode final di dalam
                          // transaksi yang sama supaya tidak bentrok antar barang.
                          final freshCategory =
                              await isar.categoryModels.get(category.id) ?? category;
                          final nextSeq = freshCategory.lastSequence + 1;
                          final generatedCode =
                              "${freshCategory.code}-${nextSeq.toString().padLeft(4, '0')}";

                          freshCategory.lastSequence = nextSeq;
                          await isar.categoryModels.put(freshCategory);

                          final newItem = ItemModel(
                            partNumber: generatedCode,
                            name: nameCtrl.text.trim(),
                            category: freshCategory.name,
                            buyPrice: buyPrice,
                            sellPrice: sellPrice,
                            minStock: minStock,
                            currentStock: currentStock,
                            isSynced: false,
                          );
                          final id = await isar.itemModels.put(newItem);

                          if (currentStock > 0) {
                            await isar.stockMovementLogModels.put(
                              StockMovementLogModel(
                                itemId: id,
                                changeQty: currentStock,
                                movementType: 'ADJUSTMENT',
                                referenceNumber: 'INITIAL-STOCK',
                                timestamp: DateTime.now(),
                                isSynced: false,
                              ),
                            );
                          }
                        }
                      });

                      if (dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                      if (mounted) {
                        _loadItems();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? "Barang berhasil diperbarui"
                                  : "Barang baru berhasil ditambahkan",
                            ),
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(ItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus sparepart '${item.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final isar = context.read<Isar>();
              await isar.writeTxn(() async {
                await isar.itemModels.delete(item.id);
              });
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                _loadItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Barang telah dihapus")),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canModify = RolePermission.canModifyStock(widget.currentUser.userRoleEnum);

    return Scaffold(
      floatingActionButton: canModify
          ? FloatingActionButton.extended(
              onPressed: () => _openItemForm(),
              icon: const Icon(Icons.add),
              label: const Text("Tambah Sparepart"),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter & Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Cari nama, part number, atau kategori...",
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ALL', label: Text('Semua')),
                    ButtonSegment(value: 'LOW', label: Text('Menipis')),
                    ButtonSegment(value: 'OUT', label: Text('Habis')),
                  ],
                  selected: {_filterStock},
                  onSelectionChanged: (set) {
                    setState(() {
                      _filterStock = set.first;
                      _applyFilter();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item Counter
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Menampilkan ${_filteredItems.length} sparepart",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),

            // Table / List Sparepart
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredItems.isEmpty
                      ? const Center(child: Text("Tidak ada data sparepart."))
                      : ListView.separated(
                          itemCount: _filteredItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isLow = item.currentStock <= item.minStock && item.currentStock > 0;
                            final isOut = item.currentStock <= 0;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isOut
                                    ? Colors.red.shade100
                                    : (isLow ? Colors.amber.shade100 : Colors.indigo.shade50),
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: isOut
                                      ? Colors.red.shade800
                                      : (isLow ? Colors.amber.shade900 : Colors.indigo.shade700),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (isOut)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "STOK HABIS",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    )
                                  else if (isLow)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "STOK MENIPIS",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Part: ${item.partNumber} • Kategori: ${item.category}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Beli: ${Formatters.formatRupiah(item.buyPrice)} • Jual: ${Formatters.formatRupiah(item.sellPrice)} • Min: ${item.minStock}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isOut
                                          ? Colors.red.shade50
                                          : (isLow ? Colors.amber.shade50 : Colors.grey.shade100),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Stok: ${item.currentStock}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isOut
                                            ? Colors.red.shade900
                                            : (isLow ? Colors.amber.shade900 : Colors.black87),
                                      ),
                                    ),
                                  ),
                                  if (canModify) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _openItemForm(item),
                                      tooltip: "Edit",
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _confirmDelete(item),
                                      tooltip: "Hapus",
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
