/// Model transaksi setoran sampah nasabah.
/// Untuk prototype Milestone 1, data masih dummy/statis (belum dari backend).
class WasteTransaction {
  final String jenisSampah;
  final double beratKg;
  final int nilaiRupiah;
  final DateTime tanggal;

  const WasteTransaction({
    required this.jenisSampah,
    required this.beratKg,
    required this.nilaiRupiah,
    required this.tanggal,
  });
}

/// Model sederhana data nasabah bank sampah.
class Nasabah {
  final String nama;
  final int saldo;
  final double totalKgTersetor;

  const Nasabah({
    required this.nama,
    required this.saldo,
    required this.totalKgTersetor,
  });
}

/// Data dummy sementara untuk kebutuhan prototype tampilan.
final Nasabah dummyNasabah = Nasabah(
  nama: 'Bu Sri Wahyuni',
  saldo: 87500,
  totalKgTersetor: 23.4,
);

final List<WasteTransaction> dummyRiwayat = [
  WasteTransaction(
    jenisSampah: 'Botol Plastik PET',
    beratKg: 3.2,
    nilaiRupiah: 9600,
    tanggal: DateTime(2026, 8, 18),
  ),
  WasteTransaction(
    jenisSampah: 'Kardus',
    beratKg: 5.0,
    nilaiRupiah: 7500,
    tanggal: DateTime(2026, 8, 14),
  ),
  WasteTransaction(
    jenisSampah: 'Kaleng Aluminium',
    beratKg: 1.1,
    nilaiRupiah: 8800,
    tanggal: DateTime(2026, 8, 10),
  ),
  WasteTransaction(
    jenisSampah: 'Botol Kaca',
    beratKg: 4.5,
    nilaiRupiah: 4500,
    tanggal: DateTime(2026, 8, 5),
  ),
  WasteTransaction(
    jenisSampah: 'Kertas Bekas',
    beratKg: 2.8,
    nilaiRupiah: 2800,
    tanggal: DateTime(2026, 8, 1),
  ),
];
