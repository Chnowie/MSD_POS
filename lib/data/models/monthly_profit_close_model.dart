import 'package:isar/isar.dart';

part 'monthly_profit_close_model.g.dart';

/// Snapshot laba bersih satu bulan yang sudah "ditutup" (dibekukan).
/// Setelah ditutup, angka netProfit di sini TIDAK berubah lagi walau ada
/// transaksi lama yang diedit/dihapus setelahnya — supaya pembagian ke
/// owner tetap konsisten dengan apa yang sudah dibagikan.
@collection
class MonthlyProfitCloseModel {
  Id id = Isar.autoIncrement;

  /// Format "YYYY-MM", contoh "2026-08". Unik per bulan.
  @Index(unique: true)
  String monthKey;

  int year;
  int month; // 1-12

  /// Laba bersih bulan ini yang dibekukan: (penjualan diterima) -
  /// (total pembelian bulan ini, baik yang sudah dibayar maupun hutang).
  double netProfit;

  DateTime closedAt;

  @Index()
  bool isSynced;

  MonthlyProfitCloseModel({
    this.id = Isar.autoIncrement,
    required this.monthKey,
    required this.year,
    required this.month,
    required this.netProfit,
    required this.closedAt,
    this.isSynced = false,
  });
}
