/// Konfigurasi koneksi ke project Supabase.
///
/// CPMK 6: nilai TIDAK boleh ditulis langsung di kode (hardcoded) —
/// diambil lewat Compile-Time Environment Injection (`--dart-define`),
/// dibaca dari file `.env` yang TIDAK di-commit ke Git (lihat .gitignore
/// & RELEASE_GUIDE.md).
///
/// Cara jalanin di lokal:
///   flutter run --dart-define-from-file=.env
/// Cara build release:
///   flutter build appbundle --dart-define-from-file=.env
///
/// Isi file `.env` (bikin sendiri dari `.env.example`):
///   SUPABASE_URL=https://xxxxx.supabase.co
///   SUPABASE_ANON_KEY=eyJhbGciOi...
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// App otomatis "tahu" belum dikonfigurasi kalau salah satu masih kosong.
  /// Dipakai supaya app TIDAK CRASH saat dijalankan sebelum key diisi —
  /// fitur cloud akan menampilkan pesan error yang jelas, bukan bikin
  /// seluruh app force-close.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
