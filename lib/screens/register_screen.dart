import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../data/local/secure_session_storage.dart';
import '../presentation/providers/auth_provider.dart';
import 'home_screen.dart';

/// Daftar Akun — form nama, telepon, email, kata sandi. Sesuai desain Figma.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreed = false;

  Future<void> _handleBuatAkun() async {
    final auth = context.read<AuthProvider>();
    final nama = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final berhasilCloud = await auth.signUp(email: email, password: password, namaLengkap: nama);

    if (!mounted) return;

    if (berhasilCloud && auth.user != null) {
      // Sign up cloud (Supabase) berhasil — simpan juga ke secure storage
      // lokal (CPMK 4) supaya sesi tetap persistent lintas restart app.
      await SecureSessionStorage().saveSession(
        token: auth.user!.id,
        namaNasabah: nama.isEmpty ? 'Nasabah EcoBank' : nama,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }

    final belumDikonfigurasi = auth.errorMessage?.contains('belum dikonfigurasi') ?? false;
    if (belumDikonfigurasi) {
      // Supabase belum di-setup kelompok — jangan blokir demo milestone
      // sebelumnya. Tetap daftar secara lokal saja, kasih tahu dengan jelas.
      final simulatedToken = 'local_${DateTime.now().microsecondsSinceEpoch}';
      await SecureSessionStorage().saveSession(
        token: simulatedToken,
        namaNasabah: nama.isEmpty ? 'Nasabah EcoBank' : nama,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supabase belum terhubung — akun tersimpan lokal saja. Lihat CLOUD_SETUP.md')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }

    // Error sungguhan (email sudah dipakai, password lemah, tidak ada
    // internet, dst) — tampilkan pesannya, JANGAN lanjut ke Beranda.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.errorMessage ?? 'Pendaftaran gagal. Coba lagi.')),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            prefixIcon: Icon(icon, size: 20, color: Colors.black45),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF2F4F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'EcoBank',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bergabunglah dan kelola kontribusi lingkungan Anda.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    _buildField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                      hint: 'Masukkan nama lengkap Anda',
                      icon: Icons.person_outline,
                    ),
                    _buildField(
                      label: 'Nomor Telepon',
                      controller: _phoneController,
                      hint: 'Contoh: 081234567890',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'alamat@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      label: 'Kata Sandi',
                      controller: _passwordController,
                      hint: 'Minimal 8 karakter',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: Colors.black45,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: AppTheme.primaryGreen,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: Colors.black54, fontSize: 12.5),
                                children: [
                                  TextSpan(text: 'Saya menyetujui '),
                                  TextSpan(
                                    text: 'Syarat dan Ketentuan',
                                    style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(text: ' serta '),
                                  TextSpan(
                                    text: 'Kebijakan Privasi',
                                    style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleBuatAkun,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Buat Akun →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                    children: [
                      TextSpan(text: 'Sudah punya akun? '),
                      TextSpan(
                        text: 'Masuk',
                        style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
