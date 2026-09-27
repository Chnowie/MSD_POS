import 'package:isar/isar.dart';

import '../models/app_settings_model.dart';
import '../models/audit_log_model.dart';
import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/monthly_profit_close_model.dart';
import '../models/owner_model.dart';
import '../models/owner_withdrawal_model.dart';
import '../models/purchase_item_model.dart';
import '../models/purchase_transaction_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_transaction_model.dart';
import '../models/stock_movement_log_model.dart';
import '../models/supplier_model.dart';
import '../models/user_model.dart';

/// Format versi struktur file backup. Naikkan kalau format berubah besar
/// di masa depan, supaya proses restore bisa menyesuaikan / menolak file lama.
const int kBackupFormatVersion = 1;

/// Export & import SELURUH database Isar lokal ke/dari satu file JSON,
/// sebagai jaring pengaman tambahan di luar sinkronisasi Supabase (mis.
/// kalau HP hilang/rusak sebelum sempat sync, atau mau pindah device).
class BackupService {
  final Isar isar;

  BackupService(this.isar);

  Future<Map<String, dynamic>> exportAll() async {
    return {
      'formatVersion': kBackupFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'users': (await isar.userModels.where().findAll()).map(_userToMap).toList(),
      'items': (await isar.itemModels.where().findAll()).map(_itemToMap).toList(),
      'categories': (await isar.categoryModels.where().findAll()).map(_categoryToMap).toList(),
      'customers': (await isar.customerModels.where().findAll()).map(_customerToMap).toList(),
      'suppliers': (await isar.supplierModels.where().findAll()).map(_supplierToMap).toList(),
      'saleTransactions':
          (await isar.saleTransactionModels.where().findAll()).map(_saleTxToMap).toList(),
      'saleItems': (await isar.saleItemModels.where().findAll()).map(_saleItemToMap).toList(),
      'purchaseTransactions':
          (await isar.purchaseTransactionModels.where().findAll()).map(_purchaseTxToMap).toList(),
      'purchaseItems':
          (await isar.purchaseItemModels.where().findAll()).map(_purchaseItemToMap).toList(),
      'stockMovementLogs':
          (await isar.stockMovementLogModels.where().findAll()).map(_stockLogToMap).toList(),
      'appSettings':
          (await isar.appSettingsModels.where().findAll()).map(_appSettingsToMap).toList(),
      'owners': (await isar.ownerModels.where().findAll()).map(_ownerToMap).toList(),
      'monthlyProfitCloses':
          (await isar.monthlyProfitCloseModels.where().findAll()).map(_monthlyCloseToMap).toList(),
      'ownerWithdrawals':
          (await isar.ownerWithdrawalModels.where().findAll()).map(_withdrawalToMap).toList(),
      'auditLogs': (await isar.auditLogModels.where().findAll()).map(_auditLogToMap).toList(),
    };
  }

  /// Kembalikan seluruh isi data dari [data] hasil parse file backup.
  /// PERINGATAN: ini MENIMPA/MENGGANTI seluruh data lokal saat ini —
  /// konfirmasi ke pengguna harus dilakukan SEBELUM memanggil ini.
  Future<void> restoreAll(Map<String, dynamic> data) async {
    await isar.writeTxn(() async {
      // Bersihkan semua koleksi dulu
      await isar.userModels.clear();
      await isar.itemModels.clear();
      await isar.categoryModels.clear();
      await isar.customerModels.clear();
      await isar.supplierModels.clear();
      await isar.saleTransactionModels.clear();
      await isar.saleItemModels.clear();
      await isar.purchaseTransactionModels.clear();
      await isar.purchaseItemModels.clear();
      await isar.stockMovementLogModels.clear();
      await isar.appSettingsModels.clear();
      await isar.ownerModels.clear();
      await isar.monthlyProfitCloseModels.clear();
      await isar.ownerWithdrawalModels.clear();
      await isar.auditLogModels.clear();

      // Isi ulang dari backup — pakai ID yang sama persis dari backup supaya
      // semua relasi (customerId, itemId, dst.) tetap valid.
      await isar.userModels.putAll(_listFrom(data['users'], _userFromMap));
      await isar.itemModels.putAll(_listFrom(data['items'], _itemFromMap));
      await isar.categoryModels.putAll(_listFrom(data['categories'], _categoryFromMap));
      await isar.customerModels.putAll(_listFrom(data['customers'], _customerFromMap));
      await isar.supplierModels.putAll(_listFrom(data['suppliers'], _supplierFromMap));
      await isar.saleTransactionModels
          .putAll(_listFrom(data['saleTransactions'], _saleTxFromMap));
      await isar.saleItemModels.putAll(_listFrom(data['saleItems'], _saleItemFromMap));
      await isar.purchaseTransactionModels
          .putAll(_listFrom(data['purchaseTransactions'], _purchaseTxFromMap));
      await isar.purchaseItemModels
          .putAll(_listFrom(data['purchaseItems'], _purchaseItemFromMap));
      await isar.stockMovementLogModels
          .putAll(_listFrom(data['stockMovementLogs'], _stockLogFromMap));
      await isar.appSettingsModels.putAll(_listFrom(data['appSettings'], _appSettingsFromMap));
      await isar.ownerModels.putAll(_listFrom(data['owners'], _ownerFromMap));
      await isar.monthlyProfitCloseModels
          .putAll(_listFrom(data['monthlyProfitCloses'], _monthlyCloseFromMap));
      await isar.ownerWithdrawalModels
          .putAll(_listFrom(data['ownerWithdrawals'], _withdrawalFromMap));
      await isar.auditLogModels.putAll(_listFrom(data['auditLogs'], _auditLogFromMap));
    });
  }

  static List<T> _listFrom<T>(dynamic raw, T Function(Map<String, dynamic>) fromMap) {
    if (raw is! List) return <T>[];
    return raw.map((e) => fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  // ---------------------------------------------------------------------------
  // USERS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _userToMap(UserModel u) => {
        'id': u.id,
        'uuid': u.uuid,
        'username': u.username,
        'email': u.email,
        'role': u.role,
        'passwordHash': u.passwordHash,
        'lastLogin': u.lastLogin.toIso8601String(),
        'isSynced': u.isSynced,
      };

  static UserModel _userFromMap(Map<String, dynamic> m) => UserModel(
        uuid: m['uuid'] as String,
        username: m['username'] as String,
        email: m['email'] as String,
        role: m['role'] as String,
        passwordHash: m['passwordHash'] as String?,
        lastLogin: DateTime.parse(m['lastLogin'] as String),
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // ITEMS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _itemToMap(ItemModel i) => {
        'id': i.id,
        'partNumber': i.partNumber,
        'name': i.name,
        'category': i.category,
        'buyPrice': i.buyPrice,
        'sellPrice': i.sellPrice,
        'minStock': i.minStock,
        'currentStock': i.currentStock,
        'isSynced': i.isSynced,
      };

  static ItemModel _itemFromMap(Map<String, dynamic> m) => ItemModel(
        partNumber: m['partNumber'] as String,
        name: m['name'] as String,
        category: m['category'] as String,
        buyPrice: (m['buyPrice'] as num).toDouble(),
        sellPrice: (m['sellPrice'] as num).toDouble(),
        minStock: m['minStock'] as int,
        currentStock: m['currentStock'] as int,
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // CATEGORIES
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _categoryToMap(CategoryModel c) => {
        'id': c.id,
        'name': c.name,
        'code': c.code,
        'lastSequence': c.lastSequence,
      };

  static CategoryModel _categoryFromMap(Map<String, dynamic> m) => CategoryModel(
        name: m['name'] as String,
        code: m['code'] as String,
        lastSequence: m['lastSequence'] as int? ?? 0,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // CUSTOMERS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _customerToMap(CustomerModel c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'address': c.address,
        'totalDebt': c.totalDebt,
      };

  static CustomerModel _customerFromMap(Map<String, dynamic> m) => CustomerModel(
        name: m['name'] as String,
        phone: m['phone'] as String,
        address: m['address'] as String,
        totalDebt: (m['totalDebt'] as num?)?.toDouble() ?? 0.0,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // SUPPLIERS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _supplierToMap(SupplierModel s) => {
        'id': s.id,
        'name': s.name,
        'phone': s.phone,
        'address': s.address,
        'totalPayable': s.totalPayable,
      };

  static SupplierModel _supplierFromMap(Map<String, dynamic> m) => SupplierModel(
        name: m['name'] as String,
        phone: m['phone'] as String,
        address: m['address'] as String,
        totalPayable: (m['totalPayable'] as num?)?.toDouble() ?? 0.0,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // SALE TRANSACTIONS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _saleTxToMap(SaleTransactionModel s) => {
        'id': s.id,
        'invoiceNumber': s.invoiceNumber,
        'customerId': s.customerId,
        'date': s.date.toIso8601String(),
        'paymentStatus': s.paymentStatus,
        'grandTotal': s.grandTotal,
        'paidAmount': s.paidAmount,
        'remainingDebt': s.remainingDebt,
        'dueDate': s.dueDate?.toIso8601String(),
        'isSynced': s.isSynced,
      };

  static SaleTransactionModel _saleTxFromMap(Map<String, dynamic> m) => SaleTransactionModel(
        invoiceNumber: m['invoiceNumber'] as String,
        customerId: m['customerId'] as int,
        date: DateTime.parse(m['date'] as String),
        paymentStatus: m['paymentStatus'] as String,
        grandTotal: (m['grandTotal'] as num).toDouble(),
        paidAmount: (m['paidAmount'] as num).toDouble(),
        remainingDebt: (m['remainingDebt'] as num).toDouble(),
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate'] as String) : null,
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // SALE ITEMS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _saleItemToMap(SaleItemModel s) => {
        'id': s.id,
        'saleTransactionId': s.saleTransactionId,
        'itemId': s.itemId,
        'qty': s.qty,
        'price': s.price,
        'subtotal': s.subtotal,
      };

  static SaleItemModel _saleItemFromMap(Map<String, dynamic> m) => SaleItemModel(
        saleTransactionId: m['saleTransactionId'] as int,
        itemId: m['itemId'] as int,
        qty: m['qty'] as int,
        price: (m['price'] as num).toDouble(),
        subtotal: (m['subtotal'] as num).toDouble(),
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // PURCHASE TRANSACTIONS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _purchaseTxToMap(PurchaseTransactionModel p) => {
        'id': p.id,
        'poNumber': p.poNumber,
        'supplierId': p.supplierId,
        'date': p.date.toIso8601String(),
        'paymentStatus': p.paymentStatus,
        'grandTotal': p.grandTotal,
        'paidAmount': p.paidAmount,
        'remainingPayable': p.remainingPayable,
        'dueDate': p.dueDate?.toIso8601String(),
        'isSynced': p.isSynced,
      };

  static PurchaseTransactionModel _purchaseTxFromMap(Map<String, dynamic> m) =>
      PurchaseTransactionModel(
        poNumber: m['poNumber'] as String,
        supplierId: m['supplierId'] as int,
        date: DateTime.parse(m['date'] as String),
        paymentStatus: m['paymentStatus'] as String,
        grandTotal: (m['grandTotal'] as num).toDouble(),
        paidAmount: (m['paidAmount'] as num).toDouble(),
        remainingPayable: (m['remainingPayable'] as num).toDouble(),
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate'] as String) : null,
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // PURCHASE ITEMS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _purchaseItemToMap(PurchaseItemModel p) => {
        'id': p.id,
        'purchaseTransactionId': p.purchaseTransactionId,
        'itemId': p.itemId,
        'qty': p.qty,
        'price': p.price,
        'subtotal': p.subtotal,
      };

  static PurchaseItemModel _purchaseItemFromMap(Map<String, dynamic> m) => PurchaseItemModel(
        purchaseTransactionId: m['purchaseTransactionId'] as int,
        itemId: m['itemId'] as int,
        qty: m['qty'] as int,
        price: (m['price'] as num).toDouble(),
        subtotal: (m['subtotal'] as num).toDouble(),
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // STOCK MOVEMENT LOGS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _stockLogToMap(StockMovementLogModel s) => {
        'id': s.id,
        'itemId': s.itemId,
        'changeQty': s.changeQty,
        'movementType': s.movementType,
        'referenceNumber': s.referenceNumber,
        'timestamp': s.timestamp.toIso8601String(),
        'isSynced': s.isSynced,
      };

  static StockMovementLogModel _stockLogFromMap(Map<String, dynamic> m) =>
      StockMovementLogModel(
        itemId: m['itemId'] as int,
        changeQty: m['changeQty'] as int,
        movementType: m['movementType'] as String,
        referenceNumber: m['referenceNumber'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // APP SETTINGS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _appSettingsToMap(AppSettingsModel a) => {
        'id': a.id,
        'themeMode': a.themeMode,
      };

  static AppSettingsModel _appSettingsFromMap(Map<String, dynamic> m) => AppSettingsModel(
        themeMode: m['themeMode'] as String? ?? 'system',
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // OWNERS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _ownerToMap(OwnerModel o) => {
        'id': o.id,
        'name': o.name,
        'sharePercentage': o.sharePercentage,
        'totalEntitled': o.totalEntitled,
        'totalWithdrawn': o.totalWithdrawn,
      };

  static OwnerModel _ownerFromMap(Map<String, dynamic> m) => OwnerModel(
        name: m['name'] as String,
        sharePercentage: (m['sharePercentage'] as num).toDouble(),
        totalEntitled: (m['totalEntitled'] as num?)?.toDouble() ?? 0.0,
        totalWithdrawn: (m['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // MONTHLY PROFIT CLOSES
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _monthlyCloseToMap(MonthlyProfitCloseModel c) => {
        'id': c.id,
        'monthKey': c.monthKey,
        'year': c.year,
        'month': c.month,
        'netProfit': c.netProfit,
        'closedAt': c.closedAt.toIso8601String(),
        'isSynced': c.isSynced,
      };

  static MonthlyProfitCloseModel _monthlyCloseFromMap(Map<String, dynamic> m) =>
      MonthlyProfitCloseModel(
        monthKey: m['monthKey'] as String,
        year: m['year'] as int,
        month: m['month'] as int,
        netProfit: (m['netProfit'] as num).toDouble(),
        closedAt: DateTime.parse(m['closedAt'] as String),
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // OWNER WITHDRAWALS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _withdrawalToMap(OwnerWithdrawalModel w) => {
        'id': w.id,
        'uuid': w.uuid,
        'ownerId': w.ownerId,
        'amount': w.amount,
        'date': w.date.toIso8601String(),
        'note': w.note,
        'isSynced': w.isSynced,
      };

  static OwnerWithdrawalModel _withdrawalFromMap(Map<String, dynamic> m) =>
      OwnerWithdrawalModel(
        uuid: m['uuid'] as String,
        ownerId: m['ownerId'] as int,
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String? ?? '',
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;

  // ---------------------------------------------------------------------------
  // AUDIT LOGS
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> _auditLogToMap(AuditLogModel a) => {
        'id': a.id,
        'uuid': a.uuid,
        'username': a.username,
        'role': a.role,
        'action': a.action,
        'description': a.description,
        'timestamp': a.timestamp.toIso8601String(),
        'isSynced': a.isSynced,
      };

  static AuditLogModel _auditLogFromMap(Map<String, dynamic> m) => AuditLogModel(
        uuid: m['uuid'] as String,
        username: m['username'] as String,
        role: m['role'] as String,
        action: m['action'] as String,
        description: m['description'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        isSynced: m['isSynced'] as bool? ?? false,
      )..id = m['id'] as int;
}
