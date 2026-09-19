import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import '../../core/utils/document_number_generator.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/create_sale_transaction.dart';
import '../../utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
class CartItem {
  final ItemModel item;
  int qty;
  double price;

  CartItem({
    required this.item,
    required this.qty,
    required this.price,
  });

  double get subtotal => qty * price;
}

class PosScreen extends StatefulWidget {
  final UserModel currentUser;

  const PosScreen({super.key, required this.currentUser});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<ItemModel> _allItems = [];
  List<ItemModel> _filteredItems = [];
  List<CustomerModel> _customers = [];
  CustomerModel? _selectedCustomer;

  final List<CartItem> _cart = [];
  // Dipakai supaya panel keranjang di dalam bottom sheet (layar HP) ikut
  // update live saat isi keranjang berubah, walau bottom sheet-nya
  // sudah terlanjur terbuka.
  final ValueNotifier<int> _cartTick = ValueNotifier(0);
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  bool _isLoading = true;
  StreamSubscription? _itemSub;
  StreamSubscription? _customerSub;

  @override
  void initState() {
    super.initState();
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
    _customerSub = isar.customerModels.watchLazy().listen((_) {
      if (mounted) {
        _loadData(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _itemSub?.cancel();
    _customerSub?.cancel();
    _searchController.dispose();
    _cartTick.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && _allItems.isEmpty) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();

    final items = await isar.itemModels.where().findAll();
    final customers = await isar.customerModels.where().findAll();

    if (mounted) {
      setState(() {
        _allItems = items;
        _customers = customers;
        if (_selectedCustomer == null && customers.isNotEmpty) {
          _selectedCustomer = customers.first;
        } else if (_selectedCustomer != null) {
          _selectedCustomer = customers.firstWhere(
            (c) => c.id == _selectedCustomer!.id,
            orElse: () => customers.isNotEmpty ? customers.first : _selectedCustomer!,
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

  void _addToCart(ItemModel item) {
    if (item.currentStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Stok '${item.name}' habis!"),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final index = _cart.indexWhere((c) => c.item.id == item.id);
    if (index >= 0) {
      if (_cart[index].qty + 1 > item.currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Jumlah melebihi sisa stok (${item.currentStock})"),
            backgroundColor: Colors.orange.shade800,
          ),
        );
        return;
      }
      setState(() {
        _cart[index].qty++;
      });
      _cartTick.value++;
    } else {
      setState(() {
        _cart.add(CartItem(
          item: item,
          qty: 1,
          price: item.sellPrice,
        ));
      });
      _cartTick.value++;
    }
  }

  void _updateCartQty(int index, int delta) {
    setState(() {
      final newQty = _cart[index].qty + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else if (newQty > _cart[index].item.currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Maksimum stok tersedia: ${_cart[index].item.currentStock}",
            ),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      } else {
        _cart[index].qty = newQty;
      }
    });
    _cartTick.value++;
  }

  void _editItemPrice(int index) {
    final cartItem = _cart[index];
    final priceController = TextEditingController(
      text: cartItem.price.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Ubah Harga Jual: ${cartItem.item.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Harga Standar: ${Formatters.formatRupiah(cartItem.item.sellPrice)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Harga Jual Baru (Rp)",
                  prefixIcon: Icon(Icons.edit_note),
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
                    cartItem.price = newPrice;
                  });
                  _cartTick.value++;
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Harga tidak valid.")),
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

  void _openAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Colors.indigo),
              SizedBox(width: 8),
              Text("Tambah Pelanggan Baru"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nama Pelanggan *",
                    prefixIcon: Icon(Icons.person),
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
                    labelText: "Alamat",
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
                      content: Text("Nama dan nomor HP wajib diisi!"),
                    ),
                  );
                  return;
                }

                final isar = context.read<Isar>();
                final newCustomer = CustomerModel(
                  name: name,
                  phone: phone,
                  address: address.isEmpty ? '-' : address,
                  totalDebt: 0.0,
                );

                await isar.writeTxn(() async {
                  final id = await isar.customerModels.put(newCustomer);
                  newCustomer.id = id;
                });

                if (mounted && ctx.mounted) {
                  final updatedCustomers = await isar.customerModels.where().findAll();
                  if (!mounted || !ctx.mounted) return;
                  setState(() {
                    _customers = updatedCustomers;
                    _selectedCustomer = newCustomer;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text("Pelanggan '$name' berhasil ditambahkan."),
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

  void _openCheckoutDialog() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keranjang belanja masih kosong.")),
      );
      return;
    }

    final total = _cartTotal;
    final paidController = TextEditingController(text: total.toInt().toString());
    String paymentMethod = 'TUNAI';
    DateTime? dueDate;
    DateTime transactionDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final paid = double.tryParse(paidController.text) ?? 0.0;
            final isHutang = paymentMethod == 'HUTANG';
            final change = paid > total ? paid - total : 0.0;
            final remainingDebt = isHutang ? (total > paid ? total - paid : 0.0) : 0.0;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.payment_rounded, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text("Pembayaran Kasir"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Detail Pelanggan
                    Text(
                      "Pelanggan: ${_selectedCustomer?.name ?? 'Umum'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Tanggal Transaksi (bisa disesuaikan, tidak wajib hari ini)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tanggal: ${Formatters.formatDate(transactionDate)}",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: const Text("Ubah Tanggal"),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: transactionDate,
                              firstDate: DateTime(2020, 1, 1),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                transactionDate = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  transactionDate.hour,
                                  transactionDate.minute,
                                  transactionDate.second,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Total Belanja
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text("Total Tagihan", style: TextStyle(fontSize: 12)),
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

                    // Pilihan Metode Pembayaran
                    const Text("Metode Pembayaran",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Tunai / Cash"),
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
                                  dueDate = DateTime.now().add(const Duration(days: 14));
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input Jumlah Bayar
                    TextField(
                      controller: paidController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Jumlah Bayar (Rp)",
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),

                    // Quick Nominal Buttons
                    if (paymentMethod == 'TUNAI')
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text("Uang Pas"),
                            onPressed: () {
                              setDialogState(() {
                                paidController.text = total.toInt().toString();
                              });
                            },
                          ),
                          ActionChip(
                            label: const Text("50.000"),
                            onPressed: () {
                              setDialogState(() {
                                paidController.text = "50000";
                              });
                            },
                          ),
                          ActionChip(
                            label: const Text("100.000"),
                            onPressed: () {
                              setDialogState(() {
                                paidController.text = "100000";
                              });
                            },
                          ),
                          ActionChip(
                            label: const Text("200.000"),
                            onPressed: () {
                              setDialogState(() {
                                paidController.text = "200000";
                              });
                            },
                          ),
                        ],
                      ),

                    if (isHutang) ...[
                      const SizedBox(height: 10),
                      Text(
                        "Sisa Piutang: ${Formatters.formatRupiah(remainingDebt)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dueDate != null)
                        Text(
                          "Jatuh Tempo: ${Formatters.formatDate(dueDate!)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Text(
                        "Kembalian: ${Formatters.formatRupiah(change)}",
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                  onPressed: () => _processCheckout(
                    dialogCtx: dialogCtx,
                    total: total,
                    paid: paid,
                    paymentStatus: isHutang ? 'HUTANG' : 'LUNAS',
                    dueDate: dueDate,
                    transactionDate: transactionDate,
                  ),
                  child: const Text("SIMPAN TRANSAKSI"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processCheckout({
    required BuildContext dialogCtx,
    required double total,
    required double paid,
    required String paymentStatus,
    DateTime? dueDate,
    required DateTime transactionDate,
  }) async {
    Navigator.pop(dialogCtx); // Tutup dialog

    final isar = context.read<Isar>();
    final createSaleUseCase = context.read<CreateSaleTransaction>();

    // Nomor invoice otomatis: MSD/INV/DDMMYY/XXXX (reset per hari transaksi)
    final fullPrefix = DocumentNumberGenerator.buildPrefix('MSD/INV', transactionDate);
    final existingNumbers = await isar.saleTransactionModels
        .filter()
        .invoiceNumberStartsWith(fullPrefix)
        .findAll();
    final invoiceNumber = DocumentNumberGenerator.next(
      fullPrefix,
      existingNumbers.map((e) => e.invoiceNumber).toList(),
    );

    final transaction = SaleTransactionModel(
      invoiceNumber: invoiceNumber,
      customerId: _selectedCustomer?.id ?? 1,
      date: transactionDate,
      paymentStatus: paymentStatus,
      grandTotal: total,
      paidAmount: paid,
      remainingDebt: paymentStatus == 'HUTANG' ? (total - paid) : 0.0,
      dueDate: dueDate,
      isSynced: false,
    );

    final saleItems = _cart.map((c) {
      return SaleItemModel(
        saleTransactionId: 0,
        itemId: c.item.id,
        qty: c.qty,
        price: c.price,
        subtotal: c.subtotal,
      );
    }).toList();

    final result = await createSaleUseCase.execute(
      transaction: transaction,
      items: saleItems,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal checkout: ${failure.message}"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
      (savedTx) {
        setState(() {
          _cart.clear();
        });
        _cartTick.value++;
        _loadData(); // Refresh list stok barang
        _showSuccessReceiptDialog(savedTx);
      },
    );
  }

  Future<void> _printInvoice(SaleTransactionModel sale) async {
    final isar = context.read<Isar>();
    final customer = await isar.customerModels.get(sale.customerId);
    final items = await isar.saleItemModels.filter().saleTransactionIdEqualTo(sale.id).findAll();
    
    final itemIds = items.map((e) => e.itemId).toList();
    final dbItemsList = await isar.itemModels.getAll(itemIds);
    final itemMap = {for (var item in dbItemsList) if (item != null) item.id: item};

    if (customer == null) return;

    final pdfData = await PdfGenerator.generateInvoice(
      transaction: sale,
      customer: customer,
      items: items,
      itemMap: itemMap,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Faktur_${sale.invoiceNumber}',
    );
  }

  void _showSuccessReceiptDialog(SaleTransactionModel sale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text("Transaksi Berhasil!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nomor Invoice: ${sale.invoiceNumber}"),
              const SizedBox(height: 6),
              Text(
                "Total: ${Formatters.formatRupiah(sale.grandTotal)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text("Status: ${sale.paymentStatus}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _printInvoice(sale),
              child: const Text("Cetak Faktur"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Transaksi Baru"),
            ),
          ],
        );
      },
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
        final katalogPane = _buildKatalogPane(context, categories, theme);
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
            heroTag: 'pos_cart_fab',
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

  Widget _buildKatalogPane(
      BuildContext context, List<String> categories, ThemeData theme) {
    return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input & Filter
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari Nama Barang / Nomor Part...",
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
                            final isOutOfStock = item.currentStock <= 0;

                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: item.currentStock <= item.minStock
                                      ? Colors.orange.shade300
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: InkWell(
                                onTap: isOutOfStock ? null : () => _addToCart(item),
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
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.partNumber,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade800,
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
                                            Formatters.formatRupiah(item.sellPrice),
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
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
                                                    color: isOutOfStock
                                                        ? Colors.red
                                                        : (item.currentStock <= item.minStock
                                                            ? Colors.orange.shade800
                                                            : Colors.grey.shade700),
                                                    fontWeight: isOutOfStock
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.add_shopping_cart,
                                                size: 18,
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
                // Header Keranjang & Pelanggan Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Keranjang Belanja",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_cart.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() => _cart.clear());
                          _cartTick.value++;
                        },
                        child: const Text("Hapus Semua", style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Pilih Pelanggan + Tombol Tambah Cepat
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CustomerModel>(
                        initialValue: _selectedCustomer,
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: "Pelanggan",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: _customers.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              c.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedCustomer = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      tooltip: "Tambah Pelanggan Baru",
                      icon: const Icon(Icons.person_add_alt_1, size: 20),
                      onPressed: _openAddCustomerDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Daftar Item di Cart
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Keranjang masih kosong"),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _cart.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final cartItem = _cart[index];
                            final isCustomPrice = cartItem.price != cartItem.item.sellPrice;

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
                                    onTap: () => _editItemPrice(index),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isCustomPrice
                                            ? Colors.amber.shade100
                                            : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isCustomPrice
                                              ? Colors.amber.shade600
                                              : Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            Formatters.formatRupiah(cartItem.price),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isCustomPrice
                                                  ? Colors.amber.shade900
                                                  : Colors.blue.shade900,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Icon(
                                            Icons.edit,
                                            size: 12,
                                            color: isCustomPrice
                                                ? Colors.amber.shade900
                                                : Colors.blue.shade900,
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

                // Ringkasan Subtotal & Tombol Bayar
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
                          const Text("Total Pembayaran:"),
                          Text(
                            Formatters.formatRupiah(_cartTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _cart.isEmpty ? null : _openCheckoutDialog,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text(
                          "PROSES BAYAR (F9)",
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
