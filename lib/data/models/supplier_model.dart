import 'package:isar/isar.dart';

part 'supplier_model.g.dart';

@collection
class SupplierModel {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  String name;

  @Index(unique: true)
  String phone;

  String address;

  double totalPayable;

  SupplierModel({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.phone,
    required this.address,
    this.totalPayable = 0.0,
  });
}
