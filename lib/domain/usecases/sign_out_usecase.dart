import '../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;
  const SignOutUseCase(this.repository);

  Future<Result<void>> execute() => repository.signOut();
}
