import 'package:flutter_test/flutter_test.dart';
import 'package:ecobank_sampah/domain/entities/waste_transaction.dart';
import 'package:ecobank_sampah/domain/repositories/waste_repository.dart';
import 'package:ecobank_sampah/domain/usecases/setor_sampah_usecase.dart';

/// Fake repository untuk keperluan test — tidak menyentuh Flutter,
/// tidak menyentuh delay asli, supaya test cepat dan deterministik.
class _FakeWasteRepository implements WasteRepository {
  int saldo = 0;
  final List<WasteTransaction> _riwayat = [];

  @override
  Future<WasteTransaction> setorSampah({
    required JenisSampah jenis,
    required double beratKg,
  }) async {
    final nilai = (jenis.hargaPerKg * beratKg).round();
    saldo += nilai;
    final transaksi = WasteTransaction(
      jenisSampah: jenis.namaTampilan,
      beratKg: beratKg,
      nilaiRupiah: nilai,
      tanggal: DateTime(2026, 8, 27),
    );
    _riwayat.add(transaksi);
    return transaksi;
  }

  @override
  Future<int> getSaldo() async => saldo;

  @override
  Future<List<WasteTransaction>> getRiwayat() async => List.unmodifiable(_riwayat);

  @override
  Future<int> getPendingSyncCount() async => 0;

  @override
  Future<void> syncPendingTransactions() async {}
}

void main() {
  late _FakeWasteRepository fakeRepository;
  late SetorSampahUseCase useCase;

  setUp(() {
    fakeRepository = _FakeWasteRepository();
    useCase = SetorSampahUseCase(fakeRepository);
  });

  group('SetorSampahUseCase.hitungNilai', () {
    test('menghitung nilai rupiah dengan benar untuk plastik 3kg', () {
      final nilai = useCase.hitungNilai(jenis: JenisSampah.plastik, beratKg: 3);
      expect(nilai, 9000); // 3000/kg * 3kg
    });

    test('menghitung nilai rupiah dengan benar untuk berat desimal', () {
      final nilai = useCase.hitungNilai(jenis: JenisSampah.logam, beratKg: 1.5);
      expect(nilai, 12000); // 8000/kg * 1.5kg
    });
  });

  group('SetorSampahUseCase.execute', () {
    test('berhasil menyimpan transaksi untuk input valid', () async {
      final hasil = await useCase.execute(jenis: JenisSampah.kertas, beratKg: 2);

      expect(hasil.nilaiRupiah, 2000);
      expect(hasil.jenisSampah, 'Kertas');
      expect(fakeRepository.saldo, 2000);
    });

    test('melempar SetorSampahException jika berat 0', () async {
      expect(
        () => useCase.execute(jenis: JenisSampah.plastik, beratKg: 0),
        throwsA(isA<SetorSampahException>()),
      );
    });

    test('melempar SetorSampahException jika berat negatif', () async {
      expect(
        () => useCase.execute(jenis: JenisSampah.plastik, beratKg: -5),
        throwsA(isA<SetorSampahException>()),
      );
    });

    test('melempar SetorSampahException jika berat tidak wajar (>500kg)', () async {
      expect(
        () => useCase.execute(jenis: JenisSampah.plastik, beratKg: 600),
        throwsA(isA<SetorSampahException>()),
      );
    });
  });
}
