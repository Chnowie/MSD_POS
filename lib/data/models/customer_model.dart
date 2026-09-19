import 'package:isar/isar.dart';

part 'customer_model.g.dart';

@collection
class CustomerModel {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  String name;

  @Index(unique: true)
  String phone;

  String address;

  double totalDebt;

  CustomerModel({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.phone,
    required this.address,
    this.totalDebt = 0.0,
  });
}
