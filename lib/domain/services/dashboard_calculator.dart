import 'package:isar/isar.dart';

import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../../data/models/supplier_model.dart';

class DashboardSummary {
  final double totalSalesMonth;
  final double totalPurchasesMonth;
  final double totalActivityReceivables;
  final double totalActivityPayables;
  final double totalCashIn;
  final double totalCashOut;
  final double otherExpenses;
  final double netProfitMonth;

  DashboardSummary({
    required this.totalSalesMonth,
    required this.totalPurchasesMonth,
    required this.totalActivityReceivables,
    required this.totalActivityPayables,
    required this.totalCashIn,
    required this.totalCashOut,
    required this.otherExpenses,
    required this.netProfitMonth,
  });
}

class DashboardCalculator {
  final Isar isar;

  DashboardCalculator(this.isar);

  Future<Either<Failure, DashboardSummary>> calculateMonthlySummary({
    DateTime? targetMonth,
    double otherExpenses = 0.0,
  }) async {
    try {
      final now = targetMonth ?? DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final salesMonth = await isar.saleTransactionModels
          .filter()
          .dateBetween(startOfMonth, endOfMonth)
          .findAll();
      final purchaseMonth = await isar.purchaseTransactionModels
          .filter()
          .dateBetween(startOfMonth, endOfMonth)
          .findAll();

      final totalSalesMonth = salesMonth.fold<double>(
        0.0,
        (sum, item) => sum + item.grandTotal,
      );
      final totalPurchasesMonth = purchaseMonth.fold<double>(
        0.0,
        (sum, item) => sum + item.grandTotal,
      );

      final totalCashIn = salesMonth.fold<double>(
        0.0,
        (sum, item) => sum + item.paidAmount,
      );
      final totalCashOut = purchaseMonth.fold<double>(
        0.0,
        (sum, item) => sum + item.paidAmount,
      );

      final allCustomer = await isar.customerModels.where().findAll();
      final totalActiveReceivables = allCustomer.fold<double>(
        0.0,
        (sum, customer) => sum + customer.totalDebt,
      );

      final allSuppliers = await isar.supplierModels.where().findAll();
      final totalActivePayables = allSuppliers.fold<double>(
        0.0,
        (sum, supplier) => sum + supplier.totalPayable,
      );

      final netProfitMonth = totalCashIn - totalCashOut - otherExpenses;

      return Right(
        DashboardSummary(
          totalSalesMonth: totalSalesMonth,
          totalPurchasesMonth: totalPurchasesMonth,
          totalActivityReceivables: totalActiveReceivables,
          totalActivityPayables: totalActivePayables,
          totalCashIn: totalCashIn,
          totalCashOut: totalCashOut,
          otherExpenses: otherExpenses,
          netProfitMonth: netProfitMonth,
        ),
      );
    } catch (e) {
      return Left(
        DatabaseFailure(
          "Gagal menghitung statistik dashboard: ${e.toString()}",
        ),
      );
    }
  }
}
