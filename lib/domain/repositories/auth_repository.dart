import '../../core/error/result.dart';
import '../entities/app_user.dart';

/// Kontrak abstrak untuk autentikasi cloud (CPMK 5).
/// Layer domain hanya tahu ini — tidak tahu apakah di baliknya
/// Supabase, Firebase Auth, atau provider lain.
abstract class AuthRepository {
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String namaLengkap,
  });

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<void>> signOut();

  /// User yang sedang login saat ini, null kalau belum ada sesi.
  AppUser? get currentUser;
}
