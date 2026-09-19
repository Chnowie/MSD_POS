import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/purchase_item_model.dart';
import '../models/purchase_transaction_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_transaction_model.dart';
import '../models/stock_movement_log_model.dart';
import '../models/supplier_model.dart';

class SyncResult {
  final bool isSuccess;
  final String message;
  final int pushedCount;
  final int pulledCount;
  final List<String> errors;

  SyncResult({
    required this.isSuccess,
    required this.message,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.errors = const [],
  });
}

class SyncService {
  final Isar isar;
  final SupabaseClient supabaseClient;

  final ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);
  final ValueNotifier<DateTime?> lastSyncTime = ValueNotifier<DateTime?>(null);
  final ValueNotifier<int> pendingSyncCount = ValueNotifier<int>(0);

  StreamSubscription? _itemSub;
  StreamSubscription? _saleSub;
  StreamSubscription? _purchaseSub;
  StreamSubscription? _stockSub;

  SyncService({required this.isar, required this.supabaseClient}) {
    _listenToPendingChanges();
    updatePendingCount();
  }

  void dispose() {
    _itemSub?.cancel();
    _saleSub?.cancel();
    _purchaseSub?.cancel();
    _stockSub?.cancel();
    isSyncing.dispose();
    lastSyncTime.dispose();
    pendingSyncCount.dispose();
  }

  bool get isSupabaseConfigured {
    try {
      final url = supabaseClient.rest.url.toString();
      return !url.contains('placeholder.supabase.co') &&
          !url.contains('YOUR_SUPABASE_PROJECT_ID');
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _listenToPendingChanges() {
    _itemSub = isar.itemModels.watchLazy().listen((_) => updatePendingCount());
    _saleSub = isar.saleTransactionModels.watchLazy().listen((_) => updatePendingCount());
    _purchaseSub = isar.purchaseTransactionModels.watchLazy().listen((_) => updatePendingCount());
    _stockSub = isar.stockMovementLogModels.watchLazy().listen((_) => updatePendingCount());
  }

  Future<void> updatePendingCount() async {
    try {
      final unSyncedItems = await isar.itemModels.filter().isSyncedEqualTo(false).count();
      final unSyncedSales = await isar.saleTransactionModels.filter().isSyncedEqualTo(false).count();
      final unSyncedPurchases = await isar.purchaseTransactionModels.filter().isSyncedEqualTo(false).count();
      final unSyncedLogs = await isar.stockMovementLogModels.filter().isSyncedEqualTo(false).count();
      pendingSyncCount.value = unSyncedItems + unSyncedSales + unSyncedPurchases + unSyncedLogs;
    } catch (e) {
      debugPrint("Error calculating pending sync count: $e");
    }
  }

  /// Menandai SEMUA data lokal sebagai belum tersinkron (isSynced = false),
  /// lalu langsung menjalankan syncAll() untuk mengunggah ulang seluruh database ke Supabase.
  Future<SyncResult> forceResyncAll() async {
    try {
      await isar.writeTxn(() async {
        final items = await isar.itemModels.where().findAll();
        for (var item in items) {
          item.isSynced = false;
          await isar.itemModels.put(item);
        }

        final sales = await isar.saleTransactionModels.where().findAll();
        for (var sale in sales) {
          sale.isSynced = false;
          await isar.saleTransactionModels.put(sale);
        }

        final purchases = await isar.purchaseTransactionModels.where().findAll();
        for (var purchase in purchases) {
          purchase.isSynced = false;
          await isar.purchaseTransactionModels.put(purchase);
        }

        final logs = await isar.stockMovementLogModels.where().findAll();
        for (var log in logs) {
          log.isSynced = false;
          await isar.stockMovementLogModels.put(log);
        }
      });

      await updatePendingCount();
      return await syncAll();
    } catch (e) {
      debugPrint("Error during forceResyncAll: $e");
      return SyncResult(
        isSuccess: false,
        message: "Gagal mempersiapkan sinkronisasi ulang: ${e.toString()}",
      );
    }
  }

  /// Sinkronisasi penuh: Push data lokal yang belum tersinkron ke Supabase,
  /// lalu Pull data terbaru dari Supabase ke Isar.
  Future<SyncResult> syncAll() async {
    if (isSyncing.value) {
      return SyncResult(
        isSuccess: false,
        message: "Sinkronisasi sedang berjalan...",
      );
    }

    if (!isSupabaseConfigured) {
      return SyncResult(
        isSuccess: false,
        message: "Supabase belum dikonfigurasi. Mode Offline aktif.",
      );
    }

    final isOnline = await hasInternetConnection();
    if (!isOnline) {
      return SyncResult(
        isSuccess: false,
        message: "Tidak ada koneksi internet. Data tersimpan aman di lokal.",
      );
    }

    isSyncing.value = true;
    int pushed = 0;
    int pulled = 0;
    final List<String> syncErrors = [];

    try {
      // 1. PUSH & PULL ITEMS
      final itemResult = await _syncItems(syncErrors);
      pushed += itemResult['pushed'] ?? 0;
      pulled += itemResult['pulled'] ?? 0;

      // 2. PUSH & PULL CUSTOMERS & SUPPLIERS
      final partnerResult = await _syncPartners(syncErrors);
      pushed += partnerResult['pushed'] ?? 0;
      pulled += partnerResult['pulled'] ?? 0;

      // 3. PUSH SALES & SALE ITEMS
      final saleResult = await _syncSales(syncErrors);
      pushed += saleResult['pushed'] ?? 0;
      pulled += saleResult['pulled'] ?? 0;

      // 4. PUSH PURCHASES & PURCHASE ITEMS
      final purchaseResult = await _syncPurchases(syncErrors);
      pushed += purchaseResult['pushed'] ?? 0;
      pulled += purchaseResult['pulled'] ?? 0;

      // 5. PUSH STOCK MOVEMENT LOGS
      final logResult = await _syncStockLogs(syncErrors);
      pushed += logResult['pushed'] ?? 0;

      lastSyncTime.value = DateTime.now();
      await updatePendingCount();

      if (syncErrors.isNotEmpty && pushed == 0 && pulled == 0) {
        return SyncResult(
          isSuccess: false,
          message: "Sinkronisasi ada kendala: ${syncErrors.first}",
          errors: syncErrors,
        );
      }

      String successMsg = "Sinkronisasi berhasil! ($pushed data diunggah, $pulled data diunduh)";
      if (syncErrors.isNotEmpty) {
        successMsg += " (${syncErrors.length} peringatan)";
      }

      return SyncResult(
        isSuccess: true,
        message: successMsg,
        pushedCount: pushed,
        pulledCount: pulled,
        errors: syncErrors,
      );
    } catch (e) {
      debugPrint("Sync error: $e");
      return SyncResult(
        isSuccess: false,
        message: "Gagal sinkronisasi: ${e.toString()}",
        errors: [e.toString()],
      );
    } finally {
      isSyncing.value = false;
      await updatePendingCount();
    }
  }

  // ---------------------------------------------------------------------------
  // SYNC ITEMS
  // ---------------------------------------------------------------------------
  Future<Map<String, int>> _syncItems(List<String> errors) async {
    int pushed = 0;
    int pulled = 0;

    try {
      final unsyncedItems = await isar.itemModels.filter().isSyncedEqualTo(false).findAll();
      for (final item in unsyncedItems) {
        try {
          await supabaseClient.from('items').upsert({
            'part_number': item.partNumber,
            'name': item.name,
            'category': item.category,
            'buy_price': item.buyPrice,
            'sell_price': item.sellPrice,
            'min_stock': item.minStock,
            'current_stock': item.currentStock,
          }, onConflict: 'part_number');

          await isar.writeTxn(() async {
            item.isSynced = true;
            await isar.itemModels.put(item);
          });
          pushed++;
        } catch (e) {
          errors.add("Item ${item.name}: $e");
          debugPrint("Failed to push item ${item.name}: $e");
        }
      }

      // Pull items from Supabase
      try {
        final List<dynamic> remoteItems = await supabaseClient.from('items').select();
        for (final row in remoteItems) {
          final partNumber = row['part_number'] as String? ?? '';
          if (partNumber.isEmpty) continue;

          final existing = await isar.itemModels.filter().partNumberEqualTo(partNumber, caseSensitive: false).findFirst();
          if (existing == null) {
            final newItem = ItemModel(
              partNumber: partNumber,
              name: row['name'] as String? ?? '',
              category: row['category'] as String? ?? 'Umum',
              buyPrice: (row['buy_price'] as num?)?.toDouble() ?? 0.0,
              sellPrice: (row['sell_price'] as num?)?.toDouble() ?? 0.0,
              minStock: (row['min_stock'] as num?)?.toInt() ?? 0,
              currentStock: (row['current_stock'] as num?)?.toInt() ?? 0,
              isSynced: true,
            );
            await isar.writeTxn(() async {
              await isar.itemModels.put(newItem);
            });
            pulled++;
          }
        }
      } catch (e) {
        debugPrint("Failed to pull items: $e");
      }
    } catch (e) {
      errors.add("Sync Items: $e");
      debugPrint("Error in _syncItems: $e");
    }

    return {'pushed': pushed, 'pulled': pulled};
  }

  // ---------------------------------------------------------------------------
  // SYNC PARTNERS (CUSTOMERS & SUPPLIERS)
  // ---------------------------------------------------------------------------
  Future<Map<String, int>> _syncPartners(List<String> errors) async {
    int pushed = 0;
    int pulled = 0;

    // 1. Customers
    try {
      final localCustomers = await isar.customerModels.where().findAll();
      for (final cust in localCustomers) {
        try {
          await supabaseClient.from('customers').upsert({
            'name': cust.name,
            'phone': cust.phone,
            'address': cust.address,
            'total_debt': cust.totalDebt,
          }, onConflict: 'phone');
          pushed++;
        } catch (e) {
          errors.add("Customer ${cust.name}: $e");
          debugPrint("Push customer error: $e");
        }
      }

      // Pull remote customers
      try {
        final List<dynamic> remoteCusts = await supabaseClient.from('customers').select();
        for (final row in remoteCusts) {
          final phone = row['phone'] as String? ?? '';
          if (phone.isEmpty) continue;

          final existing = await isar.customerModels.filter().phoneEqualTo(phone).findFirst();
          if (existing == null) {
            final newCust = CustomerModel(
              name: row['name'] as String? ?? '',
              phone: phone,
              address: row['address'] as String? ?? '',
              totalDebt: (row['total_debt'] as num?)?.toDouble() ?? 0.0,
            );
            await isar.writeTxn(() async {
              await isar.customerModels.put(newCust);
            });
            pulled++;
          }
        }
      } catch (e) {
        debugPrint("Pull customer error: $e");
      }
    } catch (e) {
      debugPrint("Error syncing customers: $e");
    }

    // 2. Suppliers
    try {
      final localSuppliers = await isar.supplierModels.where().findAll();
      for (final sup in localSuppliers) {
        try {
          await supabaseClient.from('suppliers').upsert({
            'name': sup.name,
            'phone': sup.phone,
            'address': sup.address,
            'total_payable': sup.totalPayable,
          }, onConflict: 'phone');
          pushed++;
        } catch (e) {
          errors.add("Supplier ${sup.name}: $e");
          debugPrint("Push supplier error: $e");
        }
      }

      // Pull remote suppliers
      try {
        final List<dynamic> remoteSups = await supabaseClient.from('suppliers').select();
        for (final row in remoteSups) {
          final phone = row['phone'] as String? ?? '';
          if (phone.isEmpty) continue;

          final existing = await isar.supplierModels.filter().phoneEqualTo(phone).findFirst();
          if (existing == null) {
            final newSup = SupplierModel(
              name: row['name'] as String? ?? '',
              phone: phone,
              address: row['address'] as String? ?? '',
              totalPayable: (row['total_payable'] as num?)?.toDouble() ?? 0.0,
            );
            await isar.writeTxn(() async {
              await isar.supplierModels.put(newSup);
            });
            pulled++;
          }
        }
      } catch (e) {
        debugPrint("Pull supplier error: $e");
      }
    } catch (e) {
      debugPrint("Error syncing suppliers: $e");
    }

    return {'pushed': pushed, 'pulled': pulled};
  }

  // ---------------------------------------------------------------------------
  // SYNC SALES & SALE ITEMS
  // ---------------------------------------------------------------------------
  Future<Map<String, int>> _syncSales(List<String> errors) async {
    int pushed = 0;
    int pulled = 0;

    try {
      final unsyncedSales = await isar.saleTransactionModels.filter().isSyncedEqualTo(false).findAll();
      for (final sale in unsyncedSales) {
        try {
          // Lookup nama customer jika ada
          String customerName = "Pelanggan Umum";
          int? validCustomerId;
          if (sale.customerId > 0) {
            final customer = await isar.customerModels.get(sale.customerId);
            if (customer != null) {
              customerName = customer.name;
              validCustomerId = customer.id;
            }
          }

          // Coba kirim payload lengkap
          try {
            await supabaseClient.from('sales').upsert({
              'invoice_number': sale.invoiceNumber,
              'customer_id': validCustomerId,
              'customer_name': customerName,
              'date': sale.date.toIso8601String(),
              'payment_status': sale.paymentStatus,
              'grand_total': sale.grandTotal,
              'paid_amount': sale.paidAmount,
              'remaining_debt': sale.remainingDebt,
              'due_date': sale.dueDate?.toIso8601String(),
            }, onConflict: 'invoice_number');
          } catch (e) {
            // Fallback: kirim tanpa customer_name jika kolom tidak ada
            debugPrint("Sales upsert with customer_name failed, trying minimal payload: $e");
            await supabaseClient.from('sales').upsert({
              'invoice_number': sale.invoiceNumber,
              'customer_id': validCustomerId,
              'date': sale.date.toIso8601String(),
              'payment_status': sale.paymentStatus,
              'grand_total': sale.grandTotal,
              'paid_amount': sale.paidAmount,
              'remaining_debt': sale.remainingDebt,
              'due_date': sale.dueDate?.toIso8601String(),
            }, onConflict: 'invoice_number');
          }

          // Push items for this sale
          final items = await isar.saleItemModels.filter().saleTransactionIdEqualTo(sale.id).findAll();
          for (final item in items) {
            try {
              final itemModel = await isar.itemModels.get(item.itemId);
              try {
                await supabaseClient.from('sale_items').insert({
                  'invoice_number': sale.invoiceNumber,
                  'item_id': item.itemId > 0 ? item.itemId : null,
                  'part_number': itemModel?.partNumber ?? '',
                  'item_name': itemModel?.name ?? 'Barang',
                  'qty': item.qty,
                  'price': item.price,
                  'subtotal': item.subtotal,
                });
              } catch (itemErr) {
                // Fallback: kirim tanpa part_number dan item_name
                debugPrint("Sale item with extra columns failed, trying minimal: $itemErr");
                await supabaseClient.from('sale_items').insert({
                  'invoice_number': sale.invoiceNumber,
                  'item_id': item.itemId > 0 ? item.itemId : null,
                  'qty': item.qty,
                  'price': item.price,
                  'subtotal': item.subtotal,
                });
              }
            } catch (e) {
              debugPrint("Push sale item detail error: $e");
            }
          }

          await isar.writeTxn(() async {
            sale.isSynced = true;
            await isar.saleTransactionModels.put(sale);
          });
          pushed++;
        } catch (e) {
          final errStr = "Penjualan ${sale.invoiceNumber}: $e";
          errors.add(errStr);
          debugPrint(errStr);
        }
      }

      // Pull remote sales yang belum ada di device ini (mis. dibuat di device lain)
      try {
        final List<dynamic> remoteSales = await supabaseClient.from('sales').select();
        for (final row in remoteSales) {
          final invoiceNumber = row['invoice_number'] as String? ?? '';
          if (invoiceNumber.isEmpty) continue;

          final existingSale = await isar.saleTransactionModels
              .filter()
              .invoiceNumberEqualTo(invoiceNumber)
              .findFirst();
          if (existingSale != null) continue;

          // Cocokkan customer berdasarkan nama (fallback: Pelanggan Umum / id 0)
          int resolvedCustomerId = 0;
          final customerName = row['customer_name'] as String?;
          if (customerName != null && customerName.isNotEmpty) {
            final localCustomer = await isar.customerModels
                .filter()
                .nameEqualTo(customerName, caseSensitive: false)
                .findFirst();
            if (localCustomer != null) resolvedCustomerId = localCustomer.id;
          }

          final newSale = SaleTransactionModel(
            invoiceNumber: invoiceNumber,
            customerId: resolvedCustomerId,
            date: DateTime.tryParse(row['date'] as String? ?? '') ?? DateTime.now(),
            paymentStatus: row['payment_status'] as String? ?? 'LUNAS',
            grandTotal: (row['grand_total'] as num?)?.toDouble() ?? 0.0,
            paidAmount: (row['paid_amount'] as num?)?.toDouble() ?? 0.0,
            remainingDebt: (row['remaining_debt'] as num?)?.toDouble() ?? 0.0,
            dueDate: row['due_date'] != null
                ? DateTime.tryParse(row['due_date'] as String)
                : null,
            isSynced: true,
          );

          final newSaleId = await isar.writeTxn<int>(() async {
            final id = await isar.saleTransactionModels.put(newSale);
            newSale.id = id;
            return id;
          });
          pulled++;

          // Pull detail item penjualan untuk invoice ini
          try {
            final List<dynamic> remoteSaleItems = await supabaseClient
                .from('sale_items')
                .select()
                .eq('invoice_number', invoiceNumber);
            for (final itemRow in remoteSaleItems) {
              int resolvedItemId = 0;
              final partNumber = itemRow['part_number'] as String?;
              if (partNumber != null && partNumber.isNotEmpty) {
                final localItem = await isar.itemModels
                    .filter()
                    .partNumberEqualTo(partNumber, caseSensitive: false)
                    .findFirst();
                if (localItem != null) resolvedItemId = localItem.id;
              }

              final newSaleItem = SaleItemModel(
                saleTransactionId: newSaleId,
                itemId: resolvedItemId,
                qty: (itemRow['qty'] as num?)?.toInt() ?? 0,
                price: (itemRow['price'] as num?)?.toDouble() ?? 0.0,
                subtotal: (itemRow['subtotal'] as num?)?.toDouble() ?? 0.0,
              );
              await isar.writeTxn(() async {
                await isar.saleItemModels.put(newSaleItem);
              });
            }
          } catch (e) {
            debugPrint("Failed to pull sale items for $invoiceNumber: $e");
          }
        }
      } catch (e) {
        debugPrint("Failed to pull sales: $e");
      }
    } catch (e) {
      errors.add("Sync Sales: $e");
      debugPrint("Error syncing sales: $e");
    }

    return {'pushed': pushed, 'pulled': pulled};
  }

  // ---------------------------------------------------------------------------
  // SYNC PURCHASES & PURCHASE ITEMS
  // ---------------------------------------------------------------------------
  Future<Map<String, int>> _syncPurchases(List<String> errors) async {
    int pushed = 0;
    int pulled = 0;

    try {
      final unsyncedPurchases = await isar.purchaseTransactionModels.filter().isSyncedEqualTo(false).findAll();
      for (final purchase in unsyncedPurchases) {
        try {
          String supplierName = "Supplier";
          int? validSupplierId;
          if (purchase.supplierId > 0) {
            final supplier = await isar.supplierModels.get(purchase.supplierId);
            if (supplier != null) {
              supplierName = supplier.name;
              validSupplierId = supplier.id;
            }
          }

          try {
            await supabaseClient.from('purchases').upsert({
              'po_number': purchase.poNumber,
              'supplier_id': validSupplierId,
              'supplier_name': supplierName,
              'date': purchase.date.toIso8601String(),
              'payment_status': purchase.paymentStatus,
              'grand_total': purchase.grandTotal,
              'paid_amount': purchase.paidAmount,
              'remaining_payable': purchase.remainingPayable,
              'due_date': purchase.dueDate?.toIso8601String(),
            }, onConflict: 'po_number');
          } catch (e) {
            // Fallback: kirim tanpa supplier_name
            debugPrint("Purchases upsert with supplier_name failed, trying minimal: $e");
            await supabaseClient.from('purchases').upsert({
              'po_number': purchase.poNumber,
              'supplier_id': validSupplierId,
              'date': purchase.date.toIso8601String(),
              'payment_status': purchase.paymentStatus,
              'grand_total': purchase.grandTotal,
              'paid_amount': purchase.paidAmount,
              'remaining_payable': purchase.remainingPayable,
              'due_date': purchase.dueDate?.toIso8601String(),
            }, onConflict: 'po_number');
          }

          final items = await isar.purchaseItemModels.filter().purchaseTransactionIdEqualTo(purchase.id).findAll();
          for (final item in items) {
            try {
              final itemModel = await isar.itemModels.get(item.itemId);
              try {
                await supabaseClient.from('purchase_items').insert({
                  'po_number': purchase.poNumber,
                  'item_id': item.itemId > 0 ? item.itemId : null,
                  'part_number': itemModel?.partNumber ?? '',
                  'item_name': itemModel?.name ?? 'Barang',
                  'qty': item.qty,
                  'price': item.price,
                  'subtotal': item.subtotal,
                });
              } catch (itemErr) {
                debugPrint("Purchase item with extra columns failed, trying minimal: $itemErr");
                await supabaseClient.from('purchase_items').insert({
                  'po_number': purchase.poNumber,
                  'item_id': item.itemId > 0 ? item.itemId : null,
                  'qty': item.qty,
                  'price': item.price,
                  'subtotal': item.subtotal,
                });
              }
            } catch (e) {
              debugPrint("Push purchase item detail error: $e");
            }
          }

          await isar.writeTxn(() async {
            purchase.isSynced = true;
            await isar.purchaseTransactionModels.put(purchase);
          });
          pushed++;
        } catch (e) {
          final errStr = "Pembelian ${purchase.poNumber}: $e";
          errors.add(errStr);
          debugPrint(errStr);
        }
      }

      // Pull remote purchases yang belum ada di device ini (mis. dibuat di device lain)
      try {
        final List<dynamic> remotePurchases = await supabaseClient.from('purchases').select();
        for (final row in remotePurchases) {
          final poNumber = row['po_number'] as String? ?? '';
          if (poNumber.isEmpty) continue;

          final existingPurchase = await isar.purchaseTransactionModels
              .filter()
              .poNumberEqualTo(poNumber)
              .findFirst();
          if (existingPurchase != null) continue;

          // Cocokkan supplier berdasarkan nama (fallback: id 0)
          int resolvedSupplierId = 0;
          final supplierName = row['supplier_name'] as String?;
          if (supplierName != null && supplierName.isNotEmpty) {
            final localSupplier = await isar.supplierModels
                .filter()
                .nameEqualTo(supplierName, caseSensitive: false)
                .findFirst();
            if (localSupplier != null) resolvedSupplierId = localSupplier.id;
          }

          final newPurchase = PurchaseTransactionModel(
            poNumber: poNumber,
            supplierId: resolvedSupplierId,
            date: DateTime.tryParse(row['date'] as String? ?? '') ?? DateTime.now(),
            paymentStatus: row['payment_status'] as String? ?? 'LUNAS',
            grandTotal: (row['grand_total'] as num?)?.toDouble() ?? 0.0,
            paidAmount: (row['paid_amount'] as num?)?.toDouble() ?? 0.0,
            remainingPayable: (row['remaining_payable'] as num?)?.toDouble() ?? 0.0,
            dueDate: row['due_date'] != null
                ? DateTime.tryParse(row['due_date'] as String)
                : null,
            isSynced: true,
          );

          final newPurchaseId = await isar.writeTxn<int>(() async {
            final id = await isar.purchaseTransactionModels.put(newPurchase);
            newPurchase.id = id;
            return id;
          });
          pulled++;

          // Pull detail item pembelian untuk PO ini
          try {
            final List<dynamic> remotePurchaseItems = await supabaseClient
                .from('purchase_items')
                .select()
                .eq('po_number', poNumber);
            for (final itemRow in remotePurchaseItems) {
              int resolvedItemId = 0;
              final partNumber = itemRow['part_number'] as String?;
              if (partNumber != null && partNumber.isNotEmpty) {
                final localItem = await isar.itemModels
                    .filter()
                    .partNumberEqualTo(partNumber, caseSensitive: false)
                    .findFirst();
                if (localItem != null) resolvedItemId = localItem.id;
              }

              final newPurchaseItem = PurchaseItemModel(
                purchaseTransactionId: newPurchaseId,
                itemId: resolvedItemId,
                qty: (itemRow['qty'] as num?)?.toInt() ?? 0,
                price: (itemRow['price'] as num?)?.toDouble() ?? 0.0,
                subtotal: (itemRow['subtotal'] as num?)?.toDouble() ?? 0.0,
              );
              await isar.writeTxn(() async {
                await isar.purchaseItemModels.put(newPurchaseItem);
              });
            }
          } catch (e) {
            debugPrint("Failed to pull purchase items for $poNumber: $e");
          }
        }
      } catch (e) {
        debugPrint("Failed to pull purchases: $e");
      }
    } catch (e) {
      errors.add("Sync Purchases: $e");
      debugPrint("Error syncing purchases: $e");
    }

    return {'pushed': pushed, 'pulled': pulled};
  }

  // ---------------------------------------------------------------------------
  // SYNC STOCK MOVEMENT LOGS
  // ---------------------------------------------------------------------------
  Future<Map<String, int>> _syncStockLogs(List<String> errors) async {
    int pushed = 0;

    try {
      final unsyncedLogs = await isar.stockMovementLogModels.filter().isSyncedEqualTo(false).findAll();
      for (final log in unsyncedLogs) {
        try {
          final itemModel = await isar.itemModels.get(log.itemId);
          
          // Coba kirim payload lengkap, jika gagal fallback ke kolom standar Isar
          try {
            await supabaseClient.from('stock_movement_logs').insert({
              'item_id': log.itemId > 0 ? log.itemId : null,
              'part_number': itemModel?.partNumber ?? '',
              'item_name': itemModel?.name ?? '',
              'change_qty': log.changeQty,
              'movement_type': log.movementType,
              'reference_number': log.referenceNumber,
              'timestamp': log.timestamp.toIso8601String(),
            });
          } catch (insertErr) {
            // Fallback: Kirim HANYA kolom standar tanpa item_name & part_number
            debugPrint("Stock log insert with extra columns failed, trying standard payload: $insertErr");
            await supabaseClient.from('stock_movement_logs').insert({
              'item_id': log.itemId > 0 ? log.itemId : null,
              'change_qty': log.changeQty,
              'movement_type': log.movementType,
              'reference_number': log.referenceNumber,
              'timestamp': log.timestamp.toIso8601String(),
            });
          }

          await isar.writeTxn(() async {
            log.isSynced = true;
            await isar.stockMovementLogModels.put(log);
          });
          pushed++;
        } catch (e) {
          debugPrint("Failed to push stock log: $e");
        }
      }
    } catch (e) {
      debugPrint("Error syncing stock logs: $e");
    }

    return {'pushed': pushed};
  }
}
