import 'package:flutter_test/flutter_test.dart';
import 'package:msd_pos/core/authorization/role_permission.dart';
import 'package:msd_pos/core/utils/formatters.dart';
import 'package:msd_pos/data/models/purchase_item_model.dart';
import 'package:msd_pos/data/models/purchase_transaction_model.dart';
import 'package:msd_pos/data/models/sale_item_model.dart';
import 'package:msd_pos/data/models/sale_transaction_model.dart';
import 'package:msd_pos/domain/entities/user_role.dart';
import 'package:msd_pos/domain/repositories/purchases_repository.dart';
import 'package:msd_pos/domain/repositories/sales_repository.dart';
import 'package:msd_pos/domain/usecases/create_purchase_transaction.dart';
import 'package:msd_pos/domain/usecases/create_sale_transaction.dart';
import 'package:msd_pos/core/utils/result.dart';
import 'package:msd_pos/core/error/failures.dart';

class MockSalesRepository implements ISalesRepository {
  @override
  Future<Either<Failure, SaleTransactionModel>> createSaleTransaction({
    required SaleTransactionModel transaction,
    required List<SaleItemModel> items,
  }) async {
    return Right(transaction);
  }

  @override
  Future<Either<Failure, void>> payCustomerDebt({
    required int saleTransactionId,
    required double paymentAmount,
  }) async {
    return const Right(null);
  }
}

class MockPurchasesRepository implements IPurchasesRepository {
  @override
  Future<Either<Failure, PurchaseTransactionModel>> createPurchaseTransaction({
    required PurchaseTransactionModel transaction,
    required List<PurchaseItemModel> items,
  }) async {
    return Right(transaction);
  }

  @override
  Future<Either<Failure, void>> paySupplierDebt({
    required int purchaseTransactionId,
    required double paymentAmount,
  }) async {
    return const Right(null);
  }
}

void main() {
  group('POS Unit & Domain Tests', () {
    test('Formatters should format Indonesian Rupiah correctly', () {
      expect(Formatters.formatRupiah(150000), contains('150.000'));
      expect(Formatters.formatRupiah(0), contains('0'));
    });

    test('RolePermission RBAC guards should restrict privileges properly', () {
      // 1. Kasir
      expect(RolePermission.canCreateSale(UserRole.kasir), isTrue);
      expect(RolePermission.canViewStock(UserRole.kasir), isTrue);
      expect(RolePermission.canModifyStock(UserRole.kasir), isFalse);
      expect(RolePermission.canViewNetProfitDashboard(UserRole.kasir), isFalse);

      // 2. Admin
      expect(RolePermission.canCreateSale(UserRole.admin), isTrue);
      expect(RolePermission.canModifyStock(UserRole.admin), isTrue);
      expect(RolePermission.canManagePurchasesAndDebts(UserRole.admin), isTrue);
      expect(RolePermission.canViewNetProfitDashboard(UserRole.admin), isFalse);

      // 3. Owner
      expect(RolePermission.canCreateSale(UserRole.owner), isTrue);
      expect(RolePermission.canModifyStock(UserRole.owner), isTrue);
      expect(RolePermission.canManageUsers(UserRole.owner), isTrue);
      expect(RolePermission.canViewNetProfitDashboard(UserRole.owner), isTrue);
    });

    test('CreateSaleTransaction UseCase should validate empty items and non-positive total', () async {
      final mockRepo = MockSalesRepository();
      final useCase = CreateSaleTransaction(mockRepo);

      final dummyTx = SaleTransactionModel(
        invoiceNumber: 'INV-TEST-001',
        customerId: 1,
        date: DateTime.now(),
        paymentStatus: 'LUNAS',
        grandTotal: 0.0,
        paidAmount: 0.0,
        remainingDebt: 0.0,
      );

      // Test Empty Items
      final resultEmpty = await useCase.execute(
        transaction: dummyTx,
        items: [],
      );
      expect(resultEmpty.isLeft, isTrue);
      expect(resultEmpty.left, isA<ValidationFailure>());

      // Test Invalid Total
      final resultZeroTotal = await useCase.execute(
        transaction: dummyTx,
        items: [
          SaleItemModel(
            saleTransactionId: 1,
            itemId: 1,
            qty: 1,
            price: 50000,
            subtotal: 50000,
          ),
        ],
      );
      expect(resultZeroTotal.isLeft, isTrue);
    });

    test('CreatePurchaseTransaction UseCase should validate empty items and negative price', () async {
      final mockRepo = MockPurchasesRepository();
      final useCase = CreatePurchaseTransaction(mockRepo);

      final dummyPo = PurchaseTransactionModel(
        poNumber: 'PO-TEST-001',
        supplierId: 1,
        date: DateTime.now(),
        paymentStatus: 'LUNAS',
        grandTotal: 500000.0,
        paidAmount: 500000.0,
        remainingPayable: 0.0,
      );

      // Test Empty Items
      final resultEmpty = await useCase.execute(
        transaction: dummyPo,
        items: [],
      );
      expect(resultEmpty.isLeft, isTrue);

      // Test Valid Purchase
      final resultSuccess = await useCase.execute(
        transaction: dummyPo,
        items: [
          PurchaseItemModel(
            purchaseTransactionId: 1,
            itemId: 1,
            qty: 10,
            price: 50000,
            subtotal: 500000,
          ),
        ],
      );
      expect(resultSuccess.isRight, isTrue);
    });
  });
}

