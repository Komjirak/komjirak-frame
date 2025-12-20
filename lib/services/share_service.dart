import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

class ShareService {
  static Future<ShareResult?> shareImage(File imageFile, {String? text}) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: text ?? '✨ Created with Komjirak Frame by @Komjirak Studio',
      );
      return result;
    } catch (e) {
      debugPrint('Error sharing image: $e');
      return null;
    }
  }

  static Future<ShareResult?> shareToInstagramStory(File imageFile) async {
    try {
      // Instagram story sharing with proper attribution
      final result = await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: '✨ Made with Komjirak Frame\n@Komjirak Studio',
      );
      return result;
    } catch (e) {
      debugPrint('Error sharing to Instagram: $e');
      return null;
    }
  }

  static Future<ShareResult?> shareToSnapchat(File imageFile) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Created with Komjirak Frame 📸',
      );
      return result;
    } catch (e) {
      debugPrint('Error sharing to Snapchat: $e');
      return null;
    }
  }

  static Future<ShareResult?> shareToMessages(File imageFile) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Check out my collage! 🎨',
      );
      return result;
    } catch (e) {
      debugPrint('Error sharing to Messages: $e');
      return null;
    }
  }

  static Future<ShareResult?> shareToTikTok(File imageFile) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: '✨ Komjirak Frame Collage',
      );
      return result;
    } catch (e) {
      debugPrint('Error sharing to TikTok: $e');
      return null;
    }
  }
}
