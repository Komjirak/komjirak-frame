import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  // Create collage image from widget
  static Future<File?> captureWidgetAsImage(
    GlobalKey key, {
    String? fileName,
    int quality = 95,
  }) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Error: Could not find RenderRepaintBoundary');
        return null;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final name = fileName ?? 'collage_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${dir.path}/$name.png');
      
      await file.writeAsBytes(pngBytes);

      // Optionally compress to jpg for smaller file size
      if (quality < 100) {
        final compressed = await compressImage(file, quality: quality);
        if (compressed != null) {
          await file.delete();
          return compressed;
        }
      }

      return file;
    } catch (e) {
      debugPrint('Error capturing widget as image: $e');
      return null;
    }
  }

  // Create thumbnail from image
  static Future<File?> createThumbnail(File file, {int size = 200}) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      final thumbnail = img.copyResizeCropSquare(image, size: size);
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';

      final thumbnailFile = File(targetPath);
      await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 85));

      return thumbnailFile;
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      return null;
    }
  }
}
