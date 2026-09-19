import 'package:isar/isar.dart';

part 'sale_item_model.g.dart';

@collection
class SaleItemModel {
  Id id = Isar.autoIncrement;

  @Index()
  int saleTransactionId;

  @Index()
  int itemId;

  int qty;
  double price;
  double subtotal;

  SaleItemModel({
    this.id = Isar.autoIncrement,
    required this.saleTransactionId,
    required this.itemId,
    required this.qty,
    required this.price,
    required this.subtotal,
  });
}
