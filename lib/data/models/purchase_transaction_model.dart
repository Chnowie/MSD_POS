import 'package:isar/isar.dart';

part 'purchase_transaction_model.g.dart';

@collection
class PurchaseTransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String poNumber; // Contoh: PO-20260828-001

  @Index()
  int supplierId;

  @Index()
  DateTime date;

  @Index()
  String paymentStatus; // 'LUNAS' / 'HUTANG'

  double grandTotal;
  double paidAmount;
  double remainingPayable;
  DateTime? dueDate;

  @Index()
  bool isSynced;

  PurchaseTransactionModel({
    this.id = Isar.autoIncrement,
    required this.poNumber,
    required this.supplierId,
    required this.date,
    required this.paymentStatus,
    required this.grandTotal,
    required this.paidAmount,
    required this.remainingPayable,
    this.dueDate,
    this.isSynced = false,
  });
}
