import '../../domain/entities/user_role.dart';

/// Middleware/Helper Guard Otorisasi Hak Akses Fitur Aplikasi
class RolePermission {
  /// 1. Hak Akses Kasir & POS Sales Transaction
  static bool canCreateSale(UserRole role) {
    return role == UserRole.KASIR ||
        role == UserRole.ADMIN ||
        role == UserRole.OWNER;
  }

  /// 2. Hak Akses Melihat Stok Barang Sparepart
  static bool canViewStock(UserRole role) {
    return role == UserRole.KASIR ||
        role == UserRole.ADMIN ||
        role == UserRole.OWNER;
  }

  /// 3. Hak Akses Mengubah Harga Beli & Stok Opname (Item CRUD)
  static bool canModifyStock(UserRole role) {
    return role == UserRole.ADMIN || role == UserRole.OWNER;
  }

  /// 4. Hak Akses PO Supplier & Rekapan Hutang/Piutang
  static bool canManagePurchasesAndDebts(UserRole role) {
    return role == UserRole.ADMIN || role == UserRole.OWNER;
  }

  /// 5. Hak Akses Dashboard Laba Bersih & Laporan Keuangan Utama Toko
  static bool canViewNetProfitDashboard(UserRole role) {
    // HANYA OWNER YANG BISA MELIHAT LABA BERSIH
    return role == UserRole.OWNER;
  }

  /// 6. Hak Akses Manajemen User & Konfigurasi Sistem
  static bool canManageUsers(UserRole role) {
    return role == UserRole.OWNER;
  }
}
