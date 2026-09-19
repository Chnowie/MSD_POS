import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import '../../core/authorization/role_permission.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/services/dashboard_calculator.dart';
import '../../utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel currentUser;

  const DashboardScreen({super.key, required this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardSummary? _summary;
  List<ItemModel> _lowStockItems = [];
  List<SaleTransactionModel> _recentSales = [];
  bool _isLoading = true;
  StreamSubscription? _salesSub;
  StreamSubscription? _purchasesSub;
  StreamSubscription? _itemsSub;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _initWatchers();
  }

  void _initWatchers() {
    final isar = context.read<Isar>();
    _salesSub = isar.saleTransactionModels.watchLazy().listen((_) {
      if (mounted) _loadDashboardData(showLoading: false);
    });
    _purchasesSub = isar.purchaseTransactionModels.watchLazy().listen((_) {
      if (mounted) _loadDashboardData(showLoading: false);
    });
    _itemsSub = isar.itemModels.watchLazy().listen((_) {
      if (mounted) _loadDashboardData(showLoading: false);
    });
  }


  Future<void> _printInvoice(SaleTransactionModel sale) async {
    final isar = context.read<Isar>();
    final customer = await isar.customerModels.get(sale.customerId);
    final items = await isar.saleItemModels.filter().saleTransactionIdEqualTo(sale.id).findAll();
    
    final itemIds = items.map((e) => e.itemId).toList();
    final dbItemsList = await isar.itemModels.getAll(itemIds);
    final itemMap = {for (var item in dbItemsList) if (item != null) item.id: item};

    if (customer == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer tidak ditemukan')));
      return;
    }

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

  @override
  void dispose() {
    _salesSub?.cancel();
    _purchasesSub?.cancel();
    _itemsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData({bool showLoading = true}) async {
    if (showLoading && _summary == null) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();
    final calculator = context.read<DashboardCalculator>();

    // 1. Hitung Statistik Ringkasan
    final summaryResult = await calculator.calculateMonthlySummary();

    // 2. Ambil Barang dengan Stok Kritis / Menipis
    final allItems = await isar.itemModels.where().findAll();
    final lowStock = allItems
        .where((item) => item.currentStock <= item.minStock)
        .toList();

    // 3. Ambil Transaksi Penjualan Terakhir
    final recent = await isar.saleTransactionModels
        .where()
        .sortByDateDesc()
        .limit(5)
        .findAll();

    if (mounted) {
      setState(() {
        _summary = summaryResult.fold((l) => null, (r) => r);
        _lowStockItems = lowStock;
        _recentSales = recent;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = widget.currentUser.userRoleEnum;
    final canViewProfit = RolePermission.canViewNetProfitDashboard(role);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        widget.currentUser.username.isNotEmpty
                            ? widget.currentUser.username[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentUser.username,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Role: ${widget.currentUser.role}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Peringatan Stok Menipis (Low Stock Banner)
            if (_lowStockItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.amber.shade900, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peringatan Stok Menipis (${_lowStockItems.length} Item)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          Text(
                            _lowStockItems
                                .take(2)
                                .map((e) => '${e.name} (Sisa ${e.currentStock})')
                                .join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Section Title
            Text(
              "Ringkasan Finansial Bulan Ini",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Grid Metrik Finansial
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildMetricCard(
                      title: "Penjualan (Omzet)",
                      value: Formatters.formatRupiah(_summary?.totalSalesMonth ?? 0),
                      icon: Icons.point_of_sale_rounded,
                      color: Colors.blue.shade700,
                      bgColor: Colors.blue.shade50,
                    ),
                    _buildMetricCard(
                      title: "Pembelian (PO)",
                      value: Formatters.formatRupiah(_summary?.totalPurchasesMonth ?? 0),
                      icon: Icons.shopping_bag_outlined,
                      color: Colors.indigo.shade700,
                      bgColor: Colors.indigo.shade50,
                    ),
                    _buildMetricCard(
                      title: "Piutang Pelanggan",
                      value: Formatters.formatRupiah(_summary?.totalActivityReceivables ?? 0),
                      icon: Icons.receipt_long_rounded,
                      color: Colors.orange.shade800,
                      bgColor: Colors.orange.shade50,
                    ),
                    _buildMetricCard(
                      title: "Hutang ke Supplier",
                      value: Formatters.formatRupiah(_summary?.totalActivityPayables ?? 0),
                      icon: Icons.account_balance_wallet_outlined,
                      color: Colors.deepOrange.shade800,
                      bgColor: Colors.deepOrange.shade50,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Khusus Owner: Card Laba Bersih
            if (canViewProfit) ...[
              Card(
                elevation: 2,
                color: Colors.teal.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.stars_rounded,
                                  color: Colors.amberAccent, size: 20),
                              SizedBox(width: 6),
                              Text(
                                "ESTIMASI LABA BERSIH (KHUSUS OWNER)",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Formatters.formatRupiah(
                              _summary?.netProfitMonth ?? 0,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Riwayat Transaksi Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Penjualan Terbaru",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_recentSales.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text("Belum ada transaksi penjualan."),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentSales.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sale = _recentSales[index];
                  final isLunas = sale.paymentStatus == 'LUNAS';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isLunas
                          ? Colors.green.shade100
                          : Colors.amber.shade100,
                      child: Icon(
                        isLunas ? Icons.check_circle : Icons.schedule,
                        color: isLunas
                            ? Colors.green.shade800
                            : Colors.amber.shade900,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      sale.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(Formatters.formatDateTime(sale.date)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.print, color: Colors.blue),
                          onPressed: () => _printInvoice(sale),
                          tooltip: 'Cetak Faktur',
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.formatRupiah(sale.grandTotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              sale.paymentStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isLunas
                                    ? Colors.green.shade700
                                    : Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
