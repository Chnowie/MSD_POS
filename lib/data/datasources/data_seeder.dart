import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/purchase_item_model.dart';
import '../models/purchase_transaction_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_transaction_model.dart';
import '../models/stock_movement_log_model.dart';
import '../models/supplier_model.dart';
import '../models/user_model.dart';

class DataSeeder {
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Menjalankan initial data seeding jika database lokal masih kosong.
  /// HANYA membuat 3 akun user default (owner, admin, kasir).
  /// Semua data lain (barang, customer, supplier, transaksi) dimulai KOSONG.
  static Future<void> seedInitialData(Isar isar) async {
    // Hitung user nyata (exclude migration marker uuid)
    final userCount = await isar.userModels
        .filter()
        .not()
        .uuidEqualTo('__v2_clean__')
        .and()
        .not()
        .roleEqualTo('SYSTEM')
        .count();
    if (userCount > 0) return; // Akun sudah ada, tidak perlu re-seed


    await isar.writeTxn(() async {
      final defaultPasswordHash = _hashPassword('password123');

      final users = [
        UserModel(
          uuid: 'usr-owner-001',
          username: 'owner',
          email: 'owner@pos.com',
          role: 'OWNER',
          passwordHash: defaultPasswordHash,
          lastLogin: DateTime.now(),
          isSynced: false,
        ),
        UserModel(
          uuid: 'usr-admin-002',
          username: 'admin',
          email: 'admin@pos.com',
          role: 'ADMIN',
          passwordHash: defaultPasswordHash,
          lastLogin: DateTime.now(),
          isSynced: false,
        ),
        UserModel(
          uuid: 'usr-kasir-003',
          username: 'kasir',
          email: 'kasir@pos.com',
          role: 'KASIR',
          passwordHash: defaultPasswordHash,
          lastLogin: DateTime.now(),
          isSynced: false,
        ),
      ];
      await isar.userModels.putAll(users);
    });
  }

  /// Seed daftar kategori default (hanya jika BELUM ada satupun kategori).
  /// Daftar ini cuma titik awal — sepenuhnya bisa ditambah/diedit/dihapus
  /// sendiri lewat halaman Kelola Kategori.
  static Future<void> seedDefaultCategories(Isar isar) async {
    final categoryCount = await isar.categoryModels.count();
    if (categoryCount > 0) return; // Sudah ada kategori, tidak perlu re-seed

    await isar.writeTxn(() async {
      await isar.categoryModels.putAll([
        CategoryModel(name: 'Mesin', code: 'MSN'),
        CategoryModel(name: 'Kelistrikan', code: 'KLS'),
        CategoryModel(name: 'Pengereman', code: 'REM'),
        CategoryModel(name: 'Oli & Pelumas', code: 'OLI'),
        CategoryModel(name: 'Umum', code: 'UMM'),
      ]);
    });
  }

  /// Hapus SEMUA data lokal dan reset ke fresh state.
  /// Digunakan untuk keperluan testing / reset ulang aplikasi.
  static Future<void> clearAllData(Isar isar) async {
    await isar.writeTxn(() async {
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
    });
  }
}
