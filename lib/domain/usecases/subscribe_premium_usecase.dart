import '../../core/error/result.dart';
import '../entities/payment_result.dart';
import '../repositories/payment_repository.dart';

class SubscribePremiumUseCase {
  final PaymentRepository repository;
  const SubscribePremiumUseCase(this.repository);

  Future<Result<PaymentResult>> createPayment({
    required String planId,
    required String planName,
    required int amount,
  }) {
    return repository.createSubscriptionPayment(planId: planId, planName: planName, amount: amount);
  }

  Future<Result<PaymentResult>> checkStatus(String paymentId) {
    return repository.checkPaymentStatus(paymentId);
  }
}
