import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../models/user_model.dart';

class AuthService {
  final Isar isar;
  final SupabaseClient supabaseClient;

  AuthService({required this.isar, required this.supabaseClient});

  bool get isSupabaseConfigured {
    try {
      final url = supabaseClient.rest.url.toString();
      return !url.contains('placeholder.supabase.co') &&
          !url.contains('YOUR_SUPABASE_PROJECT_ID');
    } catch (_) {
      return false;
    }
  }

  /// Utility Hash Password sederhana untuk Local Offline Storage Backup
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Cek apakah ada koneksi internet aktif
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  /// Login Hybrid (Mencoba Online Supabase dulu, jika offline/placeholder fallback ke Local Isar)
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    // 1. Jika Supabase masih placeholder atau belum disetup, langsung gunakan Login Offline Isar
    if (!isSupabaseConfigured) {
      return await loginOffline(email: email, password: password);
    }

    // 2. Periksa koneksi internet terlebih dahulu
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return await loginOffline(email: email, password: password);
    }

    try {
      // 3. Coba Login Online via Supabase Auth
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // Fetch Profile Metadata dari Supabase Table
        String roleStr = 'KASIR';
        String username = email.split('@').first;

        try {
          final userProfile = await supabaseClient
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (userProfile != null) {
            roleStr = userProfile['role'] as String? ?? 'KASIR';
            username = userProfile['username'] as String? ?? username;
          }
        } catch (_) {
          // Tabel users mungkin belum ada, gunakan default nilai dari metadata
          final metadata = user.userMetadata;
          if (metadata != null) {
            roleStr = metadata['role'] as String? ?? 'KASIR';
            username = metadata['username'] as String? ?? username;
          }
        }

        // Save / Update to Local Isar DB for offline capability
        final localUser = await isar.writeTxn<UserModel>(() async {
          var existingUser = await isar.userModels
              .filter()
              .emailEqualTo(email)
              .findFirst();

          if (existingUser != null) {
            existingUser.uuid = user.id;
            existingUser.username = username;
            existingUser.role = roleStr;
            existingUser.passwordHash = _hashPassword(password);
            existingUser.lastLogin = DateTime.now();
            existingUser.isSynced = true;
            await isar.userModels.put(existingUser);
            return existingUser;
          } else {
            final newUser = UserModel(
              uuid: user.id,
              username: username,
              email: email,
              role: roleStr,
              passwordHash: _hashPassword(password),
              lastLogin: DateTime.now(),
              isSynced: true,
            );
            final id = await isar.userModels.put(newUser);
            newUser.id = id;
            return newUser;
          }
        });

        return Right(localUser);
      } else {
        return const Left(AuthFailure("Autentikasi Supabase gagal."));
      }
    } on SocketException catch (_) {
      // Koneksi Internet Terputus -> Offline Fallback Login
      return await loginOffline(email: email, password: password);
    } on AuthException catch (e) {
      // Jika error terkait jaringan atau kredensial tidak valid, coba login offline
      final msg = e.message.toLowerCase();
      if (msg.contains('socketexception') ||
          msg.contains('failed host lookup') ||
          msg.contains('clientexception') ||
          msg.contains('network') ||
          msg.contains('errno = 11001') ||
          msg.contains('invalid login credentials') ||
          msg.contains('invalid email or password') ||
          msg.contains('email not confirmed') ||
          msg.contains('user not found')) {
        return await loginOffline(email: email, password: password);
      }
      return Left(AuthFailure("Error Online Auth: ${e.message}"));
    } catch (e) {
      // Fallback jika tidak ada internet / offline network failure
      return await loginOffline(email: email, password: password);
    }
  }

  /// Login Offline Berdasarkan Local Isar Database
  Future<Either<Failure, UserModel>> loginOffline({
    required String email,
    required String password,
  }) async {
    try {
      final localUser = await isar.userModels
          .filter()
          .emailEqualTo(email, caseSensitive: false)
          .findFirst();

      if (localUser == null) {
        return const Left(
          AuthFailure(
            "Data login offline tidak ditemukan. Silakan login online minimal 1x atau daftar akun baru.",
          ),
        );
      }

      // Verifikasi Password Hash Lokal
      final inputHash = _hashPassword(password);
      if (localUser.passwordHash != inputHash) {
        return const Left(AuthFailure("Password salah (Mode Offline)."));
      }

      // Update Last Login — gunakan writeTxn langsung tanpa Future chaining
      await isar.writeTxn(() async {
        localUser.lastLogin = DateTime.now();
        await isar.userModels.put(localUser);
      });

      return Right(localUser);
    } catch (e) {
      return Left(DatabaseFailure("Gagal login offline: ${e.toString()}"));
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  /// Register akun baru — Hybrid (online jika terkoneksi, offline sebagai fallback)
  Future<Either<Failure, UserModel>> register({
    required String username,
    required String email,
    required String password,
    String role = 'KASIR',
  }) async {
    // 1. Validasi email tidak duplikat di lokal
    final existingLocal = await isar.userModels
        .filter()
        .emailEqualTo(email, caseSensitive: false)
        .findFirst();
    if (existingLocal != null) {
      return const Left(AuthFailure("Email ini sudah terdaftar."));
    }

    // 2. Validasi username tidak duplikat di lokal
    final existingUsername = await isar.userModels
        .filter()
        .usernameEqualTo(username, caseSensitive: false)
        .findFirst();
    if (existingUsername != null) {
      return const Left(AuthFailure("Username ini sudah digunakan."));
    }

    // 3. Coba register ke Supabase jika online
    if (isSupabaseConfigured) {
      final hasInternet = await _hasInternetConnection();
      if (hasInternet) {
        return await _registerOnline(
          username: username,
          email: email,
          password: password,
          role: role,
        );
      }
    }

    // 4. Fallback: Register offline ke Isar
    return await _registerOffline(
      username: username,
      email: email,
      password: password,
      role: role,
    );
  }

  /// Register Online via Supabase Auth + simpan ke lokal
  Future<Either<Failure, UserModel>> _registerOnline({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'role': role},
      );

      final user = response.user;
      if (user == null) {
        return const Left(AuthFailure("Gagal membuat akun di Supabase."));
      }

      // Simpan juga ke tabel users di Supabase jika memungkinkan
      try {
        await supabaseClient.from('users').upsert({
          'id': user.id,
          'username': username,
          'email': email,
          'role': role,
        });
      } catch (_) {
        // Jika tabel belum ada, abaikan dan lanjutkan simpan ke lokal
      }

      // Simpan ke Isar lokal
      final localUser = await isar.writeTxn<UserModel>(() async {
        final newUser = UserModel(
          uuid: user.id,
          username: username,
          email: email,
          role: role,
          passwordHash: _hashPassword(password),
          lastLogin: DateTime.now(),
          isSynced: true,
        );
        final id = await isar.userModels.put(newUser);
        newUser.id = id;
        return newUser;
      });

      return Right(localUser);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      // Jika sudah terdaftar di Supabase, beri tahu user
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return const Left(AuthFailure(
            "Email ini sudah terdaftar di Supabase. Silakan login."));
      }
      // Fallback ke offline jika error jaringan
      if (msg.contains('network') ||
          msg.contains('socketexception') ||
          msg.contains('clientexception')) {
        return await _registerOffline(
          username: username,
          email: email,
          password: password,
          role: role,
        );
      }
      return Left(AuthFailure("Gagal register online: ${e.message}"));
    } catch (e) {
      // Fallback ke offline jika ada error apapun
      return await _registerOffline(
        username: username,
        email: email,
        password: password,
        role: role,
      );
    }
  }

  /// Register Offline — Simpan langsung ke Isar
  Future<Either<Failure, UserModel>> _registerOffline({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final newUser = UserModel(
        uuid: _generateUuid(),
        username: username,
        email: email,
        role: role,
        passwordHash: _hashPassword(password),
        lastLogin: DateTime.now(),
        isSynced: false,
      );

      await isar.writeTxn(() async {
        await isar.userModels.put(newUser);
      });

      return Right(newUser);
    } catch (e) {
      return Left(DatabaseFailure("Gagal register offline: ${e.toString()}"));
    }
  }

  /// Generate UUID v4 menggunakan dart:math (tanpa package eksternal)
  String _generateUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
