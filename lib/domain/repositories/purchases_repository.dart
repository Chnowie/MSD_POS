import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../data/models/purchase_item_model.dart';
import '../../data/models/purchase_transaction_model.dart';

abstract class IPurchasesRepository {
  Future<Either<Failure, PurchaseTransactionModel>> createPurchaseTransaction({
    required PurchaseTransactionModel transaction,
    required List<PurchaseItemModel> items,
  });

  Future<Either<Failure, void>> paySupplierDebt({
    required int purchaseTransactionId,
    required double paymentAmount,
  });
}
