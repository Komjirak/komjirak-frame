import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

class ShareService {
  static Future<void> shareImage(File imageFile, {String? text}) async {
    try {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: text ?? 'Check out my collage from Komjirak Frame!',
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  static Future<void> shareToInstagramStory(File imageFile) async {
    try {
      // Instagram story sharing would require specific implementation
      // This is a placeholder for the functionality
      await Share.shareXFiles([XFile(imageFile.path)]);
    } catch (e) {
      debugPrint('Error sharing to Instagram: $e');
    }
  }

  static Future<void> shareToSnapchat(File imageFile) async {
    try {
      await Share.shareXFiles([XFile(imageFile.path)]);
    } catch (e) {
      debugPrint('Error sharing to Snapchat: $e');
    }
  }

  static Future<void> shareToMessages(File imageFile) async {
    try {
      await Share.shareXFiles([XFile(imageFile.path)]);
    } catch (e) {
      debugPrint('Error sharing to Messages: $e');
    }
  }
}
