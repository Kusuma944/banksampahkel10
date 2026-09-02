import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/waste_transaction.dart';
import '../presentation/screens/setor_sampah_screen.dart';

/// Home screen (Beranda) — kartu saldo, dampak lingkungan, aktivitas terakhir,
/// dan bottom navigation 5 tab. Sesuai desain Figma.
/// Data masih dummy, belum terhubung backend (sesuai lingkup Milestone 1).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

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
    final nasabah = dummyNasabah;
    final riwayat = dummyRiwayat;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: const Icon(Icons.menu),
        title: const Text(
          'EcoBank',
          style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.credit_card_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // Banner offline
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.cloud_off_rounded, color: Color(0xFFC62828), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Koneksi terputus. Menampilkan data tersimpan.',
                    style: TextStyle(color: Color(0xFFC62828), fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Kartu saldo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), AppTheme.primaryGreen],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('Update: 12 Okt, 08:45',
                        style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _formatRupiah(nasabah.saldo),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 16),
                    SizedBox(width: 4),
                    Text('+Rp 50.000 (Bulan ini)',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 12.5)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Dampak Lingkungan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text('Update: 12 Okt', style: TextStyle(color: Colors.black45, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ImpactCard(
                  icon: Icons.delete_outline_rounded,
                  value: '124 kg',
                  label: 'Sampah Diselamatkan',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImpactCard(
                  icon: Icons.co2_outlined,
                  value: '45 kg',
                  label: 'Reduksi Emisi',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Butuh koneksi internet untuk setor sampah')),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_circle_outline, color: Colors.black45),
              label: const Text('Setor Sampah (Butuh Koneksi)', style: TextStyle(color: Colors.black54)),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Aktivitas Terakhir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          ...riwayat.take(2).map((item) {
            final isSetor = item.nilaiRupiah > 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.secondaryGreen.withOpacity(0.3),
                    child: Icon(
                      isSetor ? Icons.recycling : Icons.shopping_bag_outlined,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.jenisSampah, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        const SizedBox(height: 2),
                        Text(
                          '${item.tanggal.day.toString().padLeft(2, '0')} Okt ${item.tanggal.year}, 14:20',
                          style: const TextStyle(color: Colors.black45, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isSetor ? '+' : '-'}${_formatRupiah(item.nilaiRupiah)}',
                        style: TextStyle(
                          color: isSetor ? AppTheme.primaryGreen : const Color(0xFFC62828),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryGreen.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Selesai', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Menampilkan data tersimpan. Hubungkan ke internet untuk memuat riwayat lengkap.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 11.5),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) {
          setState(() => _selectedTab = i);
          if (i == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SetorSampahScreen()),
            );
            // Kembalikan tab terpilih ke Beranda setelah user keluar dari SetorSampahScreen.
            setState(() => _selectedTab = 0);
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryGreen.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppTheme.primaryGreen), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.recycling_outlined), label: 'Setor'),
          NavigationDestination(icon: Icon(Icons.sell_outlined), label: 'Harga'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Aktivitas'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ImpactCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.secondaryGreen.withOpacity(0.3),
            child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11.5)),
        ],
      ),
    );
  }
}
