import '../../core/error/result.dart';
import '../../core/error/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;
  const SignInWithEmailUseCase(this.repository);

  Future<Result<AppUser>> execute({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const ResultFailure(UnknownFailure('Email dan kata sandi wajib diisi.'));
    }
    return repository.signInWithEmail(email: email.trim(), password: password);
  }
}
