import '../../core/error/result.dart';
import '../entities/payment_result.dart';

/// Kontrak abstrak Payment Gateway. Dibuat menyerupai alur nyata
/// Midtrans/Xendit Snap: (1) buat transaksi -> dapat payment ID,
/// (2) cek status pembayaran (biasanya lewat polling atau webhook).
///
/// Ganti [PaymentRepositorySimulatedImpl] dengan implementasi Midtrans/
/// Xendit sungguhan nanti — domain & presentation TIDAK perlu diubah.
abstract class PaymentRepository {
  Future<Result<PaymentResult>> createSubscriptionPayment({
    required String planId,
    required String planName,
    required int amount,
  });

  Future<Result<PaymentResult>> checkPaymentStatus(String paymentId);
}
