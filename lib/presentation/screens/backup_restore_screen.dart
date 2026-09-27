import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/authorization/role_permission.dart';
import '../../core/utils/audit_logger.dart';
import '../../data/datasources/backup_service.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import 'login_screen.dart';

/// Halaman Backup & Restore Database: jaring pengaman tambahan di luar
/// sinkronisasi Supabase — export seluruh data ke satu file JSON yang bisa
/// disimpan/dibagikan, dan restore dari file tersebut. Khusus Owner karena
/// restore bersifat MENIMPA TOTAL data yang ada. Restore memaksa kembali ke
/// halaman login karena data user & sesi lokal ikut diganti.
class BackupRestoreScreen extends StatefulWidget {
  final UserModel currentUser;

  const BackupRestoreScreen({super.key, required this.currentUser});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isBusy = false;
  String? _statusMessage;
  bool _statusIsError = false;

  Future<void> _exportBackup() async {
    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    try {
      final isar = context.read<Isar>();
      final backupService = BackupService(isar);
      final data = await backupService.exportAll();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final dir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${dir.path}/msd_pos_backup_$timestamp.json');
      await file.writeAsString(jsonStr);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup database MSD POS - $timestamp',
      );

      setState(() {
        _statusIsError = false;
        _statusMessage = "Backup berhasil dibuat. Simpan file itu di tempat aman "
            "(Google Drive, email, dsb).";
      });
    } catch (e) {
      setState(() {
        _statusIsError = true;
        _statusMessage = "Gagal membuat backup: $e";
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pickAndRestoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    Map<String, dynamic> data;
    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic> ||
          decoded['formatVersion'] == null ||
          decoded['users'] == null) {
        throw const FormatException("Bukan file backup MSD POS yang valid.");
      }
      data = decoded;
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusIsError = true;
          _statusMessage = "File tidak valid: $e";
        });
      }
      return;
    }

    if (!mounted) return;
    final confirmed = await _confirmRestoreDialog(data);
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    try {
      final isar = context.read<Isar>();
      final backupService = BackupService(isar);
      await backupService.restoreAll(data);

      await isar.writeTxn(() async {
        await AuditLogger.record(
          isar,
          widget.currentUser,
          'RESTORE_BACKUP',
          "Restore database dari file backup (dibuat: ${data['exportedAt'] ?? '-'})",
        );
      });

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text("Restore Berhasil"),
          content: const Text(
            "Database berhasil dipulihkan dari backup. Silakan login ulang "
            "untuk melanjutkan.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.read<AuthBloc>().add(LogoutRequested());
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _statusIsError = true;
        _statusMessage = "Gagal restore: $e";
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<bool?> _confirmRestoreDialog(Map<String, dynamic> data) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text("Konfirmasi Restore")),
          ],
        ),
        content: Text(
          "PERINGATAN: SEMUA data yang ada di aplikasi ini SEKARANG akan "
          "DIHAPUS dan DIGANTI TOTAL dengan data dari file backup "
          "(dibuat: ${data['exportedAt'] ?? '-'}).\n\n"
          "Tindakan ini TIDAK BISA DIBATALKAN. Pastikan kamu benar-benar yakin.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Timpa Semua Data", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = RolePermission.canViewNetProfitDashboard(widget.currentUser.userRoleEnum);

    if (!canManage) {
      return Scaffold(
        appBar: AppBar(title: const Text("Backup & Restore")),
        body: const Center(
          child: Text("Akses ditolak: Hanya Owner yang dapat membuka halaman ini."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Backup & Restore Database")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.backup_outlined, color: Colors.blue.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Backup Database",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Simpan salinan SELURUH data aplikasi (barang, transaksi, "
                      "pelanggan, supplier, bagi hasil, dsb.) ke satu file. File "
                      "bisa disimpan ke Google Drive, dikirim via WhatsApp/Email, dsb. "
                      "sebagai jaring pengaman tambahan di luar sinkronisasi cloud.",
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isBusy ? null : _exportBackup,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text("Buat & Bagikan Backup"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restore_outlined, color: Colors.red.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Restore Database",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.red.shade900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pulihkan data dari file backup sebelumnya. PERHATIAN: "
                      "seluruh data yang ada SEKARANG akan tertimpa/terhapus total "
                      "dan digantikan isi file backup.",
                      style: TextStyle(fontSize: 13, color: Colors.red.shade900),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: _isBusy ? null : _pickAndRestoreBackup,
                      icon: const Icon(Icons.upload_outlined),
                      label: const Text("Pilih File & Restore"),
                    ),
                  ],
                ),
              ),
            ),
            if (_isBusy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusIsError ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _statusIsError ? Colors.red.shade300 : Colors.green.shade300,
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusIsError ? Colors.red.shade900 : Colors.green.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
