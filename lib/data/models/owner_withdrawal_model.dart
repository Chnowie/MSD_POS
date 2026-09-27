import 'package:isar/isar.dart';

part 'owner_withdrawal_model.g.dart';

/// Catatan satu kali penarikan uang oleh owner dari saldo laba miliknya.
@collection
class OwnerWithdrawalModel {
  Id id = Isar.autoIncrement;

  /// UUID stabil lintas-device, dipakai sebagai kunci unik saat sinkronisasi
  /// ke Supabase (karena penarikan tidak punya nomor invoice seperti transaksi).
  @Index(unique: true)
  String uuid;

  @Index()
  int ownerId;

  double amount;

  @Index()
  DateTime date;

  String note;

  @Index()
  bool isSynced;

  OwnerWithdrawalModel({
    this.id = Isar.autoIncrement,
    required this.uuid,
    required this.ownerId,
    required this.amount,
    required this.date,
    this.note = '',
    this.isSynced = false,
  });
}
