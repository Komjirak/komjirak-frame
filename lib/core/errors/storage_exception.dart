/// 저장소 관련 에러 타입
enum StorageError {
  fileNotFound,
  permissionDenied,
  diskFull,
  invalidData,
  networkError,
  unknown,
}

/// 저장소 관련 예외 클래스
class StorageException implements Exception {
  final StorageError type;
  final String userMessage;
  final String? technicalDetails;
  final dynamic originalError;

  StorageException(
    this.type,
    this.userMessage, [
    this.technicalDetails,
    this.originalError,
  ]);

  @override
  String toString() {
    return 'StorageException(type: $type, message: $userMessage, details: $technicalDetails)';
  }

  /// 사용자 친화적인 에러 메시지
  String get displayMessage {
    switch (type) {
      case StorageError.fileNotFound:
        return '파일을 찾을 수 없습니다.';
      case StorageError.permissionDenied:
        return '저장 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      case StorageError.diskFull:
        return '저장 공간이 부족합니다. 공간을 확보한 후 다시 시도해주세요.';
      case StorageError.invalidData:
        return '데이터 형식이 올바르지 않습니다.';
      case StorageError.networkError:
        return '네트워크 연결을 확인해주세요.';
      case StorageError.unknown:
        return userMessage.isNotEmpty ? userMessage : '알 수 없는 오류가 발생했습니다.';
    }
  }
}

/// 이미지 처리 관련 예외
class ImageProcessingException implements Exception {
  final String message;
  final String? technicalDetails;
  final dynamic originalError;

  ImageProcessingException(
    this.message, [
    this.technicalDetails,
    this.originalError,
  ]);

  @override
  String toString() {
    return 'ImageProcessingException(message: $message, details: $technicalDetails)';
  }
}

/// 오프라인 상태 예외
class OfflineException implements Exception {
  final String message;

  OfflineException([this.message = '오프라인 상태입니다. 연결 후 다시 시도해주세요.']);

  @override
  String toString() => 'OfflineException: $message';
}
