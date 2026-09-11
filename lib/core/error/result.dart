import 'failure.dart';

/// Wrapper hasil operasi async yang bisa gagal — dipakai di seluruh
/// repository CPMK 5 (Auth, Payment, sync cloud) supaya UI selalu tahu
/// pasti: berhasil dengan data, atau gagal dengan alasan yang jelas.
/// Tidak ada exception yang lolos sampai ke widget — itulah intinya
/// "Error Handling & Network Resilience" di rubrik CPMK 5.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is ResultFailure<T>) return failure(self.failure);
    throw StateError('Unreachable: Result harus Success atau ResultFailure');
  }

  bool get isSuccess => this is Success<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}
