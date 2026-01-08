import 'package:flutter_test/flutter_test.dart';
import 'package:komjirak_frame/core/errors/result.dart';

void main() {
  group('Result', () {
    test('should create success result', () {
      final result = Result.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, equals(42));
      expect(result.errorOrNull, isNull);
    });

    test('should create failure result', () {
      final error = 'Test error';
      final result = Result.failure(error);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, equals(error));
    });

    test('should get value or default', () {
      final success = Result.success(42);
      final failure = Result.failure('Error');

      expect(success.getOrElse(0), equals(42));
      expect(failure.getOrElse(0), equals(0));
    });

    test('should get value or throw', () {
      final success = Result.success(42);
      expect(success.getOrThrow(), equals(42));

      final failure = Result.failure('Error');
      expect(() => failure.getOrThrow(), throwsA('Error'));
    });

    test('should map value', () {
      final success = Result.success(42);
      final mapped = success.map((value) => value * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.valueOrNull, equals(84));

      final failure = Result.failure('Error');
      final mappedFailure = failure.map((value) => value * 2);
      expect(mappedFailure.isFailure, isTrue);
    });

    test('should map error', () {
      final failure = Result.failure('Error');
      final mapped = failure.mapError((error) => 'Mapped: $error');

      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, equals('Mapped: Error'));

      final success = Result.success(42);
      final mappedSuccess = success.mapError((error) => 'Mapped');
      expect(mappedSuccess.isSuccess, isTrue);
    });

    test('should fold correctly', () {
      final success = Result.success(42);
      final folded = success.fold(
        (error) => 'Error: $error',
        (value) => 'Value: $value',
      );
      expect(folded, equals('Value: 42'));

      final failure = Result.failure('Error');
      final foldedFailure = failure.fold(
        (error) => 'Error: $error',
        (value) => 'Value: $value',
      );
      expect(foldedFailure, equals('Error: Error'));
    });
  });
}
