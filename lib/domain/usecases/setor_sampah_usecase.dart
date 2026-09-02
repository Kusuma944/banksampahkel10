import '../entities/waste_transaction.dart';
import '../repositories/waste_repository.dart';

/// Exception khusus untuk kegagalan validasi di business logic.
/// Dipisah dari Exception generik supaya UI bisa membedakan jenis error.
class SetorSampahException implements Exception {
  final String message;
  const SetorSampahException(this.message);

  @override
  String toString() => message;
}

/// Use case: memproses satu transaksi setor sampah.
///
/// Ini murni business logic — tidak import apapun dari Flutter.
/// Bisa di-unit-test tanpa perlu menjalankan aplikasi sama sekali.
class SetorSampahUseCase {
  final WasteRepository repository;

  const SetorSampahUseCase(this.repository);

  /// Memvalidasi input, lalu memanggil repository untuk menyimpan setoran.
  /// Melempar [SetorSampahException] kalau input tidak valid.
  Future<WasteTransaction> execute({
    required JenisSampah jenis,
    required double beratKg,
  }) async {
    if (beratKg <= 0) {
      throw const SetorSampahException('Berat sampah harus lebih dari 0 kg.');
    }
    if (beratKg > 500) {
      throw const SetorSampahException(
        'Berat sampah tidak wajar untuk satu kali setor (maks 500 kg).',
      );
    }

    return repository.setorSampah(jenis: jenis, beratKg: beratKg);
  }

  /// Helper murni: menghitung estimasi nilai rupiah dari jenis & berat,
  /// dipisah dari `execute` supaya gampang di-unit-test satuan.
  int hitungNilai({required JenisSampah jenis, required double beratKg}) {
    return (jenis.hargaPerKg * beratKg).round();
  }
}
