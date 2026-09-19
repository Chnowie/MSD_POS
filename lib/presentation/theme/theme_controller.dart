import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../../data/models/app_settings_model.dart';

/// Menyimpan & mengganti mode tema aplikasi (Terang/Gelap/Ikuti Sistem),
/// dipersist ke Isar supaya pilihan pengguna tetap tersimpan setelah
/// aplikasi ditutup dan dibuka lagi.
class ThemeController extends ValueNotifier<ThemeMode> {
  final Isar isar;

  ThemeController(this.isar, ThemeMode initial) : super(initial);

  static Future<ThemeMode> loadInitial(Isar isar) async {
    final settings = await isar.appSettingsModels.where().findFirst();
    return _parseThemeMode(settings?.themeMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    await isar.writeTxn(() async {
      final settings = await isar.appSettingsModels.where().findFirst();
      final modeStr = _themeModeToString(mode);
      if (settings != null) {
        settings.themeMode = modeStr;
        await isar.appSettingsModels.put(settings);
      } else {
        await isar.appSettingsModels.put(AppSettingsModel(themeMode: modeStr));
      }
    });
  }

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
