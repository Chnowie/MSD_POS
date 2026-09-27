import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/authorization/role_permission.dart';
import '../../core/utils/audit_logger.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/monthly_profit_close_model.dart';
import '../../data/models/owner_model.dart';
import '../../data/models/owner_withdrawal_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../../data/models/user_model.dart';

/// Halaman Bagi Hasil Owner: menghitung & membekukan laba bersih tiap
/// bulan, membagi ke owner sesuai porsi kepemilikan, dan melacak
/// penarikan uang masing-masing owner. Khusus role OWNER.
class OwnerProfitSharingScreen extends StatefulWidget {
  final UserModel currentUser;

  const OwnerProfitSharingScreen({super.key, required this.currentUser});

  @override
  State<OwnerProfitSharingScreen> createState() => _OwnerProfitSharingScreenState();
}

class _OwnerProfitSharingScreenState extends State<OwnerProfitSharingScreen> {
  List<OwnerModel> _owners = [];
  List<DateTime> _unclosedMonths = [];
  Map<String, double> _unclosedMonthPreview = {}; // key: "YYYY-MM"
  List<MonthlyProfitCloseModel> _closedMonths = [];
  List<OwnerWithdrawalModel> _recentWithdrawals = [];
  Map<int, String> _ownerNames = {};
  bool _isLoading = true;

  StreamSubscription? _ownerSub;
  StreamSubscription? _closeSub;
  StreamSubscription? _withdrawalSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initWatchers();
  }

  void _initWatchers() {
    final isar = context.read<Isar>();
    _ownerSub = isar.ownerModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
    _closeSub = isar.monthlyProfitCloseModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
    _withdrawalSub = isar.ownerWithdrawalModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _ownerSub?.cancel();
    _closeSub?.cancel();
    _withdrawalSub?.cancel();
    super.dispose();
  }

  String _monthKey(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}";

  String _monthLabel(DateTime d) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return "${bulan[d.month - 1]} ${d.year}";
  }

  Future<double> _computeMonthProfit(Isar isar, DateTime monthStart) async {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0, 23, 59, 59);
    final sales = await isar.saleTransactionModels
        .filter()
        .dateBetween(monthStart, monthEnd)
        .findAll();
    final purchases = await isar.purchaseTransactionModels
        .filter()
        .dateBetween(monthStart, monthEnd)
        .findAll();

    final salesReceived = sales.fold<double>(0.0, (sum, s) => sum + s.paidAmount);
    final totalPurchases = purchases.fold<double>(0.0, (sum, p) => sum + p.grandTotal);
    return salesReceived - totalPurchases;
  }

  Future<List<DateTime>> _findUnclosedMonths(Isar isar) async {
    final earliestSale = await isar.saleTransactionModels.where().sortByDate().findFirst();
    final earliestPurchase =
        await isar.purchaseTransactionModels.where().sortByDate().findFirst();

    DateTime? earliest = earliestSale?.date;
    if (earliestPurchase != null &&
        (earliest == null || earliestPurchase.date.isBefore(earliest))) {
      earliest = earliestPurchase.date;
    }
    if (earliest == null) return [];

    final now = DateTime.now();
    // Bulan yang boleh ditutup hanya bulan yang SUDAH SELESAI (bukan bulan berjalan)
    final lastClosableMonth = DateTime(now.year, now.month - 1, 1);
    var cursor = DateTime(earliest.year, earliest.month, 1);
    if (cursor.isAfter(lastClosableMonth)) return [];

    final closed = await isar.monthlyProfitCloseModels.where().findAll();
    final closedKeys = closed.map((e) => e.monthKey).toSet();

    final months = <DateTime>[];
    while (!cursor.isAfter(lastClosableMonth)) {
      if (!closedKeys.contains(_monthKey(cursor))) {
        months.add(cursor);
      }
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return months;
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && _owners.isEmpty) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();

    final owners = await isar.ownerModels.where().sortByName().findAll();
    final unclosedMonths = await _findUnclosedMonths(isar);
    final closedMonths =
        await isar.monthlyProfitCloseModels.where().sortByYearDesc().thenByMonthDesc().findAll();
    final withdrawals =
        await isar.ownerWithdrawalModels.where().sortByDateDesc().limit(30).findAll();

    final preview = <String, double>{};
    for (final m in unclosedMonths) {
      preview[_monthKey(m)] = await _computeMonthProfit(isar, m);
    }

    final ownerNames = {for (final o in owners) o.id: o.name};

    if (mounted) {
      setState(() {
        _owners = owners;
        _unclosedMonths = unclosedMonths;
        _unclosedMonthPreview = preview;
        _closedMonths = closedMonths;
        _recentWithdrawals = withdrawals;
        _ownerNames = ownerNames;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmCloseMonth(DateTime monthStart) async {
    final isar = context.read<Isar>();
    final profit = _unclosedMonthPreview[_monthKey(monthStart)] ?? 0.0;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Tutup Bulan ${_monthLabel(monthStart)}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Laba bersih bulan ini: ${Formatters.formatRupiah(profit)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: profit >= 0 ? Colors.green.shade800 : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Setelah ditutup, angka ini DIBEKUKAN dan otomatis dibagi ke "
              "saldo tiap owner sesuai porsi masing-masing. Transaksi lama "
              "bulan ini yang diedit setelahnya TIDAK akan mengubah angka "
              "yang sudah dibagikan.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ..._owners.map((o) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    "${o.name} (${(o.sharePercentage * 100).toStringAsFixed(0)}%): "
                    "${Formatters.formatRupiah(profit * o.sharePercentage)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              await isar.writeTxn(() async {
                await isar.monthlyProfitCloseModels.put(
                  MonthlyProfitCloseModel(
                    monthKey: _monthKey(monthStart),
                    year: monthStart.year,
                    month: monthStart.month,
                    netProfit: profit,
                    closedAt: DateTime.now(),
                  ),
                );
                for (final o in _owners) {
                  o.totalEntitled += profit * o.sharePercentage;
                  await isar.ownerModels.put(o);
                }

                await AuditLogger.record(
                  isar,
                  widget.currentUser,
                  'CLOSE_MONTH',
                  "Tutup bulan ${_monthLabel(monthStart)}, laba bersih "
                  "${Formatters.formatRupiah(profit)}",
                );
              });

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Bulan ${_monthLabel(monthStart)} berhasil ditutup & dibagikan."),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Tutup & Bagikan"),
          ),
        ],
      ),
    );
  }

  void _openWithdrawDialog(OwnerModel owner) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final isar = context.read<Isar>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            final amount = double.tryParse(amountCtrl.text) ?? 0.0;
            final exceedsBalance = amount > owner.availableBalance;

            return AlertDialog(
              title: Text("Tarik Uang - ${owner.name}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Saldo Belum Ditarik: ${Formatters.formatRupiah(owner.availableBalance)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Jumlah Penarikan (Rp)",
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    if (exceedsBalance) ...[
                      const SizedBox(height: 6),
                      const Text(
                        "Melebihi saldo yang belum ditarik.",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: "Catatan (opsional)",
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                ElevatedButton(
                  onPressed: (amount <= 0 || exceedsBalance)
                      ? null
                      : () async {
                          await isar.writeTxn(() async {
                            owner.totalWithdrawn += amount;
                            await isar.ownerModels.put(owner);
                            await isar.ownerWithdrawalModels.put(
                              OwnerWithdrawalModel(
                                uuid: const Uuid().v4(),
                                ownerId: owner.id,
                                amount: amount,
                                date: DateTime.now(),
                                note: noteCtrl.text.trim(),
                                isSynced: false,
                              ),
                            );

                            await AuditLogger.record(
                              isar,
                              widget.currentUser,
                              'OWNER_WITHDRAWAL',
                              "Penarikan ${Formatters.formatRupiah(amount)} oleh ${owner.name}"
                              "${noteCtrl.text.trim().isNotEmpty ? ' (${noteCtrl.text.trim()})' : ''}",
                            );
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Penarikan ${Formatters.formatRupiah(amount)} oleh ${owner.name} tercatat.",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  child: const Text("Tarik"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openEditOwnerDialog(OwnerModel owner) {
    final nameCtrl = TextEditingController(text: owner.name);
    final percentCtrl =
        TextEditingController(text: (owner.sharePercentage * 100).toStringAsFixed(0));
    final isar = context.read<Isar>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Data Owner"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nama Owner"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: percentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Porsi Kepemilikan (%)",
                suffixText: "%",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final percent = double.tryParse(percentCtrl.text.trim());
              if (name.isEmpty || percent == null || percent <= 0 || percent > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nama & porsi (1-100%) wajib valid.")),
                );
                return;
              }
              final oldName = owner.name;
              final oldPercent = (owner.sharePercentage * 100).toStringAsFixed(0);
              await isar.writeTxn(() async {
                owner.name = name;
                owner.sharePercentage = percent / 100;
                await isar.ownerModels.put(owner);

                await AuditLogger.record(
                  isar,
                  widget.currentUser,
                  'EDIT_OWNER',
                  "Edit owner '$oldName' ($oldPercent%) jadi '$name' "
                  "(${percentCtrl.text.trim()}%)",
                );
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteWithdrawal(OwnerWithdrawalModel w) async {
    final isar = context.read<Isar>();
    final ownerName = _ownerNames[w.ownerId] ?? "Owner #${w.ownerId}";

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Catatan Penarikan"),
        content: Text(
          "Yakin ingin menghapus catatan penarikan ${Formatters.formatRupiah(w.amount)} "
          "oleh $ownerName? Saldo belum ditarik owner ini akan dikembalikan.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await isar.writeTxn(() async {
                final owner = await isar.ownerModels.get(w.ownerId);
                if (owner != null) {
                  owner.totalWithdrawn -= w.amount;
                  if (owner.totalWithdrawn < 0.001) owner.totalWithdrawn = 0.0;
                  await isar.ownerModels.put(owner);
                }
                await isar.ownerWithdrawalModels.delete(w.id);

                await AuditLogger.record(
                  isar,
                  widget.currentUser,
                  'DELETE_WITHDRAWAL',
                  "Hapus catatan penarikan ${Formatters.formatRupiah(w.amount)} oleh $ownerName",
                );
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canView = RolePermission.canViewNetProfitDashboard(widget.currentUser.userRoleEnum);

    if (!canView) {
      return Scaffold(
        appBar: AppBar(title: const Text("Bagi Hasil Owner")),
        body: const Center(
          child: Text("Akses ditolak: Hanya Owner yang dapat membuka halaman ini."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bagi Hasil Owner")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Kartu tiap owner
                  ..._owners.map((o) => _buildOwnerCard(o)),
                  const SizedBox(height: 20),

                  // Bulan Belum Ditutup
                  Text(
                    "Bulan Belum Ditutup",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_unclosedMonths.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Semua bulan yang sudah selesai telah ditutup.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    ..._unclosedMonths.map((m) => _buildUnclosedMonthCard(m)),
                  const SizedBox(height: 20),

                  // Riwayat Penarikan
                  Text(
                    "Riwayat Penarikan",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_recentWithdrawals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Belum ada penarikan tercatat.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    ..._recentWithdrawals.map((w) => _buildWithdrawalTile(w)),
                  const SizedBox(height: 20),

                  // Riwayat Bulan Ditutup
                  Text(
                    "Riwayat Bulan Ditutup",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_closedMonths.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Belum ada bulan yang ditutup.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    ..._closedMonths.map((c) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.event_available, color: Colors.teal),
                          title: Text(_monthLabel(DateTime(c.year, c.month))),
                          trailing: Text(
                            Formatters.formatRupiah(c.netProfit),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: c.netProfit >= 0 ? Colors.green.shade800 : Colors.red,
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _buildOwnerCard(OwnerModel o) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: const Icon(Icons.person, color: Colors.teal),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${o.name} (${(o.sharePercentage * 100).toStringAsFixed(0)}%)",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: "Edit Owner",
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openEditOwnerDialog(o),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 6,
              children: [
                _statColumn("Saldo Belum Ditarik", o.availableBalance, Colors.green.shade800),
                _statColumn("Sudah Ditarik", o.totalWithdrawn, Colors.grey.shade700),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: o.availableBalance <= 0 ? null : () => _openWithdrawDialog(o),
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: const Text("Tarik Uang"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        Text(
          Formatters.formatRupiah(value),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
        ),
      ],
    );
  }

  Widget _buildUnclosedMonthCard(DateTime m) {
    final profit = _unclosedMonthPreview[_monthKey(m)] ?? 0.0;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.amber.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                Text(_monthLabel(m), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "Estimasi laba: ${Formatters.formatRupiah(profit)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: profit >= 0 ? Colors.green.shade800 : Colors.red,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => _confirmCloseMonth(m),
              icon: const Icon(Icons.lock_clock_outlined, size: 16),
              label: const Text("Tutup & Bagikan"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalTile(OwnerWithdrawalModel w) {
    final ownerName = _ownerNames[w.ownerId] ?? "Owner #${w.ownerId}";
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.arrow_circle_up, color: Colors.red),
        title: Text(
          "$ownerName • ${Formatters.formatRupiah(w.amount)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          w.note.isEmpty
              ? Formatters.formatDate(w.date)
              : "${Formatters.formatDate(w.date)} • ${w.note}",
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
          tooltip: "Hapus Catatan",
          visualDensity: VisualDensity.compact,
          onPressed: () => _confirmDeleteWithdrawal(w),
        ),
      ),
    );
  }
}
