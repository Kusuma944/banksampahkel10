import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'login_screen.dart';

class _OnboardData {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardData({required this.icon, required this.title, required this.description});
}

const List<_OnboardData> _pages = [
  _OnboardData(
    icon: Icons.delete_sweep_rounded,
    title: 'Pilah Sampahmu',
    description:
        'Mulailah dengan memisahkan jenis sampah yang dapat didaur ulang. '
        'Setiap kontribusi Anda dihitung dengan presisi finansial untuk masa depan yang lebih baik.',
  ),
  _OnboardData(
    icon: Icons.trending_up_rounded,
    title: 'Dapatkan Nilai & Dampak',
    description:
        'Pantau pertumbuhan Saldo Eco Anda dan lihat langsung kontribusi nyata terhadap lingkungan.',
  ),
  _OnboardData(
    icon: Icons.location_on_rounded,
    title: 'Setor dengan Mudah',
    description:
        'Pilih lokasi drop-point terdekat atau jadwalkan penjemputan sampah langsung dari rumah Anda dengan mudah.',
  ),
];

/// Onboarding — 3 slide perkenalan fitur, sesuai desain Figma.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _goToLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.secondaryGreen.withOpacity(0.2),
                          ),
                          child: Icon(page.icon, size: 88, color: AppTheme.primaryGreen),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _goToLogin,
                    child: const Text('Lewati', style: TextStyle(color: Colors.black54)),
                  ),
                  Row(
                    children: List.generate(_pages.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? AppTheme.primaryGreen : Colors.black12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  ElevatedButton.icon(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: Text(_currentPage == _pages.length - 1 ? 'Mulai Sekarang' : 'Lanjut'),
                    label: const Icon(Icons.arrow_forward, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
