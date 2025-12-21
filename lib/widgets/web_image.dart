import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A widget that displays images from XFile
/// Compatible with both web and mobile platforms
class WebCompatibleImage extends StatefulWidget {
  final XFile imageFile;
  final BoxFit fit;

  const WebCompatibleImage({
    super.key,
    required this.imageFile,
    this.fit = BoxFit.cover,
  });

  @override
  State<WebCompatibleImage> createState() => _WebCompatibleImageState();
}

class _WebCompatibleImageState extends State<WebCompatibleImage> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, use Image.network with the XFile path
      return Image.network(
        widget.imageFile.path,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // For mobile, use Image.file
      return Image.file(
        File(widget.imageFile.path),
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.broken_image,
        size: 40,
        color: Colors.grey[500],
      ),
    );
  }
}
