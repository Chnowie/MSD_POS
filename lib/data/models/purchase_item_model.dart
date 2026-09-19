import 'package:isar/isar.dart';

part 'purchase_item_model.g.dart';

@collection
class PurchaseItemModel {
  Id id = Isar.autoIncrement;

  @Index()
  int purchaseTransactionId;

  @Index()
  int itemId;

  int qty;
  double price;
  double subtotal;

  PurchaseItemModel({
    this.id = Isar.autoIncrement,
    required this.purchaseTransactionId,
    required this.itemId,
    required this.qty,
    required this.price,
    required this.subtotal,
  });
}
