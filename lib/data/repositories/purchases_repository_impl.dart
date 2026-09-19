import 'package:isar/isar.dart';

import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/purchases_repository.dart';
import '../models/item_model.dart';
import '../models/purchase_item_model.dart';
import '../models/purchase_transaction_model.dart';
import '../models/stock_movement_log_model.dart';
import '../models/supplier_model.dart';

class PurchasesRepositoryImpl implements IPurchasesRepository {
  final Isar isar;

  PurchasesRepositoryImpl(this.isar);

  @override
  Future<Either<Failure, PurchaseTransactionModel>> createPurchaseTransaction({
    required PurchaseTransactionModel transaction,
    required List<PurchaseItemModel> items,
  }) async {
    try {
      final resultTransaction = await isar.writeTxn<PurchaseTransactionModel>(() async {
        // 1. Validasi Supplier
        final supplier = await isar.supplierModels.get(transaction.supplierId);
        if (supplier == null) {
          throw Exception("Supplier dengan ID ${transaction.supplierId} tidak ditemukan.");
        }

        // 2. Hitung Sisa Hutang Transaksi Ini
        final remainingPayable = transaction.grandTotal - transaction.paidAmount;
        transaction.remainingPayable = remainingPayable < 0 ? 0.0 : remainingPayable;
        transaction.isSynced = false;

        // 3. Simpan Header Transaksi Pembelian
        final purchaseId = await isar.purchaseTransactionModels.put(transaction);
        transaction.id = purchaseId;

        // 4. Simpan Item Detail Pembelian, Tambah Stok & Catat Log
        for (var itemInput in items) {
          itemInput.purchaseTransactionId = purchaseId;
          await isar.purchaseItemModels.put(itemInput);

          // Update Stok Item (Bertambah)
          final item = await isar.itemModels.get(itemInput.itemId);
          if (item != null) {
            item.currentStock += itemInput.qty;
            // Update harga beli jika berbeda (opsional memperbarui referensi harga beli terbaru)
            if (itemInput.price > 0) {
              item.buyPrice = itemInput.price;
            }
            item.isSynced = false;
            await isar.itemModels.put(item);

            // Buat Log Pergerakan Stok (StockMovementLog)
            final stockLog = StockMovementLogModel(
              itemId: item.id,
              changeQty: itemInput.qty, // Positif karena penambahan stok masuk
              movementType: 'PURCHASE',
              referenceNumber: transaction.poNumber,
              timestamp: transaction.date,
              isSynced: false,
            );
            await isar.stockMovementLogModels.put(stockLog);
          }
        }

        // 5. Update Saldo Hutang Supplier
        if (transaction.paymentStatus == 'HUTANG' && remainingPayable > 0) {
          supplier.totalPayable += remainingPayable;
          await isar.supplierModels.put(supplier);
        }

        return transaction;
      });

      return Right(resultTransaction);
    } catch (e) {
      return Left(
        DatabaseFailure("Gagal memproses transaksi pembelian: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> paySupplierDebt({
    required int purchaseTransactionId,
    required double paymentAmount,
  }) async {
    try {
      await isar.writeTxn(() async {
        final po = await isar.purchaseTransactionModels.get(purchaseTransactionId);
        if (po == null) {
          throw Exception("Transaksi faktur PO tidak ditemukan.");
        }

        final actualPayment = paymentAmount > po.remainingPayable
            ? po.remainingPayable
            : paymentAmount;

        po.paidAmount += actualPayment;
        po.remainingPayable -= actualPayment;
        if (po.remainingPayable <= 0.001) {
          po.remainingPayable = 0.0;
          po.paymentStatus = 'LUNAS';
        }
        po.isSynced = false;
        await isar.purchaseTransactionModels.put(po);

        // Update Supplier Total Payable
        final supplier = await isar.supplierModels.get(po.supplierId);
        if (supplier != null) {
          supplier.totalPayable -= actualPayment;
          if (supplier.totalPayable < 0.001) {
            supplier.totalPayable = 0.0;
          }
          await isar.supplierModels.put(supplier);
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure("Gagal mencatat pembayaran hutang: ${e.toString()}"));
    }
  }
}
