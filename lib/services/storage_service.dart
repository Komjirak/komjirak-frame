import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }

  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/komjirak_frame');
    
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    
    return appDir.path;
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
}
