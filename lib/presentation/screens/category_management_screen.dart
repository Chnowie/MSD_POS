import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import '../../data/models/category_model.dart';
import '../../data/models/item_model.dart';

/// Halaman untuk mengelola daftar kategori barang sendiri (tambah/edit/hapus).
/// Kategori ini yang jadi sumber pilihan dropdown di form Tambah Sparepart,
/// dan kode-nya dipakai sebagai prefix nomor part otomatis (mis. REM-0001).
class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    final isar = context.read<Isar>();
    _subscription = isar.categoryModels.watchLazy().listen((_) {
      if (mounted) _loadCategories(showLoading: false);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    final isar = context.read<Isar>();
    final categories = await isar.categoryModels.where().sortByName().findAll();
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  void _openCategoryForm([CategoryModel? existing]) {
    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final codeCtrl = TextEditingController(text: existing?.code ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Kategori" : "Tambah Kategori Baru"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nama Kategori *",
                    hintText: "Misal: Pengereman",
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: "Kode Prefix (2-4 huruf) *",
                    hintText: "Misal: REM",
                    helperText: "Dipakai sebagai awalan kode barang otomatis, contoh: REM-0001",
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Wajib diisi";
                    if (v.trim().length < 2) return "Minimal 2 huruf";
                    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(v.trim())) {
                      return "Hanya huruf/angka, tanpa spasi";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final isar = context.read<Isar>();
                final name = nameCtrl.text.trim();
                final code = codeCtrl.text.trim().toUpperCase();

                // Validasi duplikat nama/kode (selain milik data yang sedang diedit)
                final dupName = await isar.categoryModels
                    .filter()
                    .nameEqualTo(name, caseSensitive: false)
                    .findFirst();
                if (dupName != null && dupName.id != existing?.id) {
                  if (dialogCtx.mounted) {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      const SnackBar(content: Text("Nama kategori sudah dipakai.")),
                    );
                  }
                  return;
                }
                final dupCode = await isar.categoryModels
                    .filter()
                    .codeEqualTo(code, caseSensitive: false)
                    .findFirst();
                if (dupCode != null && dupCode.id != existing?.id) {
                  if (dialogCtx.mounted) {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      const SnackBar(content: Text("Kode ini sudah dipakai kategori lain.")),
                    );
                  }
                  return;
                }

                await isar.writeTxn(() async {
                  if (isEdit) {
                    existing.name = name;
                    existing.code = code;
                    await isar.categoryModels.put(existing);
                  } else {
                    await isar.categoryModels.put(CategoryModel(name: name, code: code));
                  }
                });

                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final isar = context.read<Isar>();
    final usageCount = await isar.itemModels
        .filter()
        .categoryEqualTo(category.name, caseSensitive: false)
        .count();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          usageCount > 0
              ? "Kategori '${category.name}' masih dipakai $usageCount barang. "
                  "Barang-barang itu tidak akan terhapus, tapi kategorinya perlu diubah manual nanti. Tetap hapus?"
              : "Yakin ingin menghapus kategori '${category.name}'?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await isar.writeTxn(() async {
                await isar.categoryModels.delete(category.id);
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Kategori Barang")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCategoryForm(),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Kategori"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text("Belum ada kategori. Tambahkan dulu."))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          cat.code,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ),
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        "Kode: ${cat.code} • Barang berikutnya: ${cat.code}-${(cat.lastSequence + 1).toString().padLeft(4, '0')}",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _openCategoryForm(cat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            onPressed: () => _confirmDelete(cat),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
