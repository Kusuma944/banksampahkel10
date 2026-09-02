import '../repositories/waste_repository.dart';

/// Use case tipis untuk orkestrasi sinkronisasi transaksi pending.
/// Dipisah dari repository supaya bagian "kapan sync dipanggil"
/// (misal dari listener konektivitas) tetap murni business logic,
/// bisa di-unit-test tanpa Hive/Flutter sungguhan lewat Fake repository.
class SyncPendingUseCase {
  final WasteRepository repository;
  const SyncPendingUseCase(this.repository);

  Future<int> pendingCount() => repository.getPendingSyncCount();

  Future<void> execute() => repository.syncPendingTransactions();
}
