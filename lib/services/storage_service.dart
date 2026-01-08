import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../models/project_model.dart';
import '../core/errors/storage_exception.dart';
import '../core/errors/result.dart';
import '../utils/constants.dart';
import 'image_service.dart';

class StorageService {
  /// 권한 요청
  static Future<Result<bool, StorageException>> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        if (Platform.version.contains('13') || Platform.version.contains('14')) {
          final photos = await Permission.photos.request();
          if (photos.isGranted) {
            return Result.success(true);
          }
          return Result.failure(StorageException(
            StorageError.permissionDenied,
            '사진 접근 권한이 필요합니다.',
            'Android 13+ photos permission denied',
          ));
        } else {
          final storage = await Permission.storage.request();
          if (storage.isGranted) {
            return Result.success(true);
          }
          return Result.failure(StorageException(
            StorageError.permissionDenied,
            '저장소 접근 권한이 필요합니다.',
            'Android storage permission denied',
          ));
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photosAddOnly.request();
        if (status.isGranted) {
          return Result.success(true);
        }
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted || photosStatus.isLimited) {
          return Result.success(true);
        }
        return Result.failure(StorageException(
          StorageError.permissionDenied,
          '사진 라이브러리 접근 권한이 필요합니다.',
          'iOS photos permission denied',
        ));
      }
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageException(
        StorageError.unknown,
        '권한 요청 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/komjirak_frame');
    
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    
    return appDir.path;
  }

  static Future<String> getProjectsDirectory() async {
    final appDir = await getAppDirectory();
    final projectsDir = Directory('$appDir/projects');
    
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    
    return projectsDir.path;
  }

  static Future<Result<File, StorageException>> saveImage(
    File imageFile,
    String fileName,
  ) async {
    try {
      final appDir = await getAppDirectory();
      final savedPath = '$appDir/$fileName';
      final savedFile = await imageFile.copy(savedPath);
      return Result.success(savedFile);
    } on FileSystemException catch (e) {
      return Result.failure(StorageException(
        StorageError.diskFull,
        '저장 공간이 부족하거나 파일을 저장할 수 없습니다.',
        e.message,
        e,
      ));
    } catch (e) {
      return Result.failure(StorageException(
        StorageError.unknown,
        '이미지 저장 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  static Future<Result<bool, StorageException>> saveToGallery(File imageFile) async {
    try {
      debugPrint('[StorageService] saveToGallery called with file: ${imageFile.path}');
      
      if (!await imageFile.exists()) {
        return Result.failure(StorageException(
          StorageError.fileNotFound,
          '저장할 이미지 파일을 찾을 수 없습니다.',
          'File path: ${imageFile.path}',
        ));
      }
      
      final fileSize = await imageFile.length();
      debugPrint('[StorageService] File exists, size: $fileSize bytes');
      
      if (Platform.isMacOS) {
        debugPrint('[StorageService] macOS detected, saving to Downloads folder');
        return await _saveToDownloadsFolder(imageFile);
      }
      
      debugPrint('[StorageService] Requesting permissions...');
      final permissionResult = await requestPermissions();
      if (permissionResult.isFailure) {
        return permissionResult.mapError((e) => e);
      }
      
      debugPrint('[StorageService] Reading image bytes...');
      final bytes = await imageFile.readAsBytes();
      debugPrint('[StorageService] Bytes read: ${bytes.length}');
      
      final imageName = 'komjirak_frame_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[StorageService] Saving to gallery with name: $imageName');
      
      final result = await ImageGallerySaver.saveFile(
        imageFile.path,
        name: imageName,
      );

      debugPrint('[StorageService] Save result: $result');
      final success = result != null && (result['isSuccess'] == true || result is String);
      
      if (success) {
        debugPrint('[StorageService] ✅ Image saved successfully to gallery!');
        if (result is Map && result['filePath'] != null) {
          debugPrint('[StorageService] Saved to: ${result['filePath']}');
        } else if (result is String) {
          debugPrint('[StorageService] Saved to: $result');
        }
        return Result.success(true);
      } else {
        return Result.failure(StorageException(
          StorageError.unknown,
          '갤러리에 저장하는데 실패했습니다.',
          'ImageGallerySaver returned: $result',
        ));
      }
    } on FileSystemException catch (e) {
      return Result.failure(StorageException(
        StorageError.diskFull,
        '저장 공간이 부족합니다.',
        e.message,
        e,
      ));
    } catch (e, stackTrace) {
      debugPrint('[StorageService] ❌ Error saving to gallery: $e');
      debugPrint('[StorageService] Stack trace: $stackTrace');
      return Result.failure(StorageException(
        StorageError.unknown,
        '갤러리 저장 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  static Future<Result<bool, StorageException>> _saveToDownloadsFolder(File imageFile) async {
    try {
      debugPrint('[StorageService] Using application documents directory');
      final documentsDir = await getApplicationDocumentsDirectory();
      
      final savedDir = Directory('${documentsDir.path}/saved_collages');
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
        debugPrint('[StorageService] Created saved_collages directory');
      }
      
      final fileName = 'komjirak_frame_${DateTime.now().millisecondsSinceEpoch}.png';
      final targetPath = '${savedDir.path}/$fileName';
      
      debugPrint('[StorageService] Copying file to: $targetPath');
      await imageFile.copy(targetPath);
      
      final savedFile = File(targetPath);
      if (await savedFile.exists()) {
        debugPrint('[StorageService] ✅ Image saved successfully: $targetPath');
        return Result.success(true);
      } else {
        return Result.failure(StorageException(
          StorageError.unknown,
          '파일 저장 후 확인에 실패했습니다.',
          'File not found after copy: $targetPath',
        ));
      }
    } on FileSystemException catch (e) {
      return Result.failure(StorageException(
        StorageError.diskFull,
        '저장 공간이 부족합니다.',
        e.message,
        e,
      ));
    } catch (e, stackTrace) {
      debugPrint('[StorageService] ❌ Error saving to Downloads: $e');
      debugPrint('[StorageService] Stack trace: $stackTrace');
      return Result.failure(StorageException(
        StorageError.unknown,
        '파일 저장 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  static Future<Result<bool, StorageException>> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return Result.success(true);
      }
      return Result.failure(StorageException(
        StorageError.fileNotFound,
        '삭제할 파일을 찾을 수 없습니다.',
        'File path: $filePath',
      ));
    } on FileSystemException catch (e) {
      return Result.failure(StorageException(
        StorageError.unknown,
        '파일 삭제 중 오류가 발생했습니다.',
        e.message,
        e,
      ));
    } catch (e) {
      return Result.failure(StorageException(
        StorageError.unknown,
        '파일 삭제 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  static Future<List<File>> getAllSavedImages() async {
    try {
      final appDir = await getAppDirectory();
      final directory = Directory(appDir);
      
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'))
          .toList();
      
      return files;
    } catch (e) {
      debugPrint('Error getting saved images: $e');
      return [];
    }
  }

  // Project management methods with improved error handling and transaction support
  static Future<Result<bool, StorageException>> saveProject(Project project) async {
    File? tempFile;
    try {
      final projects = await getAllProjects();
      
      // Update existing or add new
      final index = projects.indexWhere((p) => p.id == project.id);
      if (index >= 0) {
        projects[index] = project;
      } else {
        projects.add(project);
      }

      final appDir = await getAppDirectory();
      
      // 1. 임시 파일에 먼저 저장 (트랜잭션 지원)
      tempFile = File('$appDir/${AppConstants.projectsFileName}.tmp');
      final jsonList = projects.map((p) => p.toJson()).toList();
      await tempFile.writeAsString(json.encode(jsonList));
      
      // 2. 썸네일 생성 (비동기, 실패해도 계속 진행)
      if (project.thumbnailPath == null && project.photoPaths.isNotEmpty) {
        _generateThumbnailAsync(project);
      }
      
      // 3. 원자적 교체 (rename은 원자적 연산)
      final mainFile = File('$appDir/${AppConstants.projectsFileName}');
      await tempFile.rename(mainFile.path);
      
      return Result.success(true);
    } on FileSystemException catch (e) {
      // 임시 파일 정리
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
      
      return Result.failure(StorageException(
        StorageError.diskFull,
        '프로젝트 저장 중 오류가 발생했습니다.',
        e.message,
        e,
      ));
    } on FormatException catch (e) {
      // 임시 파일 정리
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
      
      return Result.failure(StorageException(
        StorageError.invalidData,
        '프로젝트 데이터 형식이 올바르지 않습니다.',
        e.message,
        e,
      ));
    } catch (e) {
      // 임시 파일 정리
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
      
      return Result.failure(StorageException(
        StorageError.unknown,
        '프로젝트 저장 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  /// 비동기 썸네일 생성 (실패해도 프로젝트는 저장됨)
  static Future<void> _generateThumbnailAsync(Project project) async {
    try {
      if (project.photoPaths.isNotEmpty) {
        final thumbnailResult = await ImageService.createThumbnail(
          File(project.photoPaths.first),
        );
        
        if (thumbnailResult.isSuccess) {
          final thumbnail = thumbnailResult.valueOrNull;
          if (thumbnail != null) {
            final updatedProject = project.copyWith(
              thumbnailPath: thumbnail.path,
            );
            // 썸네일 업데이트는 실패해도 무시
            await saveProject(updatedProject);
          }
        }
      }
    } catch (e) {
      debugPrint('[StorageService] Thumbnail generation failed: $e');
      // 실패해도 프로젝트는 저장됨
    }
  }

  static Future<List<Project>> getAllProjects() async {
    try {
      final appDir = await getAppDirectory();
      final file = File('$appDir/${AppConstants.projectsFileName}');
      
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }
      
      final jsonList = json.decode(content) as List;
      
      return jsonList.map((json) => Project.fromJson(json)).toList();
    } on FormatException catch (e) {
      debugPrint('Error parsing projects JSON: $e');
      return [];
    } catch (e) {
      debugPrint('Error loading projects: $e');
      return [];
    }
  }

  static Future<Result<Project, StorageException>> getProject(String projectId) async {
    try {
      final projects = await getAllProjects();
      final project = projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
      return Result.success(project);
    } catch (e) {
      return Result.failure(StorageException(
        StorageError.fileNotFound,
        '프로젝트를 찾을 수 없습니다.',
        'Project ID: $projectId',
        e,
      ));
    }
  }

  static Future<Result<bool, StorageException>> deleteProject(String projectId) async {
    try {
      final projects = await getAllProjects();
      Project? projectResult;
      try {
        projectResult = projects.firstWhere((p) => p.id == projectId);
      } catch (e) {
        projectResult = null;
      }
      
      if (projectResult == null) {
        return Result.failure(StorageException(
          StorageError.fileNotFound,
          '삭제할 프로젝트를 찾을 수 없습니다.',
          'Project ID: $projectId',
        ));
      }
      
      // 관련 파일 삭제 (병렬 처리, 실패해도 계속 진행)
      final deleteTasks = <Future<Result<bool, StorageException>>>[];
      
      if (projectResult.thumbnailPath != null) {
        deleteTasks.add(deleteImage(projectResult.thumbnailPath!));
      }
      
      // 프로젝트 이미지 파일들도 삭제 (임시 파일인 경우에만)
      for (final photoPath in projectResult.photoPaths) {
        if (photoPath.contains('temp') || photoPath.contains('cache')) {
          deleteTasks.add(deleteImage(photoPath));
        }
      }
      
      // 모든 삭제 작업 실행 (에러 무시)
      await Future.wait(deleteTasks, eagerError: false);
      
      // 프로젝트 목록에서 제거
      projects.removeWhere((p) => p.id == projectId);
      
      // 저장
      final appDir = await getAppDirectory();
      final file = File('$appDir/${AppConstants.projectsFileName}');
      final jsonList = projects.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      return Result.success(true);
    } on FileSystemException catch (e) {
      return Result.failure(StorageException(
        StorageError.unknown,
        '프로젝트 삭제 중 오류가 발생했습니다.',
        e.message,
        e,
      ));
    } catch (e) {
      return Result.failure(StorageException(
        StorageError.unknown,
        '프로젝트 삭제 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }
}
