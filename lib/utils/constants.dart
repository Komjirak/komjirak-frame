class AppConstants {
  // Image Quality
  static const int defaultImageQuality = 85;
  static const int highImageQuality = 95;
  
  // Image Sizes
  static const int thumbnailSize = 200;
  static const int previewSize = 800;
  static const int exportSize = 2048;
  static const int maxImageSizeMB = 50;
  
  // Layout
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 20.0;
  static const double cardElevation = 2.0;
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Limits
  static const int maxPhotosPerCollage = 12;
  static const int minPhotosPerCollage = 1;
  
  // File Paths
  static const String projectsFileName = 'projects.json';
  static const String cacheDirectoryName = 'komjirak_cache';
  
  // Error Messages
  static const String errorImageLoad = '이미지를 불러올 수 없습니다';
  static const String errorSaveFailed = '저장에 실패했습니다';
  static const String errorPermissionDenied = '권한이 거부되었습니다';
  static const String errorFileNotFound = '파일을 찾을 수 없습니다';
  static const String errorDiskFull = '저장 공간이 부족합니다';
}
