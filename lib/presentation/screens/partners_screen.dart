import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/authorization/role_permission.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/purchase_transaction_model.dart';
import '../../data/models/sale_transaction_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/user_model.dart';

class PartnersScreen extends StatefulWidget {
  final UserModel currentUser;

  const PartnersScreen({super.key, required this.currentUser});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _filteredSuppliers = [];

  final TextEditingController _customerSearchCtrl = TextEditingController();
  final TextEditingController _supplierSearchCtrl = TextEditingController();
  bool _isLoading = true;
  StreamSubscription? _customerSub;
  StreamSubscription? _supplierSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _initWatchers();
    _customerSearchCtrl.addListener(_filterCustomers);
    _supplierSearchCtrl.addListener(_filterSuppliers);
  }

  void _initWatchers() {
    final isar = context.read<Isar>();
    _customerSub = isar.customerModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
    _supplierSub = isar.supplierModels.watchLazy().listen((_) {
      if (mounted) _loadData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _customerSub?.cancel();
    _supplierSub?.cancel();
    _tabController.dispose();
    _customerSearchCtrl.dispose();
    _supplierSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && _customers.isEmpty && _suppliers.isEmpty) {
      setState(() => _isLoading = true);
    }
    final isar = context.read<Isar>();

    final customers = await isar.customerModels.where().findAll();
    final suppliers = await isar.supplierModels.where().findAll();

    if (mounted) {
      setState(() {
        _customers = customers;
        _suppliers = suppliers;
        _isLoading = false;
      });
      _filterCustomers();
      _filterSuppliers();
    }
  }

  void _filterCustomers() {
    final q = _customerSearchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _filterSuppliers() {
    final q = _supplierSearchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredSuppliers = _suppliers.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.phone.toLowerCase().contains(q) ||
            s.address.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _openCustomerDialog({CustomerModel? customer}) {
    final isEdit = customer != null;
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    final addressCtrl = TextEditingController(text: customer?.address ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Data Pelanggan" : "Tambah Pelanggan Baru"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap / Bengkel *",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Nomor HP / WA *",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: "Alamat Lengkap",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final address = addressCtrl.text.trim();
                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nama dan HP wajib diisi.")),
                  );
                  return;
                }

                final isar = context.read<Isar>();
                if (isEdit) {
                  customer.name = name;
                  customer.phone = phone;
                  customer.address = address.isEmpty ? '-' : address;
                  await isar.writeTxn(() async {
                    await isar.customerModels.put(customer);
                  });
                } else {
                  final newC = CustomerModel(
                    name: name,
                    phone: phone,
                    address: address.isEmpty ? '-' : address,
                    totalDebt: 0.0,
                  );
                  await isar.writeTxn(() async {
                    await isar.customerModels.put(newC);
                  });
                }

                if (mounted && ctx.mounted) {
                  Navigator.pop(ctx);
                  _loadData();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? "Pelanggan '$name' berhasil diupdate."
                            : "Pelanggan baru berhasil ditambahkan.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void _openSupplierDialog({SupplierModel? supplier}) {
    final isEdit = supplier != null;
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Data Supplier" : "Tambah Supplier Baru"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nama Supplier / Distributor *",
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Nomor Telepon / Sales *",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: "Alamat Kantor / Gudang",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final address = addressCtrl.text.trim();
                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nama dan telepon supplier wajib diisi.")),
                  );
                  return;
                }

                final isar = context.read<Isar>();
                if (isEdit) {
                  supplier.name = name;
                  supplier.phone = phone;
                  supplier.address = address.isEmpty ? '-' : address;
                  await isar.writeTxn(() async {
                    await isar.supplierModels.put(supplier);
                  });
                } else {
                  final newS = SupplierModel(
                    name: name,
                    phone: phone,
                    address: address.isEmpty ? '-' : address,
                    totalPayable: 0.0,
                  );
                  await isar.writeTxn(() async {
                    await isar.supplierModels.put(newS);
                  });
                }

                if (mounted && ctx.mounted) {
                  Navigator.pop(ctx);
                  _loadData();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? "Supplier '$name' berhasil diupdate."
                            : "Supplier baru berhasil ditambahkan.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteCustomer(CustomerModel customer) async {
    final isar = context.read<Isar>();
    final transactionCount = await isar.saleTransactionModels
        .filter()
        .customerIdEqualTo(customer.id)
        .count();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus Pelanggan"),
        content: Text(
          transactionCount > 0
              ? "Pelanggan '${customer.name}' memiliki riwayat $transactionCount transaksi penjualan. "
                  "Riwayat transaksi TIDAK akan ikut terhapus, tapi tidak akan lagi terhubung ke data pelanggan ini."
                  "${customer.totalDebt > 0 ? ' Pelanggan ini masih punya piutang ${Formatters.formatRupiah(customer.totalDebt)} yang belum tertagih.' : ''}"
                  " Tetap hapus?"
              : "Yakin ingin menghapus data pelanggan '${customer.name}'?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await isar.writeTxn(() async {
                await isar.customerModels.delete(customer.id);
              });

              // Best-effort hapus juga di Supabase agar tidak "hidup lagi"
              // saat sinkronisasi berikutnya menarik data dari cloud.
              try {
                await Supabase.instance.client
                    .from('customers')
                    .delete()
                    .eq('phone', customer.phone);
              } catch (_) {
                // Offline / gagal koneksi: cukup terhapus lokal dulu.
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Pelanggan '${customer.name}' telah dihapus.")),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSupplier(SupplierModel supplier) async {
    final isar = context.read<Isar>();
    final transactionCount = await isar.purchaseTransactionModels
        .filter()
        .supplierIdEqualTo(supplier.id)
        .count();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus Supplier"),
        content: Text(
          transactionCount > 0
              ? "Supplier '${supplier.name}' memiliki riwayat $transactionCount transaksi pembelian. "
                  "Riwayat transaksi TIDAK akan ikut terhapus, tapi tidak akan lagi terhubung ke data supplier ini."
                  "${supplier.totalPayable > 0 ? ' Toko masih punya hutang ${Formatters.formatRupiah(supplier.totalPayable)} ke supplier ini.' : ''}"
                  " Tetap hapus?"
              : "Yakin ingin menghapus data supplier '${supplier.name}'?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await isar.writeTxn(() async {
                await isar.supplierModels.delete(supplier.id);
              });

              try {
                await Supabase.instance.client
                    .from('suppliers')
                    .delete()
                    .eq('phone', supplier.phone);
              } catch (_) {
                // Offline / gagal koneksi: cukup terhapus lokal dulu.
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Supplier '${supplier.name}' telah dihapus.")),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canManage = RolePermission.canManagePurchasesAndDebts(
      widget.currentUser.userRoleEnum,
    );

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalCustomerDebt = _customers.fold<double>(
      0.0,
      (sum, c) => sum + c.totalDebt,
    );
    final totalSupplierPayable = _suppliers.fold<double>(
      0.0,
      (sum, s) => sum + s.totalPayable,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.people_alt, size: 20),
                text: "Pelanggan (${_customers.length})",
              ),
              Tab(
                icon: const Icon(Icons.store, size: 20),
                text: "Supplier / Distributor (${_suppliers.length})",
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: CUSTOMERS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card Piutang
                Card(
                  color: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Total Piutang Belanja Pelanggan",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatRupiah(totalCustomerDebt),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openCustomerDialog(),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text("Tambah Pelanggan"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  controller: _customerSearchCtrl,
                  decoration: InputDecoration(
                    hintText: "Cari Pelanggan (Nama / Nomor HP / Alamat)...",
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _customerSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _customerSearchCtrl.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // List Customer
                Expanded(
                  child: _filteredCustomers.isEmpty
                      ? const Center(child: Text("Data pelanggan tidak ditemukan."))
                      : ListView.separated(
                          itemCount: _filteredCustomers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final c = _filteredCustomers[index];
                            final hasDebt = c.totalDebt > 0;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris nama: avatar + nama (fleksibel, tidak overflow)
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.indigo.shade100,
                                          child: Icon(Icons.person, color: theme.primaryColor, size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            c.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Telp: ${c.phone} | Alamat: ${c.address}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 8),
                                    // Badge + tombol aksi: otomatis turun baris kalau tidak muat
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: hasDebt ? Colors.red.shade100 : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            hasDebt
                                                ? "Piutang: ${Formatters.formatRupiah(c.totalDebt)}"
                                                : "Lunas (Rp 0)",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: hasDebt ? Colors.red.shade900 : Colors.green.shade900,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          tooltip: "Edit Pelanggan",
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => _openCustomerDialog(customer: c),
                                        ),
                                        if (canManage)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                            tooltip: "Hapus Pelanggan",
                                            visualDensity: VisualDensity.compact,
                                            onPressed: () => _confirmDeleteCustomer(c),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // TAB 2: SUPPLIERS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card Hutang
                Card(
                  color: Colors.amber.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.amber.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Total Hutang Toko ke Supplier",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatRupiah(totalSupplierPayable),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openSupplierDialog(),
                          icon: const Icon(Icons.business, size: 18),
                          label: const Text("Tambah Supplier"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  controller: _supplierSearchCtrl,
                  decoration: InputDecoration(
                    hintText: "Cari Supplier (Nama / Nomor HP / Alamat)...",
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _supplierSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _supplierSearchCtrl.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // List Supplier
                Expanded(
                  child: _filteredSuppliers.isEmpty
                      ? const Center(child: Text("Data supplier tidak ditemukan."))
                      : ListView.separated(
                          itemCount: _filteredSuppliers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final s = _filteredSuppliers[index];
                            final hasPayable = s.totalPayable > 0;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris nama: avatar + nama (fleksibel, tidak overflow)
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.teal.shade100,
                                          child: const Icon(Icons.business, color: Colors.teal, size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            s.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Telp: ${s.phone} | Alamat: ${s.address}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 8),
                                    // Badge + tombol aksi: otomatis turun baris kalau tidak muat
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: hasPayable ? Colors.amber.shade100 : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            hasPayable
                                                ? "Hutang: ${Formatters.formatRupiah(s.totalPayable)}"
                                                : "Lunas (Rp 0)",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: hasPayable ? Colors.amber.shade900 : Colors.green.shade900,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          tooltip: "Edit Supplier",
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => _openSupplierDialog(supplier: s),
                                        ),
                                        if (canManage)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                            tooltip: "Hapus Supplier",
                                            visualDensity: VisualDensity.compact,
                                            onPressed: () => _confirmDeleteSupplier(s),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
