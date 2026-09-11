enum PaymentStatus { pending, success, failed }

/// Entity domain untuk hasil transaksi pembayaran (langganan premium).
/// Bentuknya sengaja mirip response Payment Gateway asli (Midtrans/Xendit)
/// supaya gampang diganti tanpa mengubah domain/presentation layer.
class PaymentResult {
  final String paymentId;
  final PaymentStatus status;
  final int amount;
  final String planName;

  const PaymentResult({
    required this.paymentId,
    required this.status,
    required this.amount,
    required this.planName,
  });

  PaymentResult copyWith({PaymentStatus? status}) {
    return PaymentResult(
      paymentId: paymentId,
      status: status ?? this.status,
      amount: amount,
      planName: planName,
    );
  }
}
