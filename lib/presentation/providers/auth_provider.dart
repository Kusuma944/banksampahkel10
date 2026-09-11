import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';

enum AuthStatus { initial, loading, success, error }

/// Provider yang menjembatani UI (Login/Register screen) dengan
/// autentikasi cloud. Semua use case dipanggil lewat sini, UI tinggal
/// dengarkan [status] untuk tahu kapan tampilkan spinner/error/lanjut.
class AuthProvider extends ChangeNotifier {
  final SignUpWithEmailUseCase _signUpUseCase;
  final SignInWithEmailUseCase _signInUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthProvider({
    required SignUpWithEmailUseCase signUpUseCase,
    required SignInWithEmailUseCase signInUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signOutUseCase = signOutUseCase;

  AuthStatus status = AuthStatus.initial;
  AppUser? user;
  String? errorMessage;

  Future<bool> signUp({required String email, required String password, required String namaLengkap}) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _signUpUseCase.execute(email: email, password: password, namaLengkap: namaLengkap);
    return result.when(
      success: (appUser) {
        user = appUser;
        status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      failure: (f) {
        errorMessage = f.message;
        status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> signIn({required String email, required String password}) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _signInUseCase.execute(email: email, password: password);
    return result.when(
      success: (appUser) {
        user = appUser;
        status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      failure: (f) {
        errorMessage = f.message;
        status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _signInWithGoogleUseCase.execute();
    return result.when(
      success: (appUser) {
        user = appUser;
        status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      failure: (f) {
        errorMessage = f.message;
        status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> signOut() async {
    await _signOutUseCase.execute();
    user = null;
    status = AuthStatus.initial;
    notifyListeners();
  }
}
