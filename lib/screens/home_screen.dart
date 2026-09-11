import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/waste_transaction.dart' show dummyNasabah;
import '../presentation/providers/transaksi_provider.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/setor_sampah_screen.dart';

/// Home screen (Beranda) — kartu saldo, dampak lingkungan, aktivitas terakhir
/// (persistent lewat Hive), dan bottom navigation 5 tab.
///
/// CPMK 4: banner & daftar aktivitas di sini dibaca dari [TransaksiProvider],
/// yang di baliknya membaca langsung dari disk lokal (Hive) — jadi tetap
/// bisa ditampilkan walau HP dalam mode pesawat / tanpa internet.
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
    final transaksi = context.watch<TransaksiProvider>();
    // Saldo awal (dummy) + total nilai dari transaksi persistent (Hive).
    final totalSaldo = dummyNasabah.saldo + transaksi.saldo;

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
      body: RefreshIndicator(
        onRefresh: transaksi.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            // Banner status koneksi & sinkronisasi — DINAMIS, bukan statis lagi.
            if (!transaksi.isOnline)
              _StatusBanner(
                color: const Color(0xFFFCE4E4),
                textColor: const Color(0xFFC62828),
                icon: Icons.cloud_off_rounded,
                text: 'Koneksi terputus. Menampilkan data tersimpan.',
              )
            else if (transaksi.pendingSyncCount > 0)
              _StatusBanner(
                color: const Color(0xFFFFF3CD),
                textColor: const Color(0xFF8A6D3B),
                icon: Icons.sync_rounded,
                text: 'Menyinkronkan ${transaksi.pendingSyncCount} transaksi...',
              ),
            if (!transaksi.isOnline || transaksi.pendingSyncCount > 0)
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
                    children: [
                      const Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(
                        transaksi.isOnline ? 'Tersinkron' : 'Data Lokal',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatRupiah(totalSaldo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${_formatRupiah(transaksi.saldo)} dari setoran tersimpan',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12.5),
                      ),
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
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetorSampahScreen()),
                  );
                  if (context.mounted) await transaksi.refresh();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
                // Sengaja TIDAK menulis "Butuh Koneksi" — inti offline-first
                // justru setor sampah tetap bisa dilakukan tanpa internet.
                label: const Text('Setor Sampah Baru', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 24),
            const Text('Aktivitas Terakhir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            if (transaksi.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
              )
            else if (transaksi.riwayat.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Belum ada aktivitas. Coba setor sampah pertamamu!',
                    style: TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ),
              )
            else
              ...transaksi.riwayat.take(5).map((item) {
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
                        child: const Icon(Icons.recycling, color: AppTheme.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.jenisSampah, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            const SizedBox(height: 2),
                            Text(
                              '${item.beratKg} kg • ${item.tanggal.day.toString().padLeft(2, '0')}/${item.tanggal.month}/${item.tanggal.year}',
                              style: const TextStyle(color: Colors.black45, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${_formatRupiah(item.nilaiRupiah)}',
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item.synced ? AppTheme.secondaryGreen : Colors.orange).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.synced ? 'Tersinkron' : 'Belum Sinkron',
                              style: TextStyle(
                                fontSize: 10,
                                color: item.synced ? AppTheme.primaryGreen : Colors.orange.shade800,
                              ),
                            ),
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
                'Data dibaca dari penyimpanan lokal — tetap tersedia tanpa internet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black38, fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) async {
          setState(() => _selectedTab = i);
          if (i == 1) {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SetorSampahScreen()),
            );
            if (context.mounted) await transaksi.refresh();
            setState(() => _selectedTab = 0);
          } else if (i == 4) {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
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

class _StatusBanner extends StatelessWidget {
  final Color color;
  final Color textColor;
  final IconData icon;
  final String text;

  const _StatusBanner({
    required this.color,
    required this.textColor,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 12.5))),
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
