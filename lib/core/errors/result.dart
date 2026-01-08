/// 함수형 프로그래밍 스타일의 Result 타입
/// 성공 또는 실패를 명확하게 표현
sealed class Result<T, E> {
  const Result();

  /// 성공 결과
  const factory Result.success(T value) = Success<T, E>;

  /// 실패 결과
  const factory Result.failure(E error) = Failure<T, E>;

  /// 성공 여부 확인
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  /// 값 또는 에러 가져오기
  T? get valueOrNull => switch (this) {
        Success<T, E>(:final value) => value,
        Failure<T, E>() => null,
      };

  E? get errorOrNull => switch (this) {
        Success<T, E>() => null,
        Failure<T, E>(:final error) => error,
      };

  /// 값 가져오기 (실패 시 null)
  T? getOrNull() => valueOrNull;

  /// 값 가져오기 (실패 시 기본값)
  T getOrElse(T defaultValue) => valueOrNull ?? defaultValue;

  /// 값 가져오기 (실패 시 예외 발생)
  T getOrThrow() {
    return switch (this) {
      Success<T, E>(:final value) => value,
      Failure<T, E>(:final error) => throw error as Object,
    };
  }

  /// 변환
  Result<U, E> map<U>(U Function(T) transform) {
    return switch (this) {
      Success<T, E>(:final value) => Result.success(transform(value)),
      Failure<T, E>(:final error) => Result.failure(error),
    };
  }

  /// 에러 변환
  Result<T, F> mapError<F>(F Function(E) transform) {
    return switch (this) {
      Success<T, E>(:final value) => Result.success(value),
      Failure<T, E>(:final error) => Result.failure(transform(error)),
    };
  }

  /// 폴드 (성공/실패 모두 처리)
  R fold<R>(R Function(E error) onFailure, R Function(T value) onSuccess) {
    return switch (this) {
      Success<T, E>(:final value) => onSuccess(value),
      Failure<T, E>(:final error) => onFailure(error),
    };
  }
}

/// 성공 결과
final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// 실패 결과
final class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';
}
