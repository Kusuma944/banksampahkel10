import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/payment_result.dart';
import '../providers/payment_provider.dart';

class _Plan {
  final String id;
  final String name;
  final int price;
  final String period;
  const _Plan({required this.id, required this.name, required this.price, required this.period});
}

const _plans = [
  _Plan(id: 'premium_bulanan', name: 'Premium Bulanan', price: 15000, period: '/bulan'),
  _Plan(id: 'premium_tahunan', name: 'Premium Tahunan', price: 150000, period: '/tahun'),
];

/// Halaman checkout langganan — mendemonstrasikan alur Payment Gateway
/// (disimulasikan, arsitektur siap disambung ke Midtrans/Xendit asli)
/// lewat state Initial -> Creating Payment -> Awaiting Confirmation ->
/// Success/Failed.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  _Plan _selectedPlan = _plans.first;

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentProvider>();
    final isProcessing = payment.status == PaymentFlowStatus.creatingPayment ||
        payment.status == PaymentFlowStatus.awaitingConfirmation;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Langganan Premium')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Paket', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            ..._plans.map((plan) {
              final selected = plan.id == _selectedPlan.id;
              return GestureDetector(
                onTap: isProcessing ? null : () => setState(() => _selectedPlan = plan),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: selected ? AppTheme.primaryGreen : Colors.black12, width: selected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selected ? AppTheme.primaryGreen : Colors.black38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              '${_formatRupiah(plan.price)}${plan.period}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            if (payment.status == PaymentFlowStatus.creatingPayment)
              const _StatusCard(
                icon: Icons.hourglass_top_rounded,
                color: AppTheme.primaryGreen,
                text: 'Membuat transaksi pembayaran...',
              )
            else if (payment.status == PaymentFlowStatus.awaitingConfirmation)
              const _StatusCard(
                icon: Icons.sync_rounded,
                color: AppTheme.primaryGreen,
                text: 'Menunggu konfirmasi dari penyedia pembayaran...',
              )
            else if (payment.status == PaymentFlowStatus.success)
              _StatusCard(
                icon: Icons.check_circle_rounded,
                color: AppTheme.primaryGreen,
                text: 'Pembayaran berhasil! Langganan ${payment.lastResult?.planName ?? ''} aktif.',
              )
            else if (payment.status == PaymentFlowStatus.failed)
              _StatusCard(
                icon: Icons.error_rounded,
                color: const Color(0xFFC62828),
                text: payment.errorMessage ?? 'Pembayaran gagal.',
              ),

            if (payment.status == PaymentFlowStatus.creatingPayment ||
                payment.status == PaymentFlowStatus.awaitingConfirmation)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
              ),

            const Spacer(),

            if (payment.status == PaymentFlowStatus.success)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Selesai'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          context.read<PaymentProvider>().subscribe(
                                planId: _selectedPlan.id,
                                planName: _selectedPlan.name,
                                amount: _selectedPlan.price,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isProcessing
                        ? 'Memproses...'
                        : 'Bayar ${_formatRupiah(_selectedPlan.price)}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _StatusCard({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}
