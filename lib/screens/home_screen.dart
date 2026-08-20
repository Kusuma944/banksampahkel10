import 'package:flutter/material.dart';
import '../models/waste_transaction.dart';
import '../theme/app_theme.dart';

/// Home screen — menampilkan info nasabah, saldo, dan riwayat setoran sampah.
/// Data masih dummy, belum terhubung backend (sesuai lingkup Milestone 1).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context) {
    final nasabah = dummyNasabah;
    final riwayat = dummyRiwayat;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoBank'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Halo, ${nasabah.nama} 👋',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Kartu saldo
          Card(
            color: AppTheme.primaryGreen,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Tabungan Sampah',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatRupiah(nasabah.saldo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.eco, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${nasabah.totalKgTersetor.toStringAsFixed(1)} kg sampah tersetor',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Riwayat Setoran Terakhir',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final item = riwayat[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.lightGreen,
                    child: Icon(Icons.recycling, color: AppTheme.primaryGreen),
                  ),
                  title: Text(item.jenisSampah),
                  subtitle: Text(
                    '${item.beratKg.toStringAsFixed(1)} kg • ${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}',
                  ),
                  trailing: Text(
                    '+${_formatRupiah(item.nilaiRupiah)}',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur setor sampah baru: coming soon 🔜')),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Setor Sampah'),
      ),
    );
  }
}
