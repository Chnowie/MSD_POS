import 'package:isar/isar.dart';

part 'stock_movement_log_model.g.dart';

@collection
class StockMovementLogModel {
  Id id = Isar.autoIncrement;

  @Index()
  int itemId;

  /// Perubahan jumlah stok (Negatif untuk Penjualan, Positif untuk Pembelian/Opname)
  int changeQty;

  String movementType; // 'SALE', 'PURCHASE', 'ADJUSTMENT'
  String referenceNumber; // Nomor Invoice / PO

  @Index()
  DateTime timestamp;

  @Index()
  bool isSynced;

  StockMovementLogModel({
    this.id = Isar.autoIncrement,
    required this.itemId,
    required this.changeQty,
    required this.movementType,
    required this.referenceNumber,
    required this.timestamp,
    this.isSynced = false,
  });
}
