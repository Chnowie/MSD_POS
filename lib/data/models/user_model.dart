import 'package:isar/isar.dart';

import '../../domain/entities/user_role.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid;

  @Index(unique: true, caseSensitive: false)
  String username;

  @Index(unique: true, caseSensitive: false)
  String email;

  @Index()
  String role;

  String? passwordHash;

  DateTime lastLogin;

  @Index()
  bool isSynced;

  UserModel({
    this.id = Isar.autoIncrement,
    required this.uuid,
    required this.username,
    required this.email,
    required this.role,
    this.passwordHash,
    required this.lastLogin,
    this.isSynced = false,
  });

  @ignore
  UserRole get userRoleEnum => UserRoleExtension.fromString(role);
}
