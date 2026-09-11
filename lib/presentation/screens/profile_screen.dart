import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/secure_session_storage.dart';
import '../../screens/login_screen.dart';
import '../providers/payment_provider.dart';
import 'subscription_screen.dart';

/// Halaman Profil — mendemonstrasikan siklus penuh Secure Storage (CPMK 4):
/// baca nama nasabah & status langganan (terenkripsi), toggle status
/// langganan (tertulis kembali terenkripsi), dan hapus sesi saat "Keluar".
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _secureStorage = SecureSessionStorage();

  bool _loading = true;
  String? _namaNasabah;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final nama = await _secureStorage.getNamaNasabah();
    final subscribed = await _secureStorage.getSubscriptionStatus();
    if (!mounted) return;
    setState(() {
      _namaNasabah = nama ?? 'Nasabah EcoBank';
      _isSubscribed = subscribed;
      _loading = false;
    });
  }

  Future<void> _toggleSubscription(bool value) async {
    if (!value) {
      // Berhenti berlangganan tidak butuh pembayaran — langsung update.
      await _secureStorage.saveSubscriptionStatus(false);
      if (!mounted) return;
      setState(() => _isSubscribed = false);
      return;
    }

    // Mengaktifkan langganan HARUS lewat alur pembayaran (CPMK 5),
    // bukan sekadar toggle switch langsung jadi true.
    context.read<PaymentProvider>().reset();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );

    if (result == true) {
      final subscribed = await _secureStorage.getSubscriptionStatus();
      if (!mounted) return;
      setState(() => _isSubscribed = subscribed);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Sesi login dan data yang tersimpan terenkripsi akan dihapus dari perangkat ini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFC62828))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _secureStorage.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.secondaryGreen.withOpacity(0.3),
                  child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  _namaNasabah ?? '-',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sesi tersimpan aman di perangkat ini (terenkripsi)',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSubscribed ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                        color: _isSubscribed ? AppTheme.primaryGreen : Colors.black38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Langganan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            Text(
                              _isSubscribed ? 'Aktif — akses fitur premium' : 'Nonaktif',
                              style: const TextStyle(color: Colors.black45, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isSubscribed,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: _toggleSubscription,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFC62828)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout, color: Color(0xFFC62828), size: 18),
                    label: const Text('Keluar', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
    );
  }
}
