import 'package:hive/hive.dart';
import '../../core/network/connectivity_service.dart';
import '../../domain/entities/waste_transaction.dart';
import '../../domain/repositories/waste_repository.dart';

/// Implementasi [WasteRepository] yang PERSISTENT (Hive) dan
/// mendukung pola Offline-First.
///
/// Prinsip offline-first di sini: `setorSampah` SELALU menulis ke Hive
/// (disk lokal) terlebih dahulu, apapun status koneksinya. Kalau saat
/// itu online, langsung dicoba sinkron; kalau offline, transaksi
/// ditandai `synced: false` dan menunggu dipanggil
/// [syncPendingTransactions] saat koneksi kembali.
///
/// [remoteSync] (CPMK 5, opsional) — fungsi yang benar-benar mengupload
/// transaksi ke cloud (Supabase). Kalau null (default), perilaku persis
/// seperti CPMK 4: sinkron "disimulasikan" hanya menandai flag lokal.
/// Kalau diisi dan upload GAGAL, transaksi tetap `synced: false` supaya
/// dicoba lagi nanti — inilah error handling & network resilience yang
/// diminta CPMK 5, menyatu dengan mekanisme offline-first CPMK 4.
///
/// Box di-inject lewat constructor (bukan dibuka sendiri di sini) supaya
/// class ini gampang di-unit-test dengan Hive box sungguhan di direktori
/// sementara, tanpa perlu menjalankan seluruh aplikasi Flutter.
class WasteRepositoryHiveImpl implements WasteRepository {
  final Box<Map> _box;
  final ConnectivityService _connectivity;
  final Future<void> Function(WasteTransaction transaction)? remoteSync;

  WasteRepositoryHiveImpl(this._box, this._connectivity, {this.remoteSync});

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

    // Coba sinkron langsung kalau kebetulan online saat setor. Kalau
    // offline, transaksi tetap tersimpan lokal dan ditandai belum
    // sinkron — inilah inti offline-first.
    bool synced = false;
    if (await _connectivity.isOnline()) {
      synced = await _trySyncOne(WasteTransaction(
        jenisSampah: jenis.namaTampilan,
        beratKg: beratKg,
        nilaiRupiah: nilai,
        tanggal: tanggal,
      ));
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

  /// Mencoba upload SATU transaksi ke cloud lewat [remoteSync].
  /// Mengembalikan `true` kalau berhasil (atau memang tidak ada
  /// remoteSync yang di-set, supaya default tetap simulasi seperti
  /// CPMK 4). Mengembalikan `false` kalau gagal — transaksi tetap
  /// disimpan lokal, TIDAK ada exception yang bocor ke pemanggil.
  Future<bool> _trySyncOne(WasteTransaction transaction) async {
    if (remoteSync == null) {
      await Future.delayed(const Duration(milliseconds: 500)); // simulasi network call
      return true;
    }
    try {
      await remoteSync!(transaction);
      return true;
    } catch (_) {
      return false; // upload gagal (timeout/server error/dsb) — biarkan pending
    }
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
      final raw = Map<String, dynamic>.from(_box.get(key)!);
      final entity = _mapToEntity(raw);

      final berhasil = await _trySyncOne(entity);
      if (!berhasil) continue; // gagal upload kali ini, coba lagi di panggilan berikutnya

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
