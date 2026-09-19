import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import '../../core/utils/document_number_generator.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/item_model.dart';
import '../../data/models/purchase_item_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/create_purchase_transaction.dart';
import '../../utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
class PurchaseCartItem {
  final ItemModel item;
  int qty;
  double buyPrice;

  PurchaseCartItem({
    required this.item,
    required this.qty,
    required this.buyPrice,
  });

  double get subtotal => qty * buyPrice;
}

class PurchaseScreen extends StatefulWidget {
  final UserModel currentUser;

  const PurchaseScreen({super.key, required this.currentUser});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<ItemModel> _allItems = [];
  List<ItemModel> _filteredItems = [];
  List<SupplierModel> _suppliers = [];
  SupplierModel? _selectedSupplier;

  final List<PurchaseCartItem> _cart = [];
  // Dipakai supaya panel keranjang di dalam bottom sheet (layar HP) ikut
  // update live saat isi keranjang berubah, walau bottom sheet-nya
  // sudah terlanjur terbuka.
  final ValueNotifier<int> _cartTick = ValueNotifier(0);
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _poNumberController = TextEditingController();
  String _selectedCategory = 'Semua';
  bool _isLoading = true;
  StreamSubscription? _itemSub;
  StreamSubscription? _supplierSub;

  // Tanggal transaksi pembelian: bisa disesuaikan sendiri, tidak wajib
  // mengikuti tanggal saat disimpan.
  DateTime _transactionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshPoNumberPreview();
    _loadData();
    _initWatchers();
    _searchController.addListener(_filterItems);
  }

  void _initWatchers() {
    final isar = context.read<Isar>();
    _itemSub = isar.itemModels.watchLazy().listen((_) {
      if (mounted) {
        _loadData(showLoading: false);
      }
    });
    _supplierSub = isar.supplierModels.watchLazy().listen((_) {
      if (mounted) {
        _loadData(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _itemSub?.cancel();
    _supplierSub?.cancel();
    _searchController.dispose();
    _poNumberController.dispose();
    _cartTick.dispose();
    super.dispose();
  }

  /// Tampilkan preview nomor PO berikutnya (format MSD/PO/DDMMYY/XXXX)
  /// sesuai tanggal transaksi yang dipilih. Nomor final tetap dihitung ulang
  /// saat benar-benar disimpan, supaya tidak bentrok kalau ada input lain.
  Future<void> _refreshPoNumberPreview() async {
    final isar = context.read<Isar>();
    final fullPrefix = DocumentNumberGenerator.buildPrefix('MSD/PO', _transactionDate);
    final existingNumbers = await isar.purchaseTransactionModels
        .filter()
        .poNumberStartsWith(fullPrefix)
        .findAll();
    final preview = DocumentNumberGenerator.next(
      fullPrefix,
      existingNumbers.map((e) => e.poNumber).toList(),
    );
    if (mounted) {
      setState(() => _poNumberController.text = preview);
      _cartTick.value++;
    }
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && _allItems.isEmpty) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();

    final items = await isar.itemModels.where().findAll();
    final suppliers = await isar.supplierModels.where().findAll();

    if (mounted) {
      setState(() {
        _allItems = items;
        _suppliers = suppliers;
        if (_selectedSupplier == null && suppliers.isNotEmpty) {
          _selectedSupplier = suppliers.first;
        } else if (_selectedSupplier != null) {
          _selectedSupplier = suppliers.firstWhere(
            (s) => s.id == _selectedSupplier!.id,
            orElse: () => suppliers.isNotEmpty ? suppliers.first : _selectedSupplier!,
          );
        }
        _isLoading = false;
      });
      _filterItems();
    }
  }

  void _filterItems() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchQuery = item.name.toLowerCase().contains(query) ||
            item.partNumber.toLowerCase().contains(query);
        final matchCategory = _selectedCategory == 'Semua' ||
            item.category.toLowerCase() == _selectedCategory.toLowerCase();
        return matchQuery && matchCategory;
      }).toList();
    });
  }

  void _addToPurchaseCart(ItemModel item) {
    final index = _cart.indexWhere((c) => c.item.id == item.id);
    if (index >= 0) {
      setState(() {
        _cart[index].qty++;
      });
    } else {
      setState(() {
        _cart.add(PurchaseCartItem(
          item: item,
          qty: 1,
          buyPrice: item.buyPrice,
        ));
      });
    }
    _cartTick.value++;
  }

  void _updateCartQty(int index, int delta) {
    setState(() {
      final newQty = _cart[index].qty + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].qty = newQty;
      }
    });
    _cartTick.value++;
  }

  void _editBuyPrice(int index) {
    final cartItem = _cart[index];
    final priceController = TextEditingController(
      text: cartItem.buyPrice.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Ubah Harga Beli: ${cartItem.item.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Harga Beli Master: ${Formatters.formatRupiah(cartItem.item.buyPrice)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Harga Beli Faktur Baru (Rp)",
                  prefixIcon: Icon(Icons.receipt_long),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceController.text.trim());
                if (newPrice != null && newPrice >= 0) {
                  setState(() {
                    cartItem.buyPrice = newPrice;
                  });
                  _cartTick.value++;
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Harga beli tidak valid.")),
                  );
                }
              },
              child: const Text("Terapkan"),
            ),
          ],
        );
      },
    );
  }

  void _openAddSupplierDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.business, color: Colors.indigo),
              SizedBox(width: 8),
              Text("Tambah Supplier Baru"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nama Distributor / Supplier *",
                    prefixIcon: Icon(Icons.business_center),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "No. HP / Telepon *",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: "Alamat / Kantor",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final address = addressCtrl.text.trim();
                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nama dan no HP supplier wajib diisi!"),
                    ),
                  );
                  return;
                }

                final isar = context.read<Isar>();
                final newSupplier = SupplierModel(
                  name: name,
                  phone: phone,
                  address: address.isEmpty ? '-' : address,
                  totalPayable: 0.0,
                );

                await isar.writeTxn(() async {
                  final id = await isar.supplierModels.put(newSupplier);
                  newSupplier.id = id;
                });

                if (mounted && ctx.mounted) {
                  final updatedSuppliers = await isar.supplierModels.where().findAll();
                  if (!mounted || !ctx.mounted) return;
                  setState(() {
                    _suppliers = updatedSuppliers;
                    _selectedSupplier = newSupplier;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text("Supplier '$name' berhasil ditambahkan."),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  double get _cartTotal => _cart.fold(0.0, (sum, c) => sum + c.subtotal);

  void _openCheckoutPurchaseDialog() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Daftar belanja pembelian masih kosong.")),
      );
      return;
    }
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih supplier terlebih dahulu.")),
      );
      return;
    }

    final total = _cartTotal;
    final paidController = TextEditingController(text: total.toInt().toString());
    String paymentMethod = 'TUNAI';
    DateTime? dueDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final paid = double.tryParse(paidController.text) ?? 0.0;
            final isHutang = paymentMethod == 'HUTANG';
            final remainingPayable = isHutang ? (total > paid ? total - paid : 0.0) : 0.0;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.inventory_rounded, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text("Konfirmasi Faktur Pembelian"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Supplier: ${_selectedSupplier?.name}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "No. PO / Faktur: ${_poNumberController.text}",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),

                    // Total Tagihan Pembelian
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text("Grand Total Pembelian", style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatRupiah(total),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metode Pembayaran ke Supplier
                    const Text(
                      "Status Pembayaran ke Supplier",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Lunas (Tunai/TF)"),
                            selected: paymentMethod == 'TUNAI',
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  paymentMethod = 'TUNAI';
                                  paidController.text = total.toInt().toString();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Tempo / Hutang"),
                            selected: paymentMethod == 'HUTANG',
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  paymentMethod = 'HUTANG';
                                  paidController.text = '0';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input Jumlah Bayar / DP
                    TextField(
                      controller: paidController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isHutang ? "Uang Muka / DP (Rp)" : "Jumlah Dibayar (Rp)",
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),

                    if (isHutang) ...[
                      Text(
                        "Sisa Hutang Toko: ${Formatters.formatRupiah(remainingPayable)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Jatuh Tempo: ${Formatters.formatDate(dueDate!)}",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month, size: 18),
                            label: const Text("Ubah Tanggal"),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dueDate!,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => dueDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () => _processPurchaseCheckout(
                    dialogCtx: dialogCtx,
                    total: total,
                    paid: paid,
                    paymentStatus: isHutang ? 'HUTANG' : 'LUNAS',
                    dueDate: isHutang ? dueDate : null,
                  ),
                  child: const Text("SIMPAN PEMBELIAN & RESTOCK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processPurchaseCheckout({
    required BuildContext dialogCtx,
    required double total,
    required double paid,
    required String paymentStatus,
    DateTime? dueDate,
  }) async {
    Navigator.pop(dialogCtx);

    final isar = context.read<Isar>();
    final createPurchaseUseCase = context.read<CreatePurchaseTransaction>();

    // Hitung ulang nomor PO final tepat saat disimpan (bukan cuma dari
    // preview) supaya tidak bentrok kalau ada transaksi lain masuk duluan.
    final fullPrefix = DocumentNumberGenerator.buildPrefix('MSD/PO', _transactionDate);
    final existingNumbers = await isar.purchaseTransactionModels
        .filter()
        .poNumberStartsWith(fullPrefix)
        .findAll();
    final poNumber = DocumentNumberGenerator.next(
      fullPrefix,
      existingNumbers.map((e) => e.poNumber).toList(),
    );

    final transaction = PurchaseTransactionModel(
      poNumber: poNumber,
      supplierId: _selectedSupplier!.id,
      date: _transactionDate,
      paymentStatus: paymentStatus,
      grandTotal: total,
      paidAmount: paid,
      remainingPayable: paymentStatus == 'HUTANG' ? (total - paid) : 0.0,
      dueDate: dueDate,
      isSynced: false,
    );

    final purchaseItems = _cart.map((c) {
      return PurchaseItemModel(
        purchaseTransactionId: 0,
        itemId: c.item.id,
        qty: c.qty,
        price: c.buyPrice,
        subtotal: c.subtotal,
      );
    }).toList();

    final result = await createPurchaseUseCase.execute(
      transaction: transaction,
      items: purchaseItems,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan pembelian: ${failure.message}"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
      (savedPo) {
        setState(() {
          _cart.clear();
          _transactionDate = DateTime.now();
        });
        _cartTick.value++;
        _refreshPoNumberPreview();
        _loadData(); // Refresh stok barang terbaru

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text("Pembelian & Restock Berhasil!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("No. Faktur PO: ${savedPo.poNumber}"),
                const SizedBox(height: 6),
                Text(
                  "Total Pembelian: ${Formatters.formatRupiah(savedPo.grandTotal)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text("Status: ${savedPo.paymentStatus}"),
                const SizedBox(height: 6),
                const Text(
                  "Stok barang di katalog telah otomatis bertambah.",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => _printPO(savedPo),
                child: const Text("Cetak PO"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Selesai"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _printPO(PurchaseTransactionModel po) async {
    final isar = context.read<Isar>();
    final supplier = await isar.supplierModels.get(po.supplierId);
    final items = await isar.purchaseItemModels.filter().purchaseTransactionIdEqualTo(po.id).findAll();
    
    final itemIds = items.map((e) => e.itemId).toList();
    final dbItemsList = await isar.itemModels.getAll(itemIds);
    final itemMap = {for (var item in dbItemsList) if (item != null) item.id: item};

    if (supplier == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier tidak ditemukan')));
      return;
    }

    final pdfData = await PdfGenerator.generatePurchaseOrder(
      purchase: po,
      supplier: supplier,
      items: items,
      itemMap: itemMap,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'PO_${po.poNumber}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = [
      'Semua',
      ..._allItems.map((e) => e.category).toSet(),
    ];

    // Layout responsif: dua kolom sejajar di layar lebar (tablet/desktop),
    // ditumpuk vertikal di layar sempit (HP) supaya tidak overflow.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final katalogPane = _buildCatalogPane(context, categories);
        final cartPane = _buildCartPane(context, theme);

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 3, child: katalogPane),
              const VerticalDivider(width: 1),
              Expanded(flex: 2, child: cartPane),
            ],
          );
        }

        // Di layar sempit (HP): katalog full-screen, keranjang disembunyikan
        // di balik tombol mengambang pojok kiri bawah — tidak makan tempat
        // sampai benar-benar dibuka.
        return Stack(
          fit: StackFit.expand,
          children: [
            katalogPane,
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildCartFab(context, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartFab(BuildContext context, ThemeData theme) {
    return ValueListenableBuilder<int>(
      valueListenable: _cartTick,
      builder: (context, _, __) {
        final itemCount = _cart.length;
        return Badge(
          isLabelVisible: itemCount > 0,
          label: Text('$itemCount'),
          backgroundColor: Colors.red.shade600,
          child: FloatingActionButton.extended(
            heroTag: 'purchase_cart_fab',
            onPressed: () => _openCartSheet(context, theme),
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              itemCount > 0 ? Formatters.formatRupiah(_cartTotal) : "Keranjang",
            ),
          ),
        );
      },
    );
  }

  void _openCartSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetCtx).size.height * 0.85,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _cartTick,
                    builder: (context, _, __) => _buildCartPane(context, theme),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCatalogPane(BuildContext context, List<String> categories) {
    return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input & Filter
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari Suku Cadang yang Ingin Dibeli...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),

                // Kategori Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              _selectedCategory = cat;
                              _filterItems();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Grid Daftar Sparepart
                Expanded(
                  child: _filteredItems.isEmpty
                      ? const Center(child: Text("Barang tidak ditemukan."))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];

                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                onTap: () => _addToPurchaseCart(item),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.indigo.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.partNumber,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo.shade900,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Beli: ${Formatters.formatRupiah(item.buyPrice)}",
                                            style: const TextStyle(
                                              color: Colors.indigo,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Stok: ${item.currentStock}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.add_box,
                                                color: Colors.indigo,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
  }

  Widget _buildCartPane(BuildContext context, ThemeData theme) {
    return Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Clear
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Faktur Pembelian Masuk",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_cart.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() => _cart.clear());
                          _cartTick.value++;
                        },
                        child: const Text("Kosongkan", style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Pilih Supplier + Tombol Tambah Cepat
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<SupplierModel>(
                        initialValue: _selectedSupplier,
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: "Supplier / Distributor",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: _suppliers.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedSupplier = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      tooltip: "Tambah Supplier Baru",
                      icon: const Icon(Icons.domain_add, size: 20),
                      onPressed: _openAddSupplierDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // No. PO / Faktur (otomatis, tidak bisa diketik manual)
                TextField(
                  controller: _poNumberController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Nomor Faktur / PO",
                    prefixIcon: Icon(Icons.receipt),
                    helperText: "Otomatis, mengikuti tanggal transaksi di bawah",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),

                // Tanggal Transaksi (bisa disesuaikan, tidak wajib hari ini)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tanggal Transaksi: ${Formatters.formatDate(_transactionDate)}",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text("Ubah Tanggal"),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _transactionDate,
                          firstDate: DateTime(2020, 1, 1),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _transactionDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              _transactionDate.hour,
                              _transactionDate.minute,
                              _transactionDate.second,
                            );
                          });
                          _refreshPoNumberPreview();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Daftar Item di Cart Pembelian
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Belum ada barang yang ditambahkan"),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _cart.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final cartItem = _cart[index];
                            final isCustomPrice = cartItem.buyPrice != cartItem.item.buyPrice;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cartItem.item.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    Formatters.formatRupiah(cartItem.subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  InkWell(
                                    onTap: () => _editBuyPrice(index),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isCustomPrice
                                            ? Colors.amber.shade100
                                            : Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isCustomPrice
                                              ? Colors.amber.shade600
                                              : Colors.indigo.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            Formatters.formatRupiah(cartItem.buyPrice),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isCustomPrice
                                                  ? Colors.amber.shade900
                                                  : Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Icon(
                                            Icons.edit,
                                            size: 12,
                                            color: isCustomPrice
                                                ? Colors.amber.shade900
                                                : Colors.indigo.shade900,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "x ${cartItem.qty}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    onPressed: () => _updateCartQty(index, -1),
                                  ),
                                  Text(
                                    '${cartItem.qty}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    onPressed: () => _updateCartQty(index, 1),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Ringkasan Subtotal Pembelian
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Pembelian:"),
                          Text(
                            Formatters.formatRupiah(_cartTotal),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _cart.isEmpty ? null : _openCheckoutPurchaseDialog,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.teal.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          "PROSES FAKTUR PEMBELIAN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
