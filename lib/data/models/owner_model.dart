import 'package:isar/isar.dart';

part 'owner_model.g.dart';

/// Data pemilik toko (owner) beserta porsi kepemilikan (%) dan akumulasi
/// bagian laba yang berhak diterima / sudah ditarik.
@collection
class OwnerModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  String name;

  /// Porsi kepemilikan, dalam desimal (mis. 0.4 = 40%).
  double sharePercentage;

  /// Akumulasi total bagian laba yang sudah "dibekukan" milik owner ini,
  /// bertambah tiap kali sebuah bulan ditutup (netProfit bulan itu * share).
  double totalEntitled;

  /// Akumulasi total uang yang sudah ditarik owner ini.
  double totalWithdrawn;

  OwnerModel({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.sharePercentage,
    this.totalEntitled = 0.0,
    this.totalWithdrawn = 0.0,
  });

  /// Saldo laba yang masih bisa ditarik saat ini.
  double get availableBalance => totalEntitled - totalWithdrawn;
}
