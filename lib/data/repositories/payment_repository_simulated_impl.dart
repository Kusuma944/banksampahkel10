import 'dart:math';
import '../../core/error/result.dart';
import '../../core/network/network_resilience.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/repositories/payment_repository.dart';

/// Implementasi SIMULASI dari [PaymentRepository] — meniru alur Midtrans
/// Snap API (buat transaksi -> polling status) tanpa benar-benar
/// menghubungi payment gateway sungguhan.
///
/// TODO (lanjutan CPMK 5): ganti class ini dengan panggilan REST nyata ke
/// Midtrans/Xendit sandbox. Karena sudah implement [PaymentRepository]
/// yang sama, tinggal ganti satu baris di main.dart — tidak ada
/// perubahan di domain/presentation layer sama sekali.
class PaymentRepositorySimulatedImpl implements PaymentRepository {
  final Random _random = Random();

  @override
  Future<Result<PaymentResult>> createSubscriptionPayment({
    required String planId,
    required String planName,
    required int amount,
  }) {
    return NetworkResilience.guard(() async {
      // Simulasi latensi memanggil API "create transaction" gateway asli.
      await Future.delayed(const Duration(milliseconds: 900));

      final paymentId = 'PAY-${DateTime.now().microsecondsSinceEpoch}';
      return PaymentResult(
        paymentId: paymentId,
        status: PaymentStatus.pending,
        amount: amount,
        planName: planName,
      );
    });
  }

  @override
  Future<Result<PaymentResult>> checkPaymentStatus(String paymentId) {
    return NetworkResilience.guard(() async {
      // Simulasi latensi polling status ke gateway (biasanya via webhook).
      await Future.delayed(const Duration(seconds: 2));

      // 90% berhasil, 10% gagal — supaya alur error handling di UI
      // juga bisa didemoin, bukan cuma jalur sukses melulu.
      final berhasil = _random.nextDouble() < 0.9;

      return PaymentResult(
        paymentId: paymentId,
        status: berhasil ? PaymentStatus.success : PaymentStatus.failed,
        amount: 0,
        planName: '',
      );
    });
  }
}
