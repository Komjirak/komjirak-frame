import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../core/errors/storage_exception.dart';
import '../core/errors/result.dart';
import '../utils/constants.dart';

class ImageService {
  /// 이미지 압축
  static Future<Result<File, ImageProcessingException>> compressImage(
    File file, {
    int quality = AppConstants.defaultImageQuality,
  }) async {
    try {
      if (!await file.exists()) {
        return Result.failure(ImageProcessingException(
          '압축할 이미지 파일을 찾을 수 없습니다.',
          'File path: ${file.path}',
        ));
      }

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result == null) {
        return Result.failure(ImageProcessingException(
          '이미지 압축에 실패했습니다.',
          'FlutterImageCompress returned null',
        ));
      }

      return Result.success(File(result.path));
    } catch (e) {
      return Result.failure(ImageProcessingException(
        '이미지 압축 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  /// 이미지 크롭
  static Future<Result<File, ImageProcessingException>> cropImage(
    File file, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    try {
      if (!await file.exists()) {
        return Result.failure(ImageProcessingException(
          '크롭할 이미지 파일을 찾을 수 없습니다.',
          'File path: ${file.path}',
        ));
      }

      // 파일 크기 확인 (메모리 제한)
      final fileSize = await file.length();
      final maxSize = AppConstants.maxImageSizeMB * 1024 * 1024;
      
      if (fileSize > maxSize) {
        return Result.failure(ImageProcessingException(
          '이미지 파일이 너무 큽니다. 더 작은 이미지를 사용해주세요.',
          'File size: ${fileSize / 1024 / 1024}MB, Max: ${AppConstants.maxImageSizeMB}MB',
        ));
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return Result.failure(ImageProcessingException(
          '이미지를 디코딩할 수 없습니다.',
          'Invalid image format',
        ));
      }

      // 크롭 범위 검증
      if (x < 0 || y < 0 || width <= 0 || height <= 0 ||
          x + width > image.width || y + height > image.height) {
        return Result.failure(ImageProcessingException(
          '크롭 범위가 이미지 크기를 초과합니다.',
          'Crop bounds: ($x, $y, $width, $height), Image size: (${image.width}, ${image.height})',
        ));
      }

      final cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_cropped.jpg';

      final croppedFile = File(targetPath);
      await croppedFile.writeAsBytes(img.encodeJpg(cropped));

      return Result.success(croppedFile);
    } catch (e) {
      return Result.failure(ImageProcessingException(
        '이미지 크롭 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  /// 이미지 리사이즈 (메모리 최적화)
  static Future<Result<File, ImageProcessingException>> resizeImage(
    File file, {
    required int width,
    required int height,
    int? maxMemoryMB,
  }) async {
    try {
      if (!await file.exists()) {
        return Result.failure(ImageProcessingException(
          '리사이즈할 이미지 파일을 찾을 수 없습니다.',
          'File path: ${file.path}',
        ));
      }

      final maxSize = (maxMemoryMB ?? AppConstants.maxImageSizeMB) * 1024 * 1024;
      final fileSize = await file.length();

      // 큰 파일은 스트리밍 방식으로 처리
      if (fileSize > maxSize) {
        return await _resizeImageStreaming(file, width, height);
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return Result.failure(ImageProcessingException(
          '이미지를 디코ng할 수 없습니다.',
          'Invalid image format',
        ));
      }

      final resized = img.copyResize(image, width: width, height: height);
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_resized.jpg';

      final resizedFile = File(targetPath);
      await resizedFile.writeAsBytes(img.encodeJpg(resized));

      return Result.success(resizedFile);
    } catch (e) {
      return Result.failure(ImageProcessingException(
        '이미지 리사이즈 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  /// 스트리밍 방식 이미지 리사이즈 (큰 파일용)
  static Future<Result<File, ImageProcessingException>> _resizeImageStreaming(
    File file,
    int width,
    int height,
  ) async {
    try {
      // 큰 파일의 경우 단계적으로 리사이즈
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return Result.failure(ImageProcessingException(
          '이미지를 디코ng할 수 없습니다.',
          'Invalid image format',
        ));
      }

      // 단계적 리사이즈로 메모리 사용량 감소
      img.Image resized = image;
      final targetWidth = width;
      final targetHeight = height;
      
      // 현재 크기가 목표 크기의 2배 이상이면 중간 크기로 먼저 리사이즈
      while (resized.width > targetWidth * 2 || resized.height > targetHeight * 2) {
        resized = img.copyResize(
          resized,
          width: (resized.width / 2).round(),
          height: (resized.height / 2).round(),
        );
      }
      
      // 최종 크기로 리사이즈
      resized = img.copyResize(resized, width: targetWidth, height: targetHeight);

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_resized.jpg';

      final resizedFile = File(targetPath);
      await resizedFile.writeAsBytes(img.encodeJpg(resized));

      return Result.success(resizedFile);
    } catch (e) {
      return Result.failure(ImageProcessingException(
        '이미지 리사이즈 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  static Future<Result<ui.Image, ImageProcessingException>> loadImage(File file) async {
    try {
      if (!await file.exists()) {
        return Result.failure(ImageProcessingException(
          '이미지 파일을 찾을 수 없습니다.',
          'File path: ${file.path}',
        ));
      }

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return Result.success(frame.image);
    } catch (e) {
      return Result.failure(ImageProcessingException(
        '이미지를 불러오는 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  /// 위젯을 이미지로 캡처
  static Future<Result<File, ImageProcessingException>> captureWidgetAsImage(
    GlobalKey key, {
    String? fileName,
    int quality = AppConstants.highImageQuality,
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return Result.failure(ImageProcessingException(
          '렌더링 경계를 찾을 수 없습니다.',
          'RenderRepaintBoundary not found',
        ));
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        return Result.failure(ImageProcessingException(
          '이미지 데이터를 변환할 수 없습니다.',
          'Failed to convert image to byte data',
        ));
      }

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final name = fileName ?? 'collage_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${dir.path}/$name.png');
      
      await file.writeAsBytes(pngBytes);

      // 품질이 100 미만이면 JPG로 압축
      if (quality < 100) {
        final compressedResult = await compressImage(file, quality: quality);
        if (compressedResult.isSuccess) {
          final compressed = compressedResult.valueOrNull;
          if (compressed != null) {
            await file.delete();
            return Result.success(compressed);
          }
        }
      }

      return Result.success(file);
    } catch (e) {
      return Result.failure(ImageProcessingException(
        '위젯 캡처 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  /// 썸네일 생성
  static Future<Result<File, ImageProcessingException>> createThumbnail(
    File file, {
    int size = AppConstants.thumbnailSize,
  }) async {
    try {
      if (!await file.exists()) {
        return Result.failure(ImageProcessingException(
          '썸네일을 생성할 이미지 파일을 찾을 수 없습니다.',
          'File path: ${file.path}',
        ));
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return Result.failure(ImageProcessingException(
          '이미지를 디코ng할 수 없습니다.',
          'Invalid image format',
        ));
      }

      final thumbnail = img.copyResizeCropSquare(image, size: size);
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';

      final thumbnailFile = File(targetPath);
      await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: AppConstants.defaultImageQuality));

      return Result.success(thumbnailFile);
    } catch (e) {
      return Result.failure(ImageProcessingException(
        '썸네일 생성 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }
}
