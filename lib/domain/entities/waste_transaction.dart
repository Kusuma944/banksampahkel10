/// Entity domain — representasi murni data transaksi setor sampah.
/// Tidak bergantung pada Flutter/UI, cuma Dart plain object.
class WasteTransaction {
  final String jenisSampah;
  final double beratKg;
  final int nilaiRupiah;
  final DateTime tanggal;

  /// Status sinkronisasi ke server. `false` berarti transaksi ini dibuat
  /// saat offline dan masih menunggu disinkron begitu koneksi kembali.
  /// Default `true` supaya kode lama (yang belum peduli offline-first)
  /// tetap kompatibel tanpa perlu diubah.
  final bool synced;

  const WasteTransaction({
    required this.jenisSampah,
    required this.beratKg,
    required this.nilaiRupiah,
    required this.tanggal,
    this.synced = true,
  });
}

/// Jenis sampah yang didukung, beserta harga per kg (dalam Rupiah).
/// Untuk prototype, harga masih hardcode — nanti bisa dipindah ke remote config/API.
enum JenisSampah {
  plastik(namaTampilan: 'Plastik', hargaPerKg: 3000),
  kertas(namaTampilan: 'Kertas', hargaPerKg: 1000),
  kaca(namaTampilan: 'Botol Kaca', hargaPerKg: 1000),
  logam(namaTampilan: 'Logam/Kaleng', hargaPerKg: 8000);

  final String namaTampilan;
  final int hargaPerKg;
  const JenisSampah({required this.namaTampilan, required this.hargaPerKg});
}
