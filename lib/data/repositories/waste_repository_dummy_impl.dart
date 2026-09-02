import '../../domain/entities/waste_transaction.dart';
import '../../domain/repositories/waste_repository.dart';

/// Implementasi dummy dari [WasteRepository] — simpan di memory saja
/// (TIDAK persistent, hilang saat app ditutup).
///
/// Dipertahankan sebagai contoh konkret "dependency inversion": UI dan
/// use case tidak berubah sama sekali walau repository-nya diganti dari
/// ini ke [WasteRepositoryHiveImpl] yang persistent. Untuk kebutuhan
/// CPMK 4 (persistent + offline-first), gunakan WasteRepositoryHiveImpl.
class WasteRepositoryDummyImpl implements WasteRepository {
  int _saldo = 87500;
  final List<WasteTransaction> _riwayat = [];

  @override
  Future<WasteTransaction> setorSampah({
    required JenisSampah jenis,
    required double beratKg,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final nilai = (jenis.hargaPerKg * beratKg).round();
    final transaksi = WasteTransaction(
      jenisSampah: jenis.namaTampilan,
      beratKg: beratKg,
      nilaiRupiah: nilai,
      tanggal: DateTime.now(),
      synced: true, // tidak relevan untuk implementasi in-memory
    );

    _riwayat.add(transaksi);
    _saldo += nilai;

    return transaksi;
  }

  @override
  Future<int> getSaldo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _saldo;
  }

  @override
  Future<List<WasteTransaction>> getRiwayat() async => List.unmodifiable(_riwayat);

  @override
  Future<int> getPendingSyncCount() async => 0; // in-memory selalu "tersinkron"

  @override
  Future<void> syncPendingTransactions() async {
    // Tidak ada apa-apa untuk disinkron pada implementasi in-memory.
  }
}
