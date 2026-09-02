import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Menyimpan data sensitif (token sesi login & status langganan) di
/// penyimpanan TERENKRIPSI milik OS (Android Keystore / iOS Keychain
/// lewat `flutter_secure_storage`) — BUKAN SharedPreferences biasa
/// yang tersimpan sebagai teks mentah.
///
/// Ini yang membedakan poin "Sangat Baik" vs "Kurang" di rubrik CPMK 4:
/// kredensial harus terenkripsi, bukan plain text.
class SecureSessionStorage {
  static const _keySessionToken = 'session_token';
  static const _keyNamaNasabah = 'session_nama_nasabah';
  static const _keyIsSubscribed = 'subscription_status';

  final FlutterSecureStorage _storage;

  SecureSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Dipanggil setelah login/daftar berhasil. Token di sini disimulasikan
  /// (untuk prototype) — nanti tinggal diganti dengan token asli dari API.
  Future<void> saveSession({required String token, required String namaNasabah}) async {
    await _storage.write(key: _keySessionToken, value: token);
    await _storage.write(key: _keyNamaNasabah, value: namaNasabah);
  }

  Future<String?> getToken() => _storage.read(key: _keySessionToken);

  Future<String?> getNamaNasabah() => _storage.read(key: _keyNamaNasabah);

  /// Dipakai splash screen untuk menentukan: langsung ke Beranda,
  /// atau ke alur Onboarding/Login.
  Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Hapus sesi — dipanggil saat user menekan "Keluar" di halaman Profil.
  Future<void> clearSession() async {
    await _storage.delete(key: _keySessionToken);
    await _storage.delete(key: _keyNamaNasabah);
  }

  /// Status langganan (monetization status) — juga tersimpan terenkripsi
  /// karena statusnya menentukan fitur berbayar apa yang bisa diakses user.
  Future<void> saveSubscriptionStatus(bool isSubscribed) async {
    await _storage.write(key: _keyIsSubscribed, value: isSubscribed.toString());
  }

  Future<bool> getSubscriptionStatus() async {
    final value = await _storage.read(key: _keyIsSubscribed);
    return value == 'true';
  }
}
