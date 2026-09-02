import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/waste_transaction.dart';
import '../providers/setor_sampah_provider.dart';
import '../providers/transaksi_provider.dart';

/// Screen Setor Sampah — mendemonstrasikan alur state
/// Initial -> Loading -> Success -> Error lewat Provider.
///
/// Widget ini TIDAK menghitung nilai rupiah atau validasi sendiri;
/// semua itu didelegasikan ke SetorSampahProvider (yang memanggil
/// SetorSampahUseCase di layer domain). Widget cuma menampilkan UI
/// sesuai status yang sedang aktif.
class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});

  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen> {
  JenisSampah _jenisTerpilih = JenisSampah.plastik;
  final TextEditingController _beratController = TextEditingController();

  @override
  void dispose() {
    _beratController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SetorSampahProvider>();
    final isOnline = context.watch<TransaksiProvider>().isOnline;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Setor Sampah')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOnline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off_rounded, color: Color(0xFF8A6D3B), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sedang offline — setoran tetap bisa dilakukan, akan disinkron nanti.',
                        style: TextStyle(color: Color(0xFF8A6D3B), fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            const Text('Jenis Sampah', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<JenisSampah>(
              initialValue: _jenisTerpilih,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: JenisSampah.values
                  .map((j) => DropdownMenuItem(
                        value: j,
                        child: Text('${j.namaTampilan} (Rp ${j.hargaPerKg}/kg)'),
                      ))
                  .toList(),
              onChanged: provider.status == SetorSampahStatus.loading
                  ? null
                  : (value) {
                      if (value != null) setState(() => _jenisTerpilih = value);
                    },
            ),
            const SizedBox(height: 16),
            const Text('Berat (kg)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _beratController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: provider.status != SetorSampahStatus.loading,
              decoration: InputDecoration(
                hintText: 'Contoh: 2.5',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),

            // --- Bagian ini yang mendemonstrasikan state Initial/Loading/Success/Error ---
            if (provider.status == SetorSampahStatus.loading)
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),

            if (provider.status == SetorSampahStatus.error)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4E4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage ?? 'Terjadi kesalahan.',
                        style: const TextStyle(color: Color(0xFFC62828), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            if (provider.status == SetorSampahStatus.success && provider.lastTransaction != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryGreen.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.lastTransaction!.synced
                            ? 'Berhasil! +Rp ${provider.lastTransaction!.nilaiRupiah} tersimpan & tersinkron.'
                            : 'Tersimpan lokal (offline). Akan disinkron otomatis saat online.',
                        style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.status == SetorSampahStatus.loading
                    ? null
                    : () async {
                        final berat = double.tryParse(_beratController.text.replaceAll(',', '.')) ?? 0;
                        await context.read<SetorSampahProvider>().setorSampah(
                              jenis: _jenisTerpilih,
                              beratKg: berat,
                            );
                        // Setoran disimpan lokal (Hive) apapun status koneksinya —
                        // refresh di sini supaya Beranda langsung menampilkan data terbaru.
                        if (context.mounted) {
                          await context.read<TransaksiProvider>().refresh();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  provider.status == SetorSampahStatus.loading ? 'Memproses...' : 'Setor Sekarang',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
