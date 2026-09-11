/// Representasi eror level domain — dipetakan dari exception teknis
/// (timeout, DNS gagal, HTTP 5xx, dsb) ke sesuatu yang bisa ditampilkan
/// UI dengan pesan yang manusiawi, tanpa UI perlu tahu detail implementasi
/// jaringan di baliknya.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Tidak ada koneksi internet sama sekali (mis. DNS gagal, mode pesawat).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.']);
}

/// Request memakan waktu terlalu lama dan sudah dicoba ulang beberapa kali.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Permintaan memakan waktu terlalu lama. Coba lagi.']);
}

/// Server merespons dengan status error (4xx/5xx).
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(this.statusCode, String message) : super(message);
}

/// Sesi/kredensial tidak valid (401/403), atau kombinasi email-password salah.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Sesi tidak valid. Silakan masuk kembali.']);
}

/// Fallback untuk error yang tidak terduga / tidak masuk kategori di atas.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan tak terduga. Coba lagi.']);
}
