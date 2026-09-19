import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../data/models/purchase_item_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../repositories/purchases_repository.dart';

class CreatePurchaseTransaction {
  final IPurchasesRepository repository;

  CreatePurchaseTransaction(this.repository);

  Future<Either<Failure, PurchaseTransactionModel>> execute({
    required PurchaseTransactionModel transaction,
    required List<PurchaseItemModel> items,
  }) async {
    // 1. Validasi Daftar Barang
    if (items.isEmpty) {
      return const Left(
        ValidationFailure("Keranjang faktur pembelian tidak boleh kosong."),
      );
    }

    // 2. Validasi Jumlah & Nilai Transaksi
    if (transaction.grandTotal <= 0) {
      return const Left(
        ValidationFailure("Grand total faktur pembelian harus lebih besar dari 0."),
      );
    }

    for (var item in items) {
      if (item.qty <= 0) {
        return const Left(
          ValidationFailure("Jumlah kuantitas item harus lebih dari 0."),
        );
      }
      if (item.price < 0) {
        return const Left(
          ValidationFailure("Harga beli item tidak boleh negatif."),
        );
      }
    }

    // 3. Eksekusi Pembelian
    return await repository.createPurchaseTransaction(
      transaction: transaction,
      items: items,
    );
  }
}
