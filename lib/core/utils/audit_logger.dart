import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/audit_log_model.dart';
import '../../data/models/user_model.dart';

/// Helper untuk mencatat jejak aktivitas sensitif (hapus data, ubah status
/// pembayaran, penarikan owner, tutup bulan, dll).
///
/// PENTING: panggil dari DALAM `isar.writeTxn()` yang sedang berjalan untuk
/// aksi yang bersangkutan (bukan membuka transaksi baru sendiri), supaya
/// catatan log tersimpan atomic bersamaan dengan perubahan datanya.
class AuditLogger {
  static Future<void> record(
    Isar isar,
    UserModel user,
    String action,
    String description,
  ) async {
    await isar.auditLogModels.put(
      AuditLogModel(
        uuid: const Uuid().v4(),
        username: user.username,
        role: user.role,
        action: action,
        description: description,
        timestamp: DateTime.now(),
        isSynced: false,
      ),
    );
  }
}
