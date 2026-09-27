import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import '../../core/authorization/role_permission.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/models/user_model.dart';

/// Halaman Log Aktivitas: menampilkan jejak aksi-aksi sensitif (hapus data,
/// ubah status pembayaran, penarikan owner, tutup bulan, dll) — siapa
/// melakukan apa dan kapan. Khusus Admin & Owner.
class AuditLogScreen extends StatefulWidget {
  final UserModel currentUser;

  const AuditLogScreen({super.key, required this.currentUser});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  List<AuditLogModel> _logs = [];
  List<AuditLogModel> _filteredLogs = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _actionFilter = 'SEMUA';
  bool _isLoading = true;
  StreamSubscription? _logSub;

  static const Map<String, String> _actionLabels = {
    'DELETE_SALE': 'Hapus Penjualan',
    'DELETE_PURCHASE': 'Hapus Pembelian',
    'CHANGE_SALE_STATUS': 'Ubah Status Penjualan',
    'CHANGE_PURCHASE_STATUS': 'Ubah Status Pembelian',
    'RECONCILE_DEBT_TOTALS': 'Sinkronkan Ulang Piutang/Hutang',
    'DELETE_CUSTOMER': 'Hapus Pelanggan',
    'DELETE_SUPPLIER': 'Hapus Supplier',
    'DELETE_ITEM': 'Hapus Barang',
    'CLOSE_MONTH': 'Tutup Bulan',
    'OWNER_WITHDRAWAL': 'Penarikan Owner',
    'DELETE_WITHDRAWAL': 'Hapus Penarikan',
    'EDIT_OWNER': 'Edit Data Owner',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_applyFilter);
    final isar = context.read<Isar>();
    _logSub = isar.auditLogModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && _logs.isEmpty) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();
    final logs = await isar.auditLogModels.where().sortByTimestampDesc().findAll();

    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredLogs = _logs.where((log) {
        final matchesAction = _actionFilter == 'SEMUA' || log.action == _actionFilter;
        final matchesQuery = q.isEmpty ||
            log.username.toLowerCase().contains(q) ||
            log.description.toLowerCase().contains(q);
        return matchesAction && matchesQuery;
      }).toList();
    });
  }

  String _actionLabel(String action) => _actionLabels[action] ?? action;

  Color _actionColor(String action) {
    if (action.startsWith('DELETE')) return Colors.red;
    if (action.startsWith('CHANGE') || action == 'RECONCILE_DEBT_TOTALS') return Colors.orange.shade800;
    if (action == 'CLOSE_MONTH') return Colors.teal;
    if (action == 'OWNER_WITHDRAWAL') return Colors.indigo;
    return Colors.blueGrey;
  }

  IconData _actionIcon(String action) {
    if (action.startsWith('DELETE')) return Icons.delete_outline;
    if (action.startsWith('CHANGE')) return Icons.sync_alt;
    if (action == 'CLOSE_MONTH') return Icons.lock_clock_outlined;
    if (action == 'OWNER_WITHDRAWAL') return Icons.payments_outlined;
    if (action == 'EDIT_OWNER') return Icons.edit_outlined;
    return Icons.history;
  }

  @override
  Widget build(BuildContext context) {
    final canView = RolePermission.canManagePurchasesAndDebts(widget.currentUser.userRoleEnum);

    if (!canView) {
      return Scaffold(
        appBar: AppBar(title: const Text("Log Aktivitas")),
        body: const Center(
          child: Text("Akses ditolak: Hanya Admin & Owner yang dapat membuka halaman ini."),
        ),
      );
    }

    final actionOptions = ['SEMUA', ..._actionLabels.keys.where((a) => _logs.any((l) => l.action == a))];

    return Scaffold(
      appBar: AppBar(title: const Text("Log Aktivitas")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Cari nama pengguna atau deskripsi aksi...",
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchCtrl.clear(),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: actionOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final action = actionOptions[index];
                        final label = action == 'SEMUA' ? 'Semua' : _actionLabel(action);
                        return FilterChip(
                          label: Text(label, style: const TextStyle(fontSize: 12)),
                          selected: _actionFilter == action,
                          onSelected: (_) {
                            setState(() => _actionFilter = action);
                            _applyFilter();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Menampilkan ${_filteredLogs.length} dari ${_logs.length} log",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filteredLogs.isEmpty
                        ? const Center(child: Text("Belum ada aktivitas tercatat."))
                        : ListView.separated(
                            itemCount: _filteredLogs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final log = _filteredLogs[index];
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _actionColor(log.action).withValues(alpha: 0.15),
                                    child: Icon(_actionIcon(log.action), color: _actionColor(log.action), size: 20),
                                  ),
                                  title: Text(
                                    _actionLabel(log.action),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(log.description, style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${log.username} (${log.role}) • ${Formatters.formatDateTime(log.timestamp)}",
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
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
