import 'package:hive/hive.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/waste_transaction.dart';
import '../../domain/repositories/waste_repository.dart';

/// Implementasi [WasteRepository] yang PERSISTENT (Hive) dan
/// mendukung pola Offline-First.
///
/// Prinsip offline-first di sini: `setorSampah` SELALU menulis ke Hive
/// (disk lokal) terlebih dahulu, apapun status koneksinya. Kalau saat
/// itu online, langsung dicoba sinkron (simulasi network call); kalau
/// offline, transaksi ditandai `synced: false` dan menunggu dipanggil
/// [syncPendingTransactions] saat koneksi kembali.
///
/// Box di-inject lewat constructor (bukan dibuka sendiri di sini) supaya
/// class ini gampang di-unit-test dengan Hive box sungguhan di direktori
/// sementara, tanpa perlu menjalankan seluruh aplikasi Flutter.
class WasteRepositoryHiveImpl implements WasteRepository {
  final Box<Map> _box;
  final ConnectivityService _connectivity;

  WasteRepositoryHiveImpl(this._box, this._connectivity);

  @override
  Future<WasteTransaction> setorSampah({
    required JenisSampah jenis,
    required double beratKg,
  }) async {
    final nilai = (jenis.hargaPerKg * beratKg).round();
    final tanggal = DateTime.now();
    // Key unik berbasis timestamp mikrodetik, supaya urutan insert terjaga
    // dan tidak butuh auto-increment terpisah.
    final key = tanggal.microsecondsSinceEpoch.toString();

    // Coba sinkron langsung kalau kebetulan online saat setor (simulasi
    // panggilan API). Kalau offline, transaksi tetap tersimpan lokal
    // dan ditandai belum sinkron — inilah inti offline-first.
    bool synced = false;
    if (await _connectivity.isOnline()) {
      await Future.delayed(const Duration(milliseconds: 500)); // simulasi network call
      synced = true;
    }

    await _box.put(key, {
      'jenisSampah': jenis.namaTampilan,
      'beratKg': beratKg,
      'nilaiRupiah': nilai,
      'tanggal': tanggal.toIso8601String(),
      'synced': synced,
    });

    return WasteTransaction(
      jenisSampah: jenis.namaTampilan,
      beratKg: beratKg,
      nilaiRupiah: nilai,
      tanggal: tanggal,
      synced: synced,
    );
  }

  @override
  Future<int> getSaldo() async {
    var total = 0;
    for (final raw in _box.values) {
      total += (raw['nilaiRupiah'] as num).toInt();
    }
    return total;
  }

  @override
  Future<List<WasteTransaction>> getRiwayat() async {
    // Dibaca langsung dari disk lokal — sengaja TIDAK memanggil apapun
    // yang butuh internet, supaya tetap jalan 100% saat offline.
    final list = _box.values.map(_mapToEntity).toList();
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  @override
  Future<int> getPendingSyncCount() async {
    return _box.values.where((raw) => raw['synced'] == false).length;
  }

  @override
  Future<void> syncPendingTransactions() async {
    if (!await _connectivity.isOnline()) return; // tidak ada koneksi, batalkan

    final pendingKeys = _box.keys.where((key) {
      final raw = _box.get(key);
      return raw != null && raw['synced'] == false;
    }).toList();

    for (final key in pendingKeys) {
      await Future.delayed(const Duration(milliseconds: 300)); // simulasi upload satu per satu
      final raw = Map<String, dynamic>.from(_box.get(key)!);
      raw['synced'] = true;
      await _box.put(key, raw);
    }
  }

  WasteTransaction _mapToEntity(Map raw) {
    return WasteTransaction(
      jenisSampah: raw['jenisSampah'] as String,
      beratKg: (raw['beratKg'] as num).toDouble(),
      nilaiRupiah: (raw['nilaiRupiah'] as num).toInt(),
      tanggal: DateTime.parse(raw['tanggal'] as String),
      synced: raw['synced'] as bool? ?? true,
    );
  }
}
