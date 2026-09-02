import 'package:connectivity_plus/connectivity_plus.dart';

/// Kontrak abstrak untuk cek status koneksi internet.
/// Dipisah dari implementasi `connectivity_plus` supaya repository
/// bisa di-unit-test dengan Fake, tanpa perlu koneksi/plugin sungguhan.
abstract class ConnectivityService {
  /// Cek status koneksi saat ini (sekali panggil, bukan stream).
  Future<bool> isOnline();

  /// Stream yang emit setiap kali status online/offline berubah.
  /// Dipakai untuk trigger auto-sync begitu koneksi kembali.
  Stream<bool> get onStatusChange;
}

/// Implementasi asli memakai package `connectivity_plus`.
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool _resultToBool(List<ConnectivityResult> result) {
    return result.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _resultToBool(result);
  }

  @override
  Stream<bool> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(_resultToBool);
  }
}
