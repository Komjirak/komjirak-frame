import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../models/project_model.dart';

class StorageService {
  static const String _projectsFileName = 'projects.json';

  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (Platform.version.contains('13') || Platform.version.contains('14')) {
        // Android 13+ uses different permissions
        final photos = await Permission.photos.request();
        return photos.isGranted;
      } else {
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true; // For web and other platforms
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

  static Future<File?> saveImage(File imageFile, String fileName) async {
    try {
      final appDir = await getAppDirectory();
      final savedPath = '$appDir/$fileName';
      
      return await imageFile.copy(savedPath);
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  static Future<bool> saveToGallery(File imageFile) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        debugPrint('Gallery permission denied');
        return false;
      }

      final bytes = await imageFile.readAsBytes();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: 'komjirak_frame_${DateTime.now().millisecondsSinceEpoch}',
      );

      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }

  static Future<bool> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
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

  // Project management methods
  static Future<bool> saveProject(Project project) async {
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
      final file = File('$appDir/$_projectsFileName');
      
      final jsonList = projects.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      return true;
    } catch (e) {
      debugPrint('Error saving project: $e');
      return false;
    }
  }

  static Future<List<Project>> getAllProjects() async {
    try {
      final appDir = await getAppDirectory();
      final file = File('$appDir/$_projectsFileName');
      
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      final jsonList = json.decode(content) as List;
      
      return jsonList.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading projects: $e');
      return [];
    }
  }

  static Future<Project?> getProject(String projectId) async {
    try {
      final projects = await getAllProjects();
      return projects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => throw Exception('Project not found'),
      );
    } catch (e) {
      debugPrint('Error getting project: $e');
      return null;
    }
  }

  static Future<bool> deleteProject(String projectId) async {
    try {
      final projects = await getAllProjects();
      final project = projects.firstWhere((p) => p.id == projectId);
      
      // Delete associated images
      if (project.thumbnailPath != null) {
        await deleteImage(project.thumbnailPath!);
      }

      projects.removeWhere((p) => p.id == projectId);

      final appDir = await getAppDirectory();
      final file = File('$appDir/$_projectsFileName');
      
      final jsonList = projects.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      
      return true;
    } catch (e) {
      debugPrint('Error deleting project: $e');
      return false;
    }
  }
}
