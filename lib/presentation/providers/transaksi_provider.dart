import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/waste_transaction.dart';
import '../../domain/repositories/waste_repository.dart';

/// Provider yang menjembatani Beranda dengan data transaksi PERSISTENT
/// (lewat WasteRepository, yang di balik layar dipegang Hive).
///
/// Ini pusat dari demonstrasi Offline-First:
/// - [refresh] membaca ulang riwayat & status sync dari disk lokal —
///   sengaja tidak butuh internet sama sekali, jadi Beranda tetap bisa
///   menampilkan data walau HP dalam mode pesawat.
/// - Saat koneksi berubah dari offline -> online, provider ini otomatis
///   memanggil `syncPendingTransactions()` lalu me-refresh data.
class TransaksiProvider extends ChangeNotifier {
  final WasteRepository _repository;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _subscription;

  bool isOnline = true;
  bool isLoading = true;
  int pendingSyncCount = 0;
  List<WasteTransaction> riwayat = [];
  int saldo = 0;

  TransaksiProvider(this._repository, this._connectivity) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    isOnline = await _connectivity.isOnline();
    await refresh();
    isLoading = false;
    notifyListeners();

    // Dengarkan perubahan koneksi — begitu online, coba sinkron otomatis.
    _subscription = _connectivity.onStatusChange.listen((online) async {
      isOnline = online;
      if (online) {
        await _repository.syncPendingTransactions();
      }
      await refresh();
    });
  }

  /// Membaca ulang riwayat, saldo, dan jumlah transaksi pending dari
  /// penyimpanan lokal. Aman dipanggil kapan saja, termasuk saat offline.
  Future<void> refresh() async {
    riwayat = await _repository.getRiwayat();
    pendingSyncCount = await _repository.getPendingSyncCount();
    saldo = await _repository.getSaldo();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
