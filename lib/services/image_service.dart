import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  static Future<File?> compressImage(File file, {int quality = 85}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  static Future<File?> cropImage(
    File file, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      final cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_cropped.jpg';

      final croppedFile = File(targetPath);
      await croppedFile.writeAsBytes(img.encodeJpg(cropped));

      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  static Future<File?> resizeImage(
    File file, {
    required int width,
    required int height,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      final resized = img.copyResize(image, width: width, height: height);
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_resized.jpg';

      final resizedFile = File(targetPath);
      await resizedFile.writeAsBytes(img.encodeJpg(resized));

      return resizedFile;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return null;
    }
  }

  static Future<ui.Image> loadImage(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
