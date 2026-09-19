import 'package:isar/isar.dart';

part 'sale_transaction_model.g.dart';

@collection
class SaleTransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String invoiceNumber;

  @Index()
  int customerId;

  @Index()
  DateTime date;

  @Index()
  String paymentStatus;

  double grandTotal;
  double paidAmount;
  double remainingDebt;
  DateTime? dueDate;

  @Index()
  bool isSynced;

  SaleTransactionModel({
    this.id = Isar.autoIncrement,
    required this.invoiceNumber,
    required this.customerId,
    required this.date,
    required this.paymentStatus,
    required this.grandTotal,
    required this.paidAmount,
    required this.remainingDebt,
    this.dueDate,
    this.isSynced = false,
  });
}
