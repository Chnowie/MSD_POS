import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/sync_service.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import 'category_management_screen.dart';
import 'dashboard_screen.dart';
import 'debt_report_screen.dart';
import 'inventory_screen.dart';
import 'login_screen.dart';
import 'offline_db_viewer_dialog.dart';
import 'partners_screen.dart';
import 'pos_screen.dart';
import 'purchase_screen.dart';
import '../theme/theme_controller.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel currentUser;
  final bool isOfflineMode;

  const MainNavigationScreen({
    super.key,
    required this.currentUser,
    this.isOfflineMode = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  PopupMenuItem<ThemeMode> _themeMenuItem(
      ThemeMode value, IconData icon, String label, ThemeMode current) {
    final isSelected = value == current;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isSelected ? Colors.indigo : null),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.indigo : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 18, color: Colors.indigo),
          ],
        ],
      ),
    );
  }

  void _triggerSync() async {
    final syncService = context.read<SyncService>();
    final result = await syncService.syncAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.isSuccess ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(result.message)),
            ],
          ),
          backgroundColor: result.isSuccess ? Colors.green.shade700 : Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncService = context.read<SyncService>();
    final screens = [
      DashboardScreen(currentUser: widget.currentUser),
      PosScreen(currentUser: widget.currentUser),
      PurchaseScreen(currentUser: widget.currentUser),
      InventoryScreen(currentUser: widget.currentUser),
      PartnersScreen(currentUser: widget.currentUser),
      DebtReportScreen(currentUser: widget.currentUser),
    ];

    final titles = [
      "Dashboard Finansial & Toko",
      "Penjualan & Kasir (POS)",
      "Pembelian & Restock Supplier",
      "Katalog Stok Sparepart",
      "Master Data Customer & Supplier",
      "Laporan Hutang & Piutang",
    ];

    final isWideScreen = MediaQuery.of(context).size.width >= 900;

    final appBar = AppBar(
      title: Text(
        titles[_currentIndex],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        // Ganti Tema Aplikasi (Terang / Gelap / Ikuti Sistem)
        Builder(
          builder: (context) {
            final themeController = context.read<ThemeController>();
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: themeController,
              builder: (context, mode, _) {
                final icon = switch (mode) {
                  ThemeMode.light => Icons.light_mode_outlined,
                  ThemeMode.dark => Icons.dark_mode_outlined,
                  ThemeMode.system => Icons.brightness_auto_outlined,
                };
                return PopupMenuButton<ThemeMode>(
                  tooltip: "Ganti Tema Aplikasi",
                  icon: Icon(icon),
                  onSelected: (selected) => themeController.setThemeMode(selected),
                  itemBuilder: (context) => [
                    _themeMenuItem(ThemeMode.light, Icons.light_mode_outlined, "Terang", mode),
                    _themeMenuItem(ThemeMode.dark, Icons.dark_mode_outlined, "Gelap", mode),
                    _themeMenuItem(
                        ThemeMode.system, Icons.brightness_auto_outlined, "Ikuti Sistem", mode),
                  ],
                );
              },
            );
          },
        ),

        // Kelola Kategori Barang (hanya muncul di tab Katalog Stok Sparepart)
        if (_currentIndex == 3)
          IconButton(
            tooltip: "Kelola Kategori Barang",
            icon: const Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CategoryManagementScreen(),
                ),
              );
            },
          ),

        // Tombol & Status Sync Supabase Cloud
        ValueListenableBuilder<bool>(
          valueListenable: syncService.isSyncing,
          builder: (context, isSyncing, _) {
            return ValueListenableBuilder<int>(
              valueListenable: syncService.pendingSyncCount,
              builder: (context, pendingCount, _) {
                return IconButton(
                  tooltip: isSyncing
                      ? "Sedang menyinkronkan data ke Cloud..."
                      : (pendingCount > 0
                          ? "Ada $pendingCount data belum disinkronkan. Klik untuk sinkron."
                          : "Data tersinkronisasi dengan Supabase"),
                  onPressed: isSyncing ? null : _triggerSync,
                  icon: Badge(
                    isLabelVisible: pendingCount > 0 && !isSyncing,
                    label: Text(
                      pendingCount > 99 ? '99+' : '$pendingCount',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.orange.shade800,
                    child: isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.indigo,
                            ),
                          )
                        : const Icon(Icons.sync_rounded),
                  ),
                );
              },
            );
          },
        ),

        // Indikator Online/Offline Mode
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.isOfflineMode ? Colors.orange.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isOfflineMode ? Icons.cloud_off : Icons.cloud_done,
                size: 14,
                color: widget.isOfflineMode ? Colors.orange.shade900 : Colors.green.shade900,
              ),
              const SizedBox(width: 4),
              Text(
                widget.isOfflineMode ? "Offline" : "Online",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.isOfflineMode ? Colors.orange.shade900 : Colors.green.shade900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // User Info & Logout Popup
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, size: 28),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            } else if (value == 'db_viewer') {
              OfflineDbViewerDialog.show(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.currentUser.username,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    "Role: ${widget.currentUser.role}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Divider(),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'db_viewer',
              child: Row(
                children: [
                  Icon(Icons.storage_rounded, color: Colors.indigo, size: 20),
                  SizedBox(width: 8),
                  Text("Isar DB Offline Viewer", style: TextStyle(color: Colors.indigo)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text("Keluar (Logout)", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );

    final navDestinations = const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: "Dashboard",
      ),
      NavigationDestination(
        icon: Icon(Icons.point_of_sale_outlined),
        selectedIcon: Icon(Icons.point_of_sale),
        label: "Penjualan",
      ),
      NavigationDestination(
        icon: Icon(Icons.add_shopping_cart_outlined),
        selectedIcon: Icon(Icons.add_shopping_cart),
        label: "Pembelian",
      ),
      NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: "Stok Barang",
      ),
      NavigationDestination(
        icon: Icon(Icons.people_alt_outlined),
        selectedIcon: Icon(Icons.people_alt),
        label: "Mitra",
      ),
      NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: "Hutang Piutang",
      ),
    ];

    if (isWideScreen) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              extended: true,
              minExtendedWidth: 210,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text("Dashboard"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale),
                  label: Text("Penjualan (Kasir)"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_shopping_cart_outlined),
                  selectedIcon: Icon(Icons.add_shopping_cart),
                  label: Text("Pembelian (Supplier)"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text("Katalog Sparepart"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: Text("Customer & Supplier"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet),
                  label: Text("Laporan Hutang Piutang"),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: navDestinations,
      ),
    );
  }
}

