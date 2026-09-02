import 'package:flutter_test/flutter_test.dart';
import 'package:ecobank_sampah/domain/entities/waste_transaction.dart';
import 'package:ecobank_sampah/domain/repositories/waste_repository.dart';
import 'package:ecobank_sampah/domain/usecases/sync_pending_usecase.dart';

/// Fake repository yang bisa disimulasikan punya transaksi pending,
/// tanpa perlu Hive/koneksi sungguhan.
class _FakeWasteRepository implements WasteRepository {
  int _pendingCount;
  bool syncWasCalled = false;

  _FakeWasteRepository({int pendingCount = 0}) : _pendingCount = pendingCount;

  @override
  Future<WasteTransaction> setorSampah({required JenisSampah jenis, required double beratKg}) async {
    throw UnimplementedError('tidak dipakai di test ini');
  }

  @override
  Future<int> getSaldo() async => 0;

  @override
  Future<List<WasteTransaction>> getRiwayat() async => [];

  @override
  Future<int> getPendingSyncCount() async => _pendingCount;

  @override
  Future<void> syncPendingTransactions() async {
    syncWasCalled = true;
    _pendingCount = 0;
  }
}

void main() {
  test('pendingCount meneruskan angka dari repository', () async {
    final fake = _FakeWasteRepository(pendingCount: 3);
    final useCase = SyncPendingUseCase(fake);

    expect(await useCase.pendingCount(), 3);
  });

  test('execute memanggil syncPendingTransactions pada repository', () async {
    final fake = _FakeWasteRepository(pendingCount: 2);
    final useCase = SyncPendingUseCase(fake);

    await useCase.execute();

    expect(fake.syncWasCalled, true);
    expect(await useCase.pendingCount(), 0);
  });
}
