import 'package:flutter/foundation.dart';
import '../../data/local/secure_session_storage.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/usecases/subscribe_premium_usecase.dart';

enum PaymentFlowStatus { initial, creatingPayment, awaitingConfirmation, success, failed }

/// Provider yang mengorkestrasi alur checkout langganan:
/// buat transaksi -> tunggu konfirmasi -> update status langganan
/// di secure storage (CPMK 4) begitu pembayaran berhasil.
class PaymentProvider extends ChangeNotifier {
  final SubscribePremiumUseCase _useCase;
  final SecureSessionStorage _secureStorage;

  PaymentProvider(this._useCase, this._secureStorage);

  PaymentFlowStatus status = PaymentFlowStatus.initial;
  PaymentResult? lastResult;
  String? errorMessage;

  Future<void> subscribe({required String planId, required String planName, required int amount}) async {
    status = PaymentFlowStatus.creatingPayment;
    errorMessage = null;
    notifyListeners();

    final createResult = await _useCase.createPayment(planId: planId, planName: planName, amount: amount);

    final payment = createResult.when(
      success: (p) => p,
      failure: (f) {
        errorMessage = f.message;
        status = PaymentFlowStatus.failed;
        return null;
      },
    );
    if (payment == null) {
      notifyListeners();
      return;
    }

    status = PaymentFlowStatus.awaitingConfirmation;
    lastResult = payment;
    notifyListeners();

    final statusResult = await _useCase.checkStatus(payment.paymentId);

    statusResult.when(
      success: (updated) async {
        final finalResult = payment.copyWith(status: updated.status);
        lastResult = finalResult;

        if (updated.status == PaymentStatus.success) {
          status = PaymentFlowStatus.success;
          await _secureStorage.saveSubscriptionStatus(true);
        } else {
          status = PaymentFlowStatus.failed;
          errorMessage = 'Pembayaran ditolak oleh penyedia. Coba metode lain.';
        }
      },
      failure: (f) {
        errorMessage = f.message;
        status = PaymentFlowStatus.failed;
      },
    );

    notifyListeners();
  }

  void reset() {
    status = PaymentFlowStatus.initial;
    lastResult = null;
    errorMessage = null;
    notifyListeners();
  }
}
