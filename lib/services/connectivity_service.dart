import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 네트워크 연결 상태 관리 서비스
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  /// 현재 연결 상태 확인
  static Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('[ConnectivityService] Error checking connectivity: $e');
      // 에러 발생 시 연결된 것으로 가정 (로컬 작업은 계속 가능)
      return true;
    }
  }

  /// 연결 상태 스트림
  static Stream<bool> get isConnectedStream async* {
    try {
      await for (final result in _connectivity.onConnectivityChanged) {
        yield result != ConnectivityResult.none;
      }
    } catch (e) {
      debugPrint('[ConnectivityService] Error in connectivity stream: $e');
      yield true; // 에러 시 연결된 것으로 가정
    }
  }

  /// 연결 타입 확인
  static Future<ConnectivityResult> get connectivityType async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('[ConnectivityService] Error checking connectivity type: $e');
      return ConnectivityResult.none;
    }
  }
}
