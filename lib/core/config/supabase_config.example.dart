// KERANGKA KONFIGURASI SUPABASE.
//
// Cara pakai:
// 1. Salin file ini menjadi `supabase_config.dart` (di folder yang sama).
// 2. Isi URL dan AnonKey dari project Supabase Anda sendiri
//    (Supabase Dashboard > Project Settings > API).
//
// Biarkan `YOUR_SUPABASE_PROJECT_ID` apa adanya jika ingin menjalankan aplikasi
// dalam mode offline saja (tanpa sinkronisasi online).
// `supabase_config.dart` sudah masuk .gitignore sehingga tidak ikut ke GitHub.

const String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
