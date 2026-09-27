import 'package:isar/isar.dart';

part 'audit_log_model.g.dart';

/// Jejak aktivitas untuk aksi-aksi sensitif (hapus data, ubah status
/// pembayaran, penarikan owner, tutup bulan, dll) — mencatat siapa
/// melakukan apa dan kapan, untuk akuntabilitas.
@collection
class AuditLogModel {
  Id id = Isar.autoIncrement;

  /// UUID stabil lintas-device, dipakai sebagai kunci unik saat sinkronisasi.
  @Index(unique: true)
  String uuid;

  @Index()
  String username;

  String role;

  /// Kode singkat jenis aksi, contoh: "DELETE_SALE", "CHANGE_SALE_STATUS".
  @Index()
  String action;

  /// Deskripsi lengkap & mudah dibaca untuk ditampilkan di layar Log Aktivitas.
  String description;

  @Index()
  DateTime timestamp;

  @Index()
  bool isSynced;

  AuditLogModel({
    this.id = Isar.autoIncrement,
    required this.uuid,
    required this.username,
    required this.role,
    required this.action,
    required this.description,
    required this.timestamp,
    this.isSynced = false,
  });
}
