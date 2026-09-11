import '../entities/waste_transaction.dart';

/// Kontrak (interface) untuk sumber data transaksi sampah.
/// Layer domain hanya tahu kontrak ini — tidak tahu apakah datanya
/// dari dummy, Hive, atau API sungguhan.
abstract class WasteRepository {
  /// Menyimpan satu transaksi setoran sampah SECARA LOKAL terlebih dahulu
  /// (offline-first). Kalau saat itu ada koneksi, implementasi boleh
  /// langsung mencoba sinkron; kalau tidak, transaksi ditandai belum sinkron.
  Future<WasteTransaction> setorSampah({
    required JenisSampah jenis,
    required double beratKg,
  });

  /// Mengambil saldo nasabah saat ini (dihitung dari data lokal).
  Future<int> getSaldo();

  /// Mengambil seluruh riwayat transaksi tersimpan secara lokal,
  /// terurut dari yang terbaru. Harus tetap bisa dipanggil tanpa internet.
  Future<List<WasteTransaction>> getRiwayat();

  /// Jumlah transaksi yang masih menunggu disinkron ke server.
  Future<int> getPendingSyncCount();

  /// Mencoba mensinkronkan semua transaksi yang masih `synced: false`.
  /// Dipanggil otomatis saat koneksi internet kembali tersedia.
  Future<void> syncPendingTransactions();
}
