import '../entities/waste_transaction.dart';

/// Kontrak (interface) untuk sumber data transaksi sampah.
/// Layer domain hanya tahu kontrak ini — tidak tahu apakah datanya
/// dari dummy, database lokal, atau API sungguhan.
abstract class WasteRepository {
  /// Menyimpan satu transaksi setoran sampah, mengembalikan transaksi
  /// yang sudah tersimpan (misal dengan nilai rupiah terhitung).
  Future<WasteTransaction> setorSampah({
    required JenisSampah jenis,
    required double beratKg,
  });

  /// Mengambil saldo nasabah saat ini.
  Future<int> getSaldo();
}
