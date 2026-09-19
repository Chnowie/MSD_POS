import 'package:isar/isar.dart';

import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/sales_repository.dart';
import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_transaction_model.dart';
import '../models/stock_movement_log_model.dart';

class SalesRepositoryImpl implements ISalesRepository {
  final Isar isar;

  SalesRepositoryImpl(this.isar);

  @override
  Future<Either<Failure, SaleTransactionModel>> createSaleTransaction({
    required SaleTransactionModel transaction,
    required List<SaleItemModel> items,
  }) async {
    try {
      // Menjalankan Seluruh Transaksi Bisnis secara ATOMIK dalam isar.writeTxn()
      final resultTransaction = await isar.writeTxn<SaleTransactionModel>(() async {
        // 1. Validasi Stok Seluruh Barang Terlebih Dahulu
        for (var itemInput in items) {
          final item = await isar.itemModels.get(itemInput.itemId);
          if (item == null) {
            throw Exception(
              "Item sparepart dengan ID ${itemInput.itemId} tidak ditemukan.",
            );
          }
          if (item.currentStock < itemInput.qty) {
            throw Exception(
              "Stok tidak mencukupi untuk item '${item.name}' (Sisa: ${item.currentStock}, Dibeli: ${itemInput.qty}).",
            );
          }
        }

        // 2. Hitung Sisa Piutang Transaksi Ini
        final remainingDebt = transaction.grandTotal - transaction.paidAmount;
        transaction.remainingDebt = remainingDebt < 0 ? 0.0 : remainingDebt;
        transaction.isSynced = false; // Flag untuk Sync Supabase nanti

        // 3. Simpan Header Transaksi Penjualan
        final saleId = await isar.saleTransactionModels.put(transaction);
        transaction.id = saleId;

        // 4. Simpan Item Detail Penjualan, Potong Stok, & Catat Movement Log
        for (var itemInput in items) {
          itemInput.saleTransactionId = saleId;
          await isar.saleItemModels.put(itemInput);

          // Update Stok Item
          final item = (await isar.itemModels.get(itemInput.itemId))!;
          item.currentStock -= itemInput.qty;
          item.isSynced = false;
          await isar.itemModels.put(item);

          // Buat Log Pergerakan Stok (StockMovementLog)
          final stockLog = StockMovementLogModel(
            itemId: item.id,
            changeQty: -itemInput.qty, // Minus karena pengurangan penjualan
            movementType: 'SALE',
            referenceNumber: transaction.invoiceNumber,
            timestamp: transaction.date,
            isSynced: false,
          );
          await isar.stockMovementLogModels.put(stockLog);
        }

        // 5. Logika Pembayaran & Piutang Customer
        if (transaction.paymentStatus == 'HUTANG' && remainingDebt > 0) {
          final customer = await isar.customerModels.get(
            transaction.customerId,
          );
          if (customer != null) {
            customer.totalDebt += remainingDebt;
            await isar.customerModels.put(customer);
          }
        }

        return transaction;
      });

      return Right(resultTransaction);
    } catch (e) {
      if (e.toString().contains("Stok tidak mencukupi")) {
        return Left(
          StockInsufficientFailure(e.toString().replaceAll("Exception: ", "")),
        );
      }
      return Left(
        DatabaseFailure("Gagal memproses transaksi penjualan: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> payCustomerDebt({
    required int saleTransactionId,
    required double paymentAmount,
  }) async {
    try {
      await isar.writeTxn(() async {
        final tx = await isar.saleTransactionModels.get(saleTransactionId);
        if (tx == null) {
          throw Exception("Transaksi penjualan tidak ditemukan.");
        }

        final actualPayment = paymentAmount > tx.remainingDebt
            ? tx.remainingDebt
            : paymentAmount;

        tx.paidAmount += actualPayment;
        tx.remainingDebt -= actualPayment;
        if (tx.remainingDebt <= 0.001) {
          tx.remainingDebt = 0.0;
          tx.paymentStatus = 'LUNAS';
        }
        tx.isSynced = false;
        await isar.saleTransactionModels.put(tx);

        // Update Customer Total Debt
        final customer = await isar.customerModels.get(tx.customerId);
        if (customer != null) {
          customer.totalDebt -= actualPayment;
          if (customer.totalDebt < 0.001) {
            customer.totalDebt = 0.0;
          }
          await isar.customerModels.put(customer);
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure("Gagal mencatat pembayaran piutang: ${e.toString()}"));
    }
  }
}

