import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/network/network_resilience.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementasi [AuthRepository] memakai Supabase Auth (GoTrue) —
/// SDK cloud sungguhan, bukan simulasi. Membutuhkan [SupabaseConfig]
/// sudah diisi (lihat CLOUD_SETUP.md).
class AuthRepositorySupabaseImpl implements AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Redirect URL untuk OAuth (Google Sign-In) kembali ke app setelah
  /// login di browser. Harus didaftarkan juga di Supabase Dashboard ->
  /// Authentication -> URL Configuration.
  static const String googleRedirectUrl = 'io.supabase.ecobanksampah://login-callback';

  Result<T> _notConfiguredFailure<T>() {
    return const ResultFailure(
      NetworkFailure('Supabase belum dikonfigurasi. Isi SupabaseConfig.url & anonKey terlebih dahulu.'),
    );
  }

  @override
  AppUser? get currentUser {
    if (!SupabaseConfig.isConfigured) return null;
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      namaLengkap: user.userMetadata?['nama_lengkap'] as String?,
    );
  }

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    if (!SupabaseConfig.isConfigured) return _notConfiguredFailure();

    return NetworkResilience.guard(() async {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'nama_lengkap': namaLengkap},
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Pendaftaran gagal. Coba lagi.');
      }
      return AppUser(id: user.id, email: user.email ?? email, namaLengkap: namaLengkap);
    });
  }

  @override
  Future<Result<AppUser>> signInWithEmail({required String email, required String password}) async {
    if (!SupabaseConfig.isConfigured) return _notConfiguredFailure();

    return NetworkResilience.guard(() async {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      final user = response.user;
      if (user == null) {
        throw const AuthException('Email atau kata sandi salah.');
      }
      return AppUser(
        id: user.id,
        email: user.email ?? email,
        namaLengkap: user.userMetadata?['nama_lengkap'] as String?,
      );
    });
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    if (!SupabaseConfig.isConfigured) return _notConfiguredFailure();

    return NetworkResilience.guard(() async {
      final started = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: googleRedirectUrl,
      );
      if (!started) {
        throw const AuthException('Google Sign-In dibatalkan.');
      }
      // Setelah redirect kembali dari browser, Supabase SDK otomatis
      // mengisi currentUser lewat deep link — di sinilah kita baca hasilnya.
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('Gagal mengambil data akun Google.');
      }
      return AppUser(
        id: user.id,
        email: user.email ?? '',
        namaLengkap: user.userMetadata?['full_name'] as String?,
      );
    }, timeout: const Duration(seconds: 60)); // OAuth butuh waktu user login di browser
  }

  @override
  Future<Result<void>> signOut() async {
    if (!SupabaseConfig.isConfigured) return _notConfiguredFailure();
    return NetworkResilience.guard(() => _client.auth.signOut());
  }
}
