import 'package:isar/isar.dart';

part 'item_model.g.dart';

@collection
class ItemModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  String partNumber;

  @Index(caseSensitive: false)
  String name;

  @Index()
  String category;

  double buyPrice;
  double sellPrice;
  int minStock;
  int currentStock;

  @Index()
  bool isSynced;

  ItemModel({
    this.id = Isar.autoIncrement,
    required this.partNumber,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.minStock,
    required this.currentStock,
    this.isSynced = false,
  });
}
