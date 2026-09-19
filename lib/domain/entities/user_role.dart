/// Enum Role Pengguna untuk Hak Akses Fitur (RBAC)
enum UserRole {
  // Menggunakan nama lowerCamelCase sesuai pedoman Dart Lints
  // dengan konstanta backward-compatible
  admin,
  kasir,
  owner;

  // Static alias untuk backwards compatibility dengan kode yang menggunakan UPPERCASE
  // ignore: constant_identifier_names
  static const UserRole ADMIN = UserRole.admin;
  // ignore: constant_identifier_names
  static const UserRole KASIR = UserRole.kasir;
  // ignore: constant_identifier_names
  static const UserRole OWNER = UserRole.owner;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.kasir:
        return 'Kasir';
      case UserRole.owner:
        return 'Owner / Pemilik Toko';
    }
  }

  String toShortString() {
    return name.toUpperCase();
  }

  static UserRole fromString(String roleStr) {
    switch (roleStr.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'KASIR':
        return UserRole.kasir;
      case 'OWNER':
        return UserRole.owner;
      default:
        return UserRole.kasir;
    }
  }
}

extension UserRoleExtension on UserRole {
  // Menjaga kompatibilitas extension
  String toShortString() => name.toUpperCase();
  static UserRole fromString(String roleStr) => UserRole.fromString(roleStr);
}
