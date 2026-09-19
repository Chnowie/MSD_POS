import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/sale_transaction_model.dart';

abstract class ISalesRepository {
  Future<Either<Failure, SaleTransactionModel>> createSaleTransaction({
    required SaleTransactionModel transaction,
    required List<SaleItemModel> items,
  });

  Future<Either<Failure, void>> payCustomerDebt({
    required int saleTransactionId,
    required double paymentAmount,
  });
}
