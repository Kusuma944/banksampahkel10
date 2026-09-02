import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ecobank_sampah/core/network/connectivity_service.dart';
import 'package:ecobank_sampah/data/repositories/waste_repository_hive_impl.dart';
import 'package:ecobank_sampah/domain/entities/waste_transaction.dart';

/// Fake koneksi yang bisa di-set manual online/offline dan bisa
/// men-trigger stream perubahan status — tanpa perlu koneksi sungguhan.
class _FakeConnectivityService implements ConnectivityService {
  bool online;
  _FakeConnectivityService({this.online = true});

  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  void setOnline(bool value) {
    online = value;
    _controller.add(value);
  }

  void dispose() => _controller.close();
}

void main() {
  late Directory tempDir;
  late Box<Map> box;
  late _FakeConnectivityService fakeConnectivity;
  late WasteRepositoryHiveImpl repository;

  setUp(() async {
    // Hive (paket dart murni, bukan hive_flutter) dipakai di sini supaya
    // test bisa jalan tanpa Flutter engine — cukup direktori sementara.
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>('test_waste_transactions');
    fakeConnectivity = _FakeConnectivityService();
    repository = WasteRepositoryHiveImpl(box, fakeConnectivity);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    fakeConnectivity.dispose();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('CRUD dasar (Praktikum Database)', () {
    test('setor sampah tersimpan dan bisa dibaca kembali dari disk', () async {
      final hasil = await repository.setorSampah(jenis: JenisSampah.plastik, beratKg: 2);

      expect(hasil.nilaiRupiah, 6000); // 3000/kg * 2kg
      expect(hasil.synced, true); // fakeConnectivity default online

      final riwayat = await repository.getRiwayat();
      expect(riwayat.length, 1);
      expect(riwayat.first.jenisSampah, 'Plastik');
    });

    test('getSaldo menjumlahkan seluruh nilai transaksi tersimpan', () async {
      await repository.setorSampah(jenis: JenisSampah.plastik, beratKg: 1); // 3000
      await repository.setorSampah(jenis: JenisSampah.kertas, beratKg: 2); // 2000

      final saldo = await repository.getSaldo();
      expect(saldo, 5000);
    });

    test('riwayat terurut dari transaksi terbaru', () async {
      await repository.setorSampah(jenis: JenisSampah.plastik, beratKg: 1);
      await Future.delayed(const Duration(milliseconds: 5));
      await repository.setorSampah(jenis: JenisSampah.logam, beratKg: 1);

      final riwayat = await repository.getRiwayat();
      expect(riwayat.first.jenisSampah, 'Logam/Kaleng'); // yang terbaru duluan
    });
  });

  group('Offline-First', () {
    test('transaksi tetap tersimpan lokal saat offline, ditandai belum sinkron', () async {
      fakeConnectivity.setOnline(false);

      final hasil = await repository.setorSampah(jenis: JenisSampah.kaca, beratKg: 3);

      expect(hasil.synced, false);
      expect(await repository.getPendingSyncCount(), 1);

      // Data tetap bisa dibaca walau offline — inti offline-first.
      final riwayat = await repository.getRiwayat();
      expect(riwayat.length, 1);
      expect(riwayat.first.synced, false);
    });

    test('transaksi pending otomatis tersinkron saat koneksi kembali online', () async {
      fakeConnectivity.setOnline(false);
      await repository.setorSampah(jenis: JenisSampah.plastik, beratKg: 2);
      expect(await repository.getPendingSyncCount(), 1);

      fakeConnectivity.setOnline(true);
      await repository.syncPendingTransactions();

      expect(await repository.getPendingSyncCount(), 0);
      final riwayat = await repository.getRiwayat();
      expect(riwayat.first.synced, true);
    });

    test('syncPendingTransactions tidak melakukan apa-apa kalau masih offline', () async {
      fakeConnectivity.setOnline(false);
      await repository.setorSampah(jenis: JenisSampah.plastik, beratKg: 1);

      await repository.syncPendingTransactions(); // masih offline, harus no-op

      expect(await repository.getPendingSyncCount(), 1);
    });

    test('beberapa transaksi offline sekaligus tersinkron semua saat online', () async {
      fakeConnectivity.setOnline(false);
      await repository.setorSampah(jenis: JenisSampah.plastik, beratKg: 1);
      await repository.setorSampah(jenis: JenisSampah.kertas, beratKg: 1);
      await repository.setorSampah(jenis: JenisSampah.logam, beratKg: 1);
      expect(await repository.getPendingSyncCount(), 3);

      fakeConnectivity.setOnline(true);
      await repository.syncPendingTransactions();

      expect(await repository.getPendingSyncCount(), 0);
    });
  });
}
