import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  /// Nama kategori, contoh: "Pengereman", "Oli & Pelumas"
  @Index(unique: true, caseSensitive: false)
  String name;

  /// Kode singkat 2-4 huruf untuk prefix nomor part otomatis, contoh: "REM", "OLI"
  @Index(unique: true, caseSensitive: false)
  String code;

  /// Nomor urut terakhir yang sudah dipakai untuk kategori ini.
  /// Dipakai untuk generate kode barang otomatis: `code` + "-" + `lastSequence + 1`.
  int lastSequence;

  CategoryModel({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.code,
    this.lastSequence = 0,
  });
}
