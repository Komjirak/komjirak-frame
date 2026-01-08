import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// 이미지 캐싱 서비스
class ImageCacheService {
  static final CacheManager _cacheManager = CacheManager(
    Config(
      AppConstants.cacheDirectoryName,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  /// 캐시된 이미지 가져오기
  static Future<File> getCachedImage(String url) async {
    try {
      return await _cacheManager.getSingleFile(url);
    } catch (e) {
      debugPrint('[ImageCacheService] Error getting cached image: $e');
      rethrow;
    }
  }

  /// 이미지 URL을 캐시에 저장
  static Future<File> cacheImage(String url) async {
    try {
      return await _cacheManager.getSingleFile(url);
    } catch (e) {
      debugPrint('[ImageCacheService] Error caching image: $e');
      rethrow;
    }
  }

  /// 캐시 삭제
  static Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      debugPrint('[ImageCacheService] Cache cleared');
    } catch (e) {
      debugPrint('[ImageCacheService] Error clearing cache: $e');
    }
  }

  /// 특정 파일 캐시 삭제
  static Future<void> removeFromCache(String url) async {
    try {
      await _cacheManager.removeFile(url);
    } catch (e) {
      debugPrint('[ImageCacheService] Error removing from cache: $e');
    }
  }

  /// 캐시 정보 가져오기
  static Future<FileInfo?> getFileFromCache(String url) async {
    try {
      return await _cacheManager.getFileFromCache(url);
    } catch (e) {
      debugPrint('[ImageCacheService] Error getting file info: $e');
      return null;
    }
  }
}
