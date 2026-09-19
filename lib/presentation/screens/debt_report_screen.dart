import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/authorization/role_permission.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../../data/models/stock_movement_log_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/purchases_repository.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../data/models/item_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/purchase_item_model.dart';
import '../../utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class DebtReportScreen extends StatefulWidget {
  final UserModel currentUser;

  const DebtReportScreen({super.key, required this.currentUser});

  @override
  State<DebtReportScreen> createState() => _DebtReportScreenState();
}

class _DebtReportScreenState extends State<DebtReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SaleTransactionModel> _saleDebts = [];
  List<PurchaseTransactionModel> _purchaseDebts = [];
  List<SaleTransactionModel> _allSales = [];
  List<PurchaseTransactionModel> _allPurchases = [];
  Map<int, String> _customerNames = {};
  Map<int, String> _supplierNames = {};

  bool _isLoading = true;
  bool _onlyUnpaidSales = true;
  bool _onlyUnpaidPurchases = true;
  bool _historyShowSales = true;

  StreamSubscription? _salesSub;
  StreamSubscription? _purchasesSub;
  StreamSubscription? _customersSub;
  StreamSubscription? _suppliersSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _initWatchers();
  }

  void _initWatchers() {
    final isar = context.read<Isar>();
    _salesSub = isar.saleTransactionModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
    _purchasesSub = isar.purchaseTransactionModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
    _customersSub = isar.customerModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
    _suppliersSub = isar.supplierModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _salesSub?.cancel();
    _purchasesSub?.cancel();
    _customersSub?.cancel();
    _suppliersSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && _saleDebts.isEmpty && _purchaseDebts.isEmpty) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();

    // 1. Fetch Customers & Suppliers lookup map
    final customers = await isar.customerModels.where().findAll();
    final suppliers = await isar.supplierModels.where().findAll();

    final cMap = <int, String>{};
    for (var c in customers) {
      cMap[c.id] = c.name;
    }

    final sMap = <int, String>{};
    for (var s in suppliers) {
      sMap[s.id] = s.name;
    }

    // 2. Fetch Sales with Debt / Tempo
    final sales = await isar.saleTransactionModels
        .filter()
        .paymentStatusEqualTo('HUTANG')
        .or()
        .remainingDebtGreaterThan(0)
        .sortByDateDesc()
        .findAll();

    // 3. Fetch Purchases with Debt / Tempo
    final purchases = await isar.purchaseTransactionModels
        .filter()
        .paymentStatusEqualTo('HUTANG')
        .or()
        .remainingPayableGreaterThan(0)
        .sortByDateDesc()
        .findAll();

    // 4. Fetch SELURUH transaksi (semua status, tanpa difilter) untuk tab Riwayat
    final allSales = await isar.saleTransactionModels.where().sortByDateDesc().findAll();
    final allPurchases =
        await isar.purchaseTransactionModels.where().sortByDateDesc().findAll();

    if (mounted) {
      setState(() {
        _customerNames = cMap;
        _supplierNames = sMap;
        _saleDebts = sales;
        _purchaseDebts = purchases;
        _allSales = allSales;
        _allPurchases = allPurchases;
        _isLoading = false;
      });
    }
  }

  void _openPayCustomerDebtDialog(SaleTransactionModel sale) {
    final amountCtrl = TextEditingController(
      text: sale.remainingDebt.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.payments, color: Colors.green),
              SizedBox(width: 8),
              Text("Pembayaran Piutang Pelanggan"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No. Faktur: ${sale.invoiceNumber}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Pelanggan: ${_customerNames[sale.customerId] ?? 'ID: ${sale.customerId}'}"),
                const SizedBox(height: 8),
                Text("Total Tagihan: ${Formatters.formatRupiah(sale.grandTotal)}"),
                Text("Sudah Dibayar: ${Formatters.formatRupiah(sale.paidAmount)}"),
                const SizedBox(height: 4),
                Text(
                  "Sisa Piutang: ${Formatters.formatRupiah(sale.remainingDebt)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Nominal Pembayaran Diterima (Rp)",
                    prefixIcon: Icon(Icons.attach_money),
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
                final amount = double.tryParse(amountCtrl.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nominal pembayaran harus lebih dari 0.")),
                  );
                  return;
                }

                final salesRepo = context.read<ISalesRepository>();
                final result = await salesRepo.payCustomerDebt(
                  saleTransactionId: sale.id,
                  paymentAmount: amount,
                );

                if (mounted && ctx.mounted) {
                  Navigator.pop(ctx);
                  result.fold(
                    (failure) => ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
                    ),
                    (_) {
                      _loadData();
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text("Pembayaran piutang berhasil dicatat!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  );
                }
              },
              child: const Text("Catat Pembayaran"),
            ),
          ],
        );
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
    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Faktur_${sale.invoiceNumber}',
    );
  }

  Future<void> _printPO(PurchaseTransactionModel po) async {
    final isar = context.read<Isar>();
    final supplier = await isar.supplierModels.get(po.supplierId);
    final items = await isar.purchaseItemModels.filter().purchaseTransactionIdEqualTo(po.id).findAll();
    final itemIds = items.map((e) => e.itemId).toList();
    final dbItemsList = await isar.itemModels.getAll(itemIds);
    final itemMap = {for (var item in dbItemsList) if (item != null) item.id: item};
    if (supplier == null) return;
    final pdfData = await PdfGenerator.generatePurchaseOrder(
      purchase: po,
      supplier: supplier,
      items: items,
      itemMap: itemMap,
    );
    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'PO_${po.poNumber}',
    );
  }

  void _openPaySupplierDebtDialog(PurchaseTransactionModel po) {
    final amountCtrl = TextEditingController(
      text: po.remainingPayable.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.indigo),
              SizedBox(width: 8),
              Text("Pembayaran Hutang ke Supplier"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No. PO / Faktur: ${po.poNumber}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Supplier: ${_supplierNames[po.supplierId] ?? 'ID: ${po.supplierId}'}"),
                const SizedBox(height: 8),
                Text("Total Faktur: ${Formatters.formatRupiah(po.grandTotal)}"),
                Text("Sudah Dibayar: ${Formatters.formatRupiah(po.paidAmount)}"),
                const SizedBox(height: 4),
                Text(
                  "Sisa Hutang Toko: ${Formatters.formatRupiah(po.remainingPayable)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Nominal Pembayaran Dikeluarkan (Rp)",
                    prefixIcon: Icon(Icons.attach_money),
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
                final amount = double.tryParse(amountCtrl.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nominal pembayaran harus lebih dari 0.")),
                  );
                  return;
                }

                final purchasesRepo = context.read<IPurchasesRepository>();
                final result = await purchasesRepo.paySupplierDebt(
                  purchaseTransactionId: po.id,
                  paymentAmount: amount,
                );

                if (mounted && ctx.mounted) {
                  Navigator.pop(ctx);
                  result.fold(
                    (failure) => ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
                    ),
                    (_) {
                      _loadData();
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text("Pembayaran hutang supplier berhasil dicatat!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  );
                }
              },
              child: const Text("Catat Pembayaran"),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // RIWAYAT TRANSAKSI: Detail Item & Koreksi Status Pembayaran
  // ---------------------------------------------------------------------------

  Future<void> _showSaleItemsDialog(SaleTransactionModel sale) async {
    final isar = context.read<Isar>();
    final saleItems = await isar.saleItemModels
        .filter()
        .saleTransactionIdEqualTo(sale.id)
        .findAll();
    final itemIds = saleItems.map((e) => e.itemId).toList();
    final itemsList = await isar.itemModels.getAll(itemIds);
    final itemMap = {for (var it in itemsList) if (it != null) it.id: it};

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Detail Item - ${sale.invoiceNumber}"),
        content: SizedBox(
          width: double.maxFinite,
          child: saleItems.isEmpty
              ? const Text("Tidak ada detail item.")
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: saleItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final si = saleItems[index];
                    final itemModel = itemMap[si.itemId];
                    return ListTile(
                      dense: true,
                      title: Text(itemModel?.name ?? "Barang #${si.itemId}"),
                      subtitle: Text(
                        "${si.qty} x ${Formatters.formatRupiah(si.price)}",
                      ),
                      trailing: Text(
                        Formatters.formatRupiah(si.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Future<void> _showPurchaseItemsDialog(PurchaseTransactionModel po) async {
    final isar = context.read<Isar>();
    final purchaseItems = await isar.purchaseItemModels
        .filter()
        .purchaseTransactionIdEqualTo(po.id)
        .findAll();
    final itemIds = purchaseItems.map((e) => e.itemId).toList();
    final itemsList = await isar.itemModels.getAll(itemIds);
    final itemMap = {for (var it in itemsList) if (it != null) it.id: it};

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Detail Item - ${po.poNumber}"),
        content: SizedBox(
          width: double.maxFinite,
          child: purchaseItems.isEmpty
              ? const Text("Tidak ada detail item.")
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: purchaseItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final pi = purchaseItems[index];
                    final itemModel = itemMap[pi.itemId];
                    return ListTile(
                      dense: true,
                      title: Text(itemModel?.name ?? "Barang #${pi.itemId}"),
                      subtitle: Text(
                        "${pi.qty} x ${Formatters.formatRupiah(pi.price)}",
                      ),
                      trailing: Text(
                        Formatters.formatRupiah(pi.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  /// Koreksi status pembayaran penjualan (LUNAS <-> BELUM LUNAS) untuk
  /// menjaga dari kesalahan klik staff. Hanya Admin/Owner (dicek di pemanggil).
  void _openChangeSaleStatusDialog(SaleTransactionModel sale) {
    String status = sale.paymentStatus == 'LUNAS' ? 'LUNAS' : 'HUTANG';
    final paidCtrl = TextEditingController(
      text: status == 'LUNAS'
          ? sale.grandTotal.toInt().toString()
          : sale.paidAmount.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final paid = double.tryParse(paidCtrl.text) ?? 0;
            final remaining = (sale.grandTotal - paid).clamp(0, sale.grandTotal);

            return AlertDialog(
              title: const Text("Ubah Status Pembayaran"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No. Faktur: ${sale.invoiceNumber}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'LUNAS',
                          label: Text('Lunas'),
                          icon: Icon(Icons.check_circle_outline),
                        ),
                        ButtonSegment(
                          value: 'HUTANG',
                          label: Text('Belum Lunas'),
                          icon: Icon(Icons.pending_outlined),
                        ),
                      ],
                      selected: {status},
                      onSelectionChanged: (set) {
                        setDialogState(() {
                          status = set.first;
                          paidCtrl.text = status == 'LUNAS'
                              ? sale.grandTotal.toInt().toString()
                              : '0';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: paidCtrl,
                      enabled: status != 'LUNAS',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Jumlah Dibayar (Rp)",
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sisa Piutang: ${Formatters.formatRupiah(remaining.toDouble())}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: remaining > 0 ? Colors.red : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final isar = context.read<Isar>();
                    final paidAmount = double.tryParse(paidCtrl.text) ?? 0;
                    final newRemaining =
                        (sale.grandTotal - paidAmount).clamp(0, sale.grandTotal).toDouble();
                    final oldRemaining = sale.remainingDebt;

                    await isar.writeTxn(() async {
                      sale.paymentStatus = status;
                      sale.paidAmount = status == 'LUNAS' ? sale.grandTotal : paidAmount;
                      sale.remainingDebt = status == 'LUNAS' ? 0 : newRemaining;
                      sale.isSynced = false;
                      await isar.saleTransactionModels.put(sale);

                      // Sinkronkan agregat piutang pelanggan (dipakai Dashboard)
                      // supaya tidak selisih dengan angka di transaksi.
                      final delta = sale.remainingDebt - oldRemaining;
                      if (delta != 0) {
                        final customer = await isar.customerModels.get(sale.customerId);
                        if (customer != null) {
                          customer.totalDebt += delta;
                          if (customer.totalDebt < 0.001) customer.totalDebt = 0.0;
                          await isar.customerModels.put(customer);
                        }
                      }
                    });

                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    if (mounted) {
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Status pembayaran berhasil diperbarui."),
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
      },
    );
  }

  /// Koreksi status pembayaran pembelian (LUNAS <-> BELUM LUNAS) untuk
  /// menjaga dari kesalahan klik staff. Hanya Admin/Owner (dicek di pemanggil).
  void _openChangePurchaseStatusDialog(PurchaseTransactionModel po) {
    String status = po.paymentStatus == 'LUNAS' ? 'LUNAS' : 'HUTANG';
    final paidCtrl = TextEditingController(
      text: status == 'LUNAS'
          ? po.grandTotal.toInt().toString()
          : po.paidAmount.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final paid = double.tryParse(paidCtrl.text) ?? 0;
            final remaining = (po.grandTotal - paid).clamp(0, po.grandTotal);

            return AlertDialog(
              title: const Text("Ubah Status Pembayaran"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No. PO / Faktur: ${po.poNumber}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'LUNAS',
                          label: Text('Lunas'),
                          icon: Icon(Icons.check_circle_outline),
                        ),
                        ButtonSegment(
                          value: 'HUTANG',
                          label: Text('Belum Lunas'),
                          icon: Icon(Icons.pending_outlined),
                        ),
                      ],
                      selected: {status},
                      onSelectionChanged: (set) {
                        setDialogState(() {
                          status = set.first;
                          paidCtrl.text = status == 'LUNAS'
                              ? po.grandTotal.toInt().toString()
                              : '0';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: paidCtrl,
                      enabled: status != 'LUNAS',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Jumlah Dibayar (Rp)",
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sisa Hutang: ${Formatters.formatRupiah(remaining.toDouble())}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: remaining > 0 ? Colors.red : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final isar = context.read<Isar>();
                    final paidAmount = double.tryParse(paidCtrl.text) ?? 0;
                    final newRemaining =
                        (po.grandTotal - paidAmount).clamp(0, po.grandTotal).toDouble();
                    final oldRemaining = po.remainingPayable;

                    await isar.writeTxn(() async {
                      po.paymentStatus = status;
                      po.paidAmount = status == 'LUNAS' ? po.grandTotal : paidAmount;
                      po.remainingPayable = status == 'LUNAS' ? 0 : newRemaining;
                      po.isSynced = false;
                      await isar.purchaseTransactionModels.put(po);

                      // Sinkronkan agregat hutang ke supplier (dipakai Dashboard)
                      // supaya tidak selisih dengan angka di transaksi.
                      final delta = po.remainingPayable - oldRemaining;
                      if (delta != 0) {
                        final supplier = await isar.supplierModels.get(po.supplierId);
                        if (supplier != null) {
                          supplier.totalPayable += delta;
                          if (supplier.totalPayable < 0.001) supplier.totalPayable = 0.0;
                          await isar.supplierModels.put(supplier);
                        }
                      }
                    });

                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    if (mounted) {
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Status pembayaran berhasil diperbarui."),
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
      },
    );
  }

  /// Hitung ulang total piutang pelanggan (CustomerModel.totalDebt) dan
  /// total hutang supplier (SupplierModel.totalPayable) langsung dari data
  /// transaksi asli. Dipakai untuk memperbaiki selisih angka di Dashboard
  /// kalau pernah ada koreksi status pembayaran yang bikin angka meleset.
  Future<void> _reconcileDebtTotals() async {
    final isar = context.read<Isar>();

    await isar.writeTxn(() async {
      final allSales = await isar.saleTransactionModels.where().findAll();
      final debtByCustomer = <int, double>{};
      for (final s in allSales) {
        if (s.remainingDebt > 0) {
          debtByCustomer[s.customerId] =
              (debtByCustomer[s.customerId] ?? 0) + s.remainingDebt;
        }
      }
      final allCustomers = await isar.customerModels.where().findAll();
      for (final c in allCustomers) {
        final correctTotal = debtByCustomer[c.id] ?? 0.0;
        if ((c.totalDebt - correctTotal).abs() > 0.01) {
          c.totalDebt = correctTotal;
          await isar.customerModels.put(c);
        }
      }

      final allPurchases = await isar.purchaseTransactionModels.where().findAll();
      final payableBySupplier = <int, double>{};
      for (final p in allPurchases) {
        if (p.remainingPayable > 0) {
          payableBySupplier[p.supplierId] =
              (payableBySupplier[p.supplierId] ?? 0) + p.remainingPayable;
        }
      }
      final allSuppliers = await isar.supplierModels.where().findAll();
      for (final sp in allSuppliers) {
        final correctTotal = payableBySupplier[sp.id] ?? 0.0;
        if ((sp.totalPayable - correctTotal).abs() > 0.01) {
          sp.totalPayable = correctTotal;
          await isar.supplierModels.put(sp);
        }
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Total piutang & hutang berhasil disinkronkan ulang."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Hapus transaksi penjualan: kembalikan stok barang yang terjual,
  /// kurangi piutang pelanggan (kalau ada sisa), lalu hapus item & transaksinya.
  /// Hanya Admin/Owner (dicek di pemanggil).
  Future<void> _confirmDeleteSale(SaleTransactionModel sale) async {
    final isar = context.read<Isar>();
    final customerName =
        _customerNames[sale.customerId] ?? "Pelanggan #${sale.customerId}";

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus Transaksi"),
        content: Text(
          "Yakin ingin menghapus faktur '${sale.invoiceNumber}' ($customerName)?\n\n"
          "Stok barang yang terjual di transaksi ini akan dikembalikan otomatis"
          "${sale.remainingDebt > 0 ? ', dan sisa piutang pelanggan untuk transaksi ini akan dihapus' : ''}."
          " Tindakan ini tidak bisa dibatalkan.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final saleItems = await isar.saleItemModels
                  .filter()
                  .saleTransactionIdEqualTo(sale.id)
                  .findAll();

              await isar.writeTxn(() async {
                // Kembalikan stok barang yang terjual
                for (final si in saleItems) {
                  final item = await isar.itemModels.get(si.itemId);
                  if (item != null) {
                    item.currentStock += si.qty;
                    item.isSynced = false;
                    await isar.itemModels.put(item);

                    await isar.stockMovementLogModels.put(
                      StockMovementLogModel(
                        itemId: item.id,
                        changeQty: si.qty,
                        movementType: 'ADJUSTMENT',
                        referenceNumber: 'HAPUS-${sale.invoiceNumber}',
                        timestamp: DateTime.now(),
                        isSynced: false,
                      ),
                    );
                  }
                }

                // Kurangi piutang pelanggan kalau transaksi ini masih berhutang
                if (sale.remainingDebt > 0) {
                  final customer = await isar.customerModels.get(sale.customerId);
                  if (customer != null) {
                    customer.totalDebt -= sale.remainingDebt;
                    if (customer.totalDebt < 0.001) customer.totalDebt = 0.0;
                    await isar.customerModels.put(customer);
                  }
                }

                for (final si in saleItems) {
                  await isar.saleItemModels.delete(si.id);
                }
                await isar.saleTransactionModels.delete(sale.id);
              });

              // Best-effort hapus juga di Supabase agar tidak "hidup lagi"
              // saat sinkronisasi berikutnya menarik data dari cloud.
              try {
                await Supabase.instance.client
                    .from('sales')
                    .delete()
                    .eq('invoice_number', sale.invoiceNumber);
              } catch (_) {
                // Offline / gagal koneksi: cukup terhapus lokal dulu.
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Transaksi '${sale.invoiceNumber}' telah dihapus, stok dikembalikan."),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Hapus transaksi pembelian: kembalikan (kurangi) stok barang yang dibeli,
  /// kurangi hutang toko ke supplier (kalau ada sisa), lalu hapus item & transaksinya.
  /// Hanya Admin/Owner (dicek di pemanggil).
  Future<void> _confirmDeletePurchase(PurchaseTransactionModel po) async {
    final isar = context.read<Isar>();
    final supplierName = _supplierNames[po.supplierId] ?? "Supplier #${po.supplierId}";

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus Transaksi"),
        content: Text(
          "Yakin ingin menghapus PO/faktur '${po.poNumber}' ($supplierName)?\n\n"
          "Stok barang yang dibeli di transaksi ini akan dikurangi kembali (dibatalkan)"
          "${po.remainingPayable > 0 ? ', dan sisa hutang toko ke supplier untuk transaksi ini akan dihapus' : ''}."
          " Tindakan ini tidak bisa dibatalkan.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final purchaseItems = await isar.purchaseItemModels
                  .filter()
                  .purchaseTransactionIdEqualTo(po.id)
                  .findAll();

              await isar.writeTxn(() async {
                // Batalkan penambahan stok dari pembelian ini
                for (final pi in purchaseItems) {
                  final item = await isar.itemModels.get(pi.itemId);
                  if (item != null) {
                    item.currentStock -= pi.qty;
                    if (item.currentStock < 0) item.currentStock = 0;
                    item.isSynced = false;
                    await isar.itemModels.put(item);

                    await isar.stockMovementLogModels.put(
                      StockMovementLogModel(
                        itemId: item.id,
                        changeQty: -pi.qty,
                        movementType: 'ADJUSTMENT',
                        referenceNumber: 'HAPUS-${po.poNumber}',
                        timestamp: DateTime.now(),
                        isSynced: false,
                      ),
                    );
                  }
                }

                // Kurangi hutang supplier kalau transaksi ini masih berhutang
                if (po.remainingPayable > 0) {
                  final supplier = await isar.supplierModels.get(po.supplierId);
                  if (supplier != null) {
                    supplier.totalPayable -= po.remainingPayable;
                    if (supplier.totalPayable < 0.001) supplier.totalPayable = 0.0;
                    await isar.supplierModels.put(supplier);
                  }
                }

                for (final pi in purchaseItems) {
                  await isar.purchaseItemModels.delete(pi.id);
                }
                await isar.purchaseTransactionModels.delete(po.id);
              });

              try {
                await Supabase.instance.client
                    .from('purchases')
                    .delete()
                    .eq('po_number', po.poNumber);
              } catch (_) {
                // Offline / gagal koneksi: cukup terhapus lokal dulu.
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Transaksi '${po.poNumber}' telah dihapus, stok disesuaikan."),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final canManage = RolePermission.canManagePurchasesAndDebts(
      widget.currentUser.userRoleEnum,
    );
    final list = _historyShowSales ? _allSales : _allPurchases;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Riwayat Penjualan'),
                icon: Icon(Icons.call_received),
              ),
              ButtonSegment(
                value: false,
                label: Text('Riwayat Pembelian'),
                icon: Icon(Icons.call_made),
              ),
            ],
            selected: {_historyShowSales},
            onSelectionChanged: (set) {
              setState(() => _historyShowSales = set.first);
            },
          ),
          if (canManage) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _reconcileDebtTotals,
                icon: const Icon(Icons.sync_problem, size: 16),
                label: const Text(
                  "Sinkronkan Ulang Total Piutang & Hutang (Dashboard)",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Menampilkan ${list.length} transaksi (semua status, terbaru dulu)",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("Belum ada transaksi."))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _historyShowSales
                          ? _buildSaleHistoryCard(
                              _allSales[index], canManage)
                          : _buildPurchaseHistoryCard(
                              _allPurchases[index], canManage);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleHistoryCard(SaleTransactionModel sale, bool canManage) {
    final isPaidOff = sale.paymentStatus == 'LUNAS';
    final customerName =
        _customerNames[sale.customerId] ?? "Pelanggan #${sale.customerId}";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showSaleItemsDialog(sale),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sale.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPaidOff ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPaidOff ? "LUNAS" : "BELUM LUNAS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPaidOff ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Pelanggan: $customerName",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                "Tanggal: ${Formatters.formatDate(sale.date)}",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Total: ${Formatters.formatRupiah(sale.grandTotal)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        "Dibayar: ${Formatters.formatRupiah(sale.paidAmount)}",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.receipt_long_outlined),
                        tooltip: 'Lihat Detail Item',
                        color: Colors.blueGrey,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showSaleItemsDialog(sale),
                      ),
                      if (canManage) ...[
                        const SizedBox(width: 4),
                        OutlinedButton.icon(
                          onPressed: () => _openChangeSaleStatusDialog(sale),
                          icon: const Icon(Icons.sync_alt, size: 16),
                          label: const Text("Ubah Status", style: TextStyle(fontSize: 12)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          tooltip: 'Hapus Transaksi',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _confirmDeleteSale(sale),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseHistoryCard(PurchaseTransactionModel po, bool canManage) {
    final isPaidOff = po.paymentStatus == 'LUNAS';
    final supplierName = _supplierNames[po.supplierId] ?? "Supplier #${po.supplierId}";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showPurchaseItemsDialog(po),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      po.poNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPaidOff ? Colors.green.shade100 : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPaidOff ? "LUNAS" : "BELUM LUNAS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPaidOff ? Colors.green.shade900 : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Distributor: $supplierName",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                "Tanggal: ${Formatters.formatDate(po.date)}",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Total: ${Formatters.formatRupiah(po.grandTotal)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        "Dibayar: ${Formatters.formatRupiah(po.paidAmount)}",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.receipt_long_outlined),
                        tooltip: 'Lihat Detail Item',
                        color: Colors.blueGrey,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showPurchaseItemsDialog(po),
                      ),
                      if (canManage) ...[
                        const SizedBox(width: 4),
                        OutlinedButton.icon(
                          onPressed: () => _openChangePurchaseStatusDialog(po),
                          icon: const Icon(Icons.sync_alt, size: 16),
                          label: const Text("Ubah Status", style: TextStyle(fontSize: 12)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          tooltip: 'Hapus Transaksi',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _confirmDeletePurchase(po),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalActiveReceivables = _saleDebts.fold<double>(
      0.0,
      (sum, item) => sum + item.remainingDebt,
    );
    final totalActivePayables = _purchaseDebts.fold<double>(
      0.0,
      (sum, item) => sum + item.remainingPayable,
    );

    final displayedSales = _onlyUnpaidSales
        ? _saleDebts.where((s) => s.remainingDebt > 0).toList()
        : _saleDebts;

    final displayedPurchases = _onlyUnpaidPurchases
        ? _purchaseDebts.where((p) => p.remainingPayable > 0).toList()
        : _purchaseDebts;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                icon: const Icon(Icons.call_received, size: 20),
                text: "Piutang Pelanggan (${displayedSales.length})",
              ),
              Tab(
                icon: const Icon(Icons.call_made, size: 20),
                text: "Hutang ke Supplier (${displayedPurchases.length})",
              ),
              Tab(
                icon: const Icon(Icons.history, size: 20),
                text: "Riwayat Transaksi",
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: PIUTANG PELANGGAN
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Card(
                  color: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Total Piutang Belum Tertagih",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatRupiah(totalActiveReceivables),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        FilterChip(
                          label: const Text("Hanya Belum Lunas"),
                          selected: _onlyUnpaidSales,
                          onSelected: (val) {
                            setState(() => _onlyUnpaidSales = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List Piutang
                Expanded(
                  child: displayedSales.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                              SizedBox(height: 8),
                              Text("Tidak ada faktur piutang pelanggan yang tertunggak."),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: displayedSales.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final sale = displayedSales[index];
                            final isPaidOff = sale.remainingDebt <= 0;
                            final customerName =
                                _customerNames[sale.customerId] ?? "Pelanggan #${sale.customerId}";

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isPaidOff ? Colors.grey.shade300 : Colors.red.shade300,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris nomor invoice + badge status (fleksibel, tidak overflow)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            sale.invoiceNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isPaidOff
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isPaidOff ? "LUNAS" : "TEMPO",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isPaidOff
                                                  ? Colors.green.shade900
                                                  : Colors.red.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Pelanggan: $customerName",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "Tanggal: ${Formatters.formatDate(sale.date)}${sale.dueDate != null ? ' | Jatuh Tempo: ${Formatters.formatDate(sale.dueDate!)}' : ''}",
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 8),
                                    // Baris nominal + aksi: pakai Wrap agar otomatis turun baris di layar sempit
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Sisa: ${Formatters.formatRupiah(sale.remainingDebt)}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isPaidOff
                                                    ? Colors.green.shade800
                                                    : Colors.red,
                                              ),
                                            ),
                                            Text(
                                              "Total: ${Formatters.formatRupiah(sale.grandTotal)}",
                                              style: TextStyle(
                                                  fontSize: 11, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.print_outlined),
                                              tooltip: 'Cetak Faktur',
                                              color: Colors.blueGrey,
                                              visualDensity: VisualDensity.compact,
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(8),
                                              onPressed: () => _printInvoice(sale),
                                            ),
                                            if (!isPaidOff) ...[
                                              const SizedBox(width: 4),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 8),
                                                  minimumSize: const Size(0, 36),
                                                  backgroundColor: Colors.green.shade700,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => _openPayCustomerDebtDialog(sale),
                                                icon: const Icon(Icons.payment, size: 16),
                                                label: const Text("Bayar / Lunasi",
                                                    style: TextStyle(fontSize: 12)),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // TAB 2: HUTANG SUPPLIER
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Card(
                  color: Colors.amber.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.amber.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Total Hutang Toko ke Supplier",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatRupiah(totalActivePayables),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        FilterChip(
                          label: const Text("Hanya Belum Lunas"),
                          selected: _onlyUnpaidPurchases,
                          onSelected: (val) {
                            setState(() => _onlyUnpaidPurchases = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List Hutang Supplier
                Expanded(
                  child: displayedPurchases.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                              SizedBox(height: 8),
                              Text("Tidak ada faktur hutang supplier yang tertunggak."),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: displayedPurchases.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final po = displayedPurchases[index];
                            final isPaidOff = po.remainingPayable <= 0;
                            final supplierName =
                                _supplierNames[po.supplierId] ?? "Supplier #${po.supplierId}";

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isPaidOff ? Colors.grey.shade300 : Colors.amber.shade400,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris nomor PO + badge status (fleksibel, tidak overflow)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            po.poNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isPaidOff
                                                ? Colors.green.shade100
                                                : Colors.amber.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isPaidOff ? "LUNAS" : "HUTANG",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isPaidOff
                                                  ? Colors.green.shade900
                                                  : Colors.amber.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Distributor: $supplierName",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "Tanggal: ${Formatters.formatDate(po.date)}${po.dueDate != null ? ' | Jatuh Tempo: ${Formatters.formatDate(po.dueDate!)}' : ''}",
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 8),
                                    // Baris nominal + aksi: pakai Wrap agar otomatis turun baris di layar sempit
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Sisa: ${Formatters.formatRupiah(po.remainingPayable)}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isPaidOff
                                                    ? Colors.green.shade800
                                                    : Colors.amber.shade900,
                                              ),
                                            ),
                                            Text(
                                              "Total: ${Formatters.formatRupiah(po.grandTotal)}",
                                              style: TextStyle(
                                                  fontSize: 11, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.print_outlined),
                                              tooltip: 'Cetak PO',
                                              color: Colors.blueGrey,
                                              visualDensity: VisualDensity.compact,
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(8),
                                              onPressed: () => _printPO(po),
                                            ),
                                            if (!isPaidOff) ...[
                                              const SizedBox(width: 4),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 8),
                                                  minimumSize: const Size(0, 36),
                                                  backgroundColor: Colors.indigo.shade700,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => _openPaySupplierDebtDialog(po),
                                                icon: const Icon(Icons.payment, size: 16),
                                                label: const Text("Bayar Hutang",
                                                    style: TextStyle(fontSize: 12)),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // TAB 3: RIWAYAT TRANSAKSI LENGKAP (semua status, tanpa filter)
          _buildHistoryTab(),
        ],
      ),
    );
  }
}
