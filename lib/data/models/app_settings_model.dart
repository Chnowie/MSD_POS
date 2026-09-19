import 'package:isar/isar.dart';

part 'app_settings_model.g.dart';

/// Pengaturan aplikasi tersimpan lokal (Isar). Cuma ada SATU baris (id tetap)
/// karena ini bukan koleksi data berulang, cuma preferensi aplikasi.
@collection
class AppSettingsModel {
  Id id = Isar.autoIncrement;

  /// 'system' | 'light' | 'dark'
  String themeMode;

  AppSettingsModel({
    this.id = Isar.autoIncrement,
    this.themeMode = 'system',
  });
}
