import '../../core/error/result.dart';
import '../../core/error/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Validasi format sebelum request dikirim ke server — supaya user
/// dapat feedback instan tanpa perlu nunggu roundtrip jaringan.
class SignUpValidationException implements Exception {
  final String message;
  const SignUpValidationException(this.message);
  @override
  String toString() => message;
}

class SignUpWithEmailUseCase {
  final AuthRepository repository;
  const SignUpWithEmailUseCase(this.repository);

  final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  Future<Result<AppUser>> execute({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    if (namaLengkap.trim().isEmpty) {
      return const ResultFailure(UnknownFailure('Nama lengkap tidak boleh kosong.'));
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      return const ResultFailure(UnknownFailure('Format email tidak valid.'));
    }
    if (password.length < 8) {
      return const ResultFailure(UnknownFailure('Kata sandi minimal 8 karakter.'));
    }

    return repository.signUpWithEmail(
      email: email.trim(),
      password: password,
      namaLengkap: namaLengkap.trim(),
    );
  }
}
