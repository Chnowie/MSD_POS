import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/formatters.dart';
import '../../data/datasources/sync_service.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../../data/models/stock_movement_log_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/user_model.dart';

class OfflineDbViewerDialog extends StatefulWidget {
  const OfflineDbViewerDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const OfflineDbViewerDialog(),
    );
  }

  @override
  State<OfflineDbViewerDialog> createState() => _OfflineDbViewerDialogState();
}

class _OfflineDbViewerDialogState extends State<OfflineDbViewerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _dbPath = "Memuat...";
  int _dbSizeBytes = 0;

  int _userCount = 0;
  int _itemCount = 0;
  int _customerCount = 0;
  int _supplierCount = 0;
  int _salesCount = 0;
  int _purchasesCount = 0;
  int _stockLogsCount = 0;

  List<ItemModel> _items = [];
  List<SaleTransactionModel> _sales = [];
  List<PurchaseTransactionModel> _purchases = [];
  List<CustomerModel> _customers = [];
  List<SupplierModel> _suppliers = [];
  List<StockMovementLogModel> _logs = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadDbInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDbInfo() async {
    setState(() => _isLoading = true);
    final isar = context.read<Isar>();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/sparepart_pos_db.isar');
      int size = 0;
      if (await dbFile.exists()) {
        size = await dbFile.length();
      }

      final users = await isar.userModels.count();
      final items = await isar.itemModels.where().findAll();
      final customers = await isar.customerModels.where().findAll();
      final suppliers = await isar.supplierModels.where().findAll();
      final sales = await isar.saleTransactionModels.where().sortByDateDesc().findAll();
      final purchases = await isar.purchaseTransactionModels.where().sortByDateDesc().findAll();
      final logs = await isar.stockMovementLogModels.where().sortByTimestampDesc().limit(100).findAll();

      if (mounted) {
        setState(() {
          _dbPath = dbFile.path;
          _dbSizeBytes = size;
          _userCount = users;
          _itemCount = items.length;
          _customerCount = customers.length;
          _supplierCount = suppliers.length;
          _salesCount = sales.length;
          _purchasesCount = purchases.length;
          _stockLogsCount = logs.length;

          _items = items;
          _customers = customers;
          _suppliers = suppliers;
          _sales = sales;
          _purchases = purchases;
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storage_rounded, color: Colors.indigo, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Isar Database Offline Viewer",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Lihat isi penyimpanan lokal perangkat tanpa koneksi internet",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Info Path File Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, size: 20, color: Colors.black87),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Lokasi File Database di Komputer:",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            _dbPath,
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatBytes(_dbSizeBytes),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: "Salin Path Database",
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _dbPath));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Path file database disalin ke clipboard!")),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Summary Badges
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatChip("Pengguna", _userCount, Icons.person_outline, Colors.indigo),
                    const SizedBox(width: 8),
                    _buildStatChip("Barang", _itemCount, Icons.inventory_2_outlined, Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip("Penjualan", _salesCount, Icons.point_of_sale_outlined, Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip("Pembelian", _purchasesCount, Icons.shopping_cart_outlined, Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatChip("Customer", _customerCount, Icons.people_outline, Colors.teal),
                    const SizedBox(width: 8),
                    _buildStatChip("Supplier", _supplierCount, Icons.storefront_outlined, Colors.purple),
                    const SizedBox(width: 8),
                    _buildStatChip("Riwayat Stok", _stockLogsCount, Icons.history_outlined, Colors.brown),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Action Force Re-Sync Button
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text("Tandai & Unggah Ulang Semua Data ke Supabase (Force Re-sync)"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: BorderSide(color: Colors.indigo.shade200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final syncService = context.read<SyncService>();
                    final res = await syncService.forceResyncAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res.message),
                          backgroundColor: res.isSuccess ? Colors.green.shade700 : Colors.orange.shade800,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: "Penjualan (Sales)"),
                  Tab(text: "Pembelian (Purchases)"),
                  Tab(text: "Barang (Items)"),
                  Tab(text: "Customer"),
                  Tab(text: "Supplier"),
                  Tab(text: "Log Stok"),
                ],
              ),
              const SizedBox(height: 8),

              // Tab Views
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSalesList(),
                          _buildPurchasesList(),
                          _buildItemsList(),
                          _buildCustomersList(),
                          _buildSuppliersList(),
                          _buildLogsList(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            "$label: $count",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    if (_sales.isEmpty) {
      return const Center(child: Text("Belum ada data transaksi penjualan tersimpan di Isar."));
    }
    return ListView.separated(
      itemCount: _sales.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = _sales[i];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: s.isSynced ? Colors.green.shade100 : Colors.orange.shade100,
            child: Icon(
              s.isSynced ? Icons.cloud_done : Icons.cloud_off,
              size: 14,
              color: s.isSynced ? Colors.green.shade900 : Colors.orange.shade900,
            ),
          ),
          title: Text(
            "${s.invoiceNumber} • ${Formatters.formatRupiah(s.grandTotal)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Status: ${s.paymentStatus} • Bayar: ${Formatters.formatRupiah(s.paidAmount)} • Tanggal: ${s.date.toLocal().toString().split('.')[0]}",
          ),
          trailing: Chip(
            padding: EdgeInsets.zero,
            label: Text(s.isSynced ? "Synced" : "Local Only", style: const TextStyle(fontSize: 10)),
            backgroundColor: s.isSynced ? Colors.green.shade50 : Colors.orange.shade50,
          ),
        );
      },
    );
  }

  Widget _buildPurchasesList() {
    if (_purchases.isEmpty) {
      return const Center(child: Text("Belum ada data transaksi pembelian tersimpan di Isar."));
    }
    return ListView.separated(
      itemCount: _purchases.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = _purchases[i];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: p.isSynced ? Colors.green.shade100 : Colors.orange.shade100,
            child: Icon(
              p.isSynced ? Icons.cloud_done : Icons.cloud_off,
              size: 14,
              color: p.isSynced ? Colors.green.shade900 : Colors.orange.shade900,
            ),
          ),
          title: Text(
            "${p.poNumber} • ${Formatters.formatRupiah(p.grandTotal)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Status: ${p.paymentStatus} • Bayar: ${Formatters.formatRupiah(p.paidAmount)} • Tanggal: ${p.date.toLocal().toString().split('.')[0]}",
          ),
          trailing: Chip(
            padding: EdgeInsets.zero,
            label: Text(p.isSynced ? "Synced" : "Local Only", style: const TextStyle(fontSize: 10)),
            backgroundColor: p.isSynced ? Colors.green.shade50 : Colors.orange.shade50,
          ),
        );
      },
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) return const Center(child: Text("Belum ada data barang di Isar."));
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = _items[i];
        return ListTile(
          dense: true,
          title: Text("${item.name} (${item.partNumber})", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Kategori: ${item.category} • Beli: ${Formatters.formatRupiah(item.buyPrice)} • Jual: ${Formatters.formatRupiah(item.sellPrice)}"),
          trailing: Text("Stok: ${item.currentStock}", style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildCustomersList() {
    if (_customers.isEmpty) return const Center(child: Text("Belum ada customer di Isar."));
    return ListView.separated(
      itemCount: _customers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = _customers[i];
        return ListTile(
          dense: true,
          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("HP: ${c.phone} • Alamat: ${c.address}"),
          trailing: Text("Piutang: ${Formatters.formatRupiah(c.totalDebt)}"),
        );
      },
    );
  }

  Widget _buildSuppliersList() {
    if (_suppliers.isEmpty) return const Center(child: Text("Belum ada supplier di Isar."));
    return ListView.separated(
      itemCount: _suppliers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = _suppliers[i];
        return ListTile(
          dense: true,
          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("HP: ${s.phone} • Alamat: ${s.address}"),
          trailing: Text("Hutang: ${Formatters.formatRupiah(s.totalPayable)}"),
        );
      },
    );
  }

  Widget _buildLogsList() {
    if (_logs.isEmpty) return const Center(child: Text("Belum ada log stok di Isar."));
    return ListView.separated(
      itemCount: _logs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final l = _logs[i];
        final isPositive = l.changeQty > 0;
        return ListTile(
          dense: true,
          leading: Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.green : Colors.red,
            size: 18,
          ),
          title: Text("${l.movementType} • Ref: ${l.referenceNumber}"),
          subtitle: Text("Waktu: ${l.timestamp.toLocal().toString().split('.')[0]}"),
          trailing: Text(
            "${isPositive ? '+' : ''}${l.changeQty}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        );
      },
    );
  }
}
