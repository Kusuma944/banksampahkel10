import 'package:flutter/foundation.dart';
import '../../domain/entities/waste_transaction.dart';
import '../../domain/usecases/setor_sampah_usecase.dart';

/// Enum status alur setor sampah — dipakai UI untuk memutuskan tampilan apa
/// yang perlu ditampilkan (spinner, hasil, atau pesan error).
enum SetorSampahStatus { initial, loading, success, error }

/// Provider (ChangeNotifier) yang menjembatani UI (Presentation) dengan
/// business logic (Domain). UI cukup "dengerin" provider ini lewat
/// Consumer/context.watch, tidak perlu tahu detail use case di baliknya.
class SetorSampahProvider extends ChangeNotifier {
  final SetorSampahUseCase _useCase;

  SetorSampahProvider(this._useCase);

  SetorSampahStatus _status = SetorSampahStatus.initial;
  WasteTransaction? _lastTransaction;
  String? _errorMessage;

  SetorSampahStatus get status => _status;
  WasteTransaction? get lastTransaction => _lastTransaction;
  String? get errorMessage => _errorMessage;

  /// Dipanggil dari UI saat user menekan tombol "Setor".
  Future<void> setorSampah({
    required JenisSampah jenis,
    required double beratKg,
  }) async {
    _status = SetorSampahStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasil = await _useCase.execute(jenis: jenis, beratKg: beratKg);
      _lastTransaction = hasil;
      _status = SetorSampahStatus.success;
    } on SetorSampahException catch (e) {
      _errorMessage = e.message;
      _status = SetorSampahStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tak terduga. Coba lagi.';
      _status = SetorSampahStatus.error;
    }

    notifyListeners();
  }

  /// Reset ke kondisi awal, dipanggil misal saat form dibuka ulang.
  void reset() {
    _status = SetorSampahStatus.initial;
    _lastTransaction = null;
    _errorMessage = null;
    notifyListeners();
  }
}
