# msd_pos

Aplikasi Point of Sale (POS) berbasis Flutter dengan pendekatan **offline-first**:
data disimpan lokal di Isar dan dapat disinkronkan ke Supabase.

## Fitur

- Kasir (POS), pembelian, dan manajemen stok barang
- Kelola kategori, pelanggan, dan supplier
- Laporan hutang dan dashboard
- Cetak dokumen PDF
- Hak akses berdasarkan peran: Owner, Admin, Kasir

## Teknologi

Flutter, Dart, flutter_bloc, Provider, Isar (database lokal), Supabase (sinkronisasi online).

## Cara menjalankan

1. Pastikan [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang.
2. Unduh dependensi:

   ```bash
   flutter pub get
   ```

3. Salin file konfigurasi, lalu isi dengan kredensial Supabase Anda sendiri:

   ```bash
   cp lib/core/config/supabase_config.example.dart lib/core/config/supabase_config.dart
   ```

   Biarkan isinya apa adanya jika hanya ingin mencoba **mode offline** (tanpa sinkronisasi online).
   File `supabase_config.dart` sengaja tidak disertakan di repository ini karena berisi kredensial.

4. (Opsional, untuk sinkronisasi online) jalankan `supabase_fresh_setup.sql` di Supabase SQL Editor untuk membuat tabel.
5. Jalankan aplikasi:

   ```bash
   flutter run -d windows
   ```

## Akun demo (data lokal)

Saat pertama dijalankan, dibuat 3 akun contoh dengan password `password123`:
`owner`, `admin`, dan `kasir`.
