import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../repositories/sales_repository.dart';

class CreateSaleTransaction {
  final ISalesRepository repository;

  CreateSaleTransaction(this.repository);

  Future<Either<Failure, SaleTransactionModel>> execute({
    required SaleTransactionModel transaction,
    required List<SaleItemModel> items,
  }) async {
    // Basic Validation
    if (items.isEmpty) {
      return const Left(
        ValidationFailure("Transaksi harus memiliki minimal 1 item sparepart."),
      );
    }
    if (transaction.grandTotal <= 0) {
      return const Left(
        ValidationFailure("Grand total transaksi tidak valid."),
      );
    }

    return await repository.createSaleTransaction(
      transaction: transaction,
      items: items,
    );
  }
}
