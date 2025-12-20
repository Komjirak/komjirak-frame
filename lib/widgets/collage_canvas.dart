import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/collage_layout.dart';

class CollageCanvas extends StatefulWidget {
  final CollageLayout layout;
  final List<String> imagePaths;
  final Function(int, Offset, double)? onImageTransformed;
  final Color frameColor;
  final String? overlayText;
  final String? fontFamily;
  final Color? textColor;
  final GlobalKey? repaintKey; // For capturing as image

  const CollageCanvas({
    Key? key,
    required this.layout,
    required this.imagePaths,
    this.onImageTransformed,
    this.frameColor = Colors.white,
    this.overlayText,
    this.fontFamily,
    this.textColor,
    this.repaintKey,
  }) : super(key: key);

  @override
  State<CollageCanvas> createState() => _CollageCanvasState();
}

class _CollageCanvasState extends State<CollageCanvas> {
  final Map<int, Offset> _positions = {};
  final Map<int, double> _scales = {};

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.repaintKey,
      child: Container(
        decoration: BoxDecoration(
          color: widget.frameColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Image cells
                    ...List.generate(
                      widget.layout.cells.length,
                      (index) => _buildCell(index, constraints),
                    ),
                    // Text overlay if provided
                    if (widget.overlayText != null && widget.overlayText!.isNotEmpty)
                      _buildTextOverlay(constraints),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index, BoxConstraints constraints) {
    if (index >= widget.imagePaths.length) {
      return _buildPlaceholderCell(index, constraints);
    }

    final cell = widget.layout.cells[index];
    final imagePath = widget.imagePaths[index];

    return Positioned(
      left: (cell.column / 3) * constraints.maxWidth,
      top: (cell.row / 3) * constraints.maxHeight,
      width: (cell.columnSpan / 3) * constraints.maxWidth,
      height: (cell.rowSpan / 3) * constraints.maxHeight,
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _positions[index] = details.focalPoint;
            _scales[index] = details.scale;
          });
          widget.onImageTransformed?.call(
            index,
            details.focalPoint,
            details.scale,
          );
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.frameColor,
              width: 3,
            ),
          ),
          child: ClipRect(
            child: Transform.scale(
              scale: _scales[index] ?? 1.0,
              child: _buildImage(imagePath),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    // For web compatibility, use Image.network for URLs
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
      // For native platforms only, use Image.file
      if (kIsWeb) {
        // On web, show placeholder or use network image
        return _buildErrorPlaceholder();
      }
      try {
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      } catch (e) {
        return _buildErrorPlaceholder();
      }
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }
  }

  Widget _buildPlaceholderCell(int index, BoxConstraints constraints) {
    final cell = widget.layout.cells[index];

    return Positioned(
      left: (cell.column / 3) * constraints.maxWidth,
      top: (cell.row / 3) * constraints.maxHeight,
      width: (cell.columnSpan / 3) * constraints.maxWidth,
      height: (cell.rowSpan / 3) * constraints.maxHeight,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(
            color: widget.frameColor,
            width: 3,
          ),
        ),
        child: Icon(
          Icons.add_photo_alternate,
          size: 40,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.broken_image,
        size: 40,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildTextOverlay(BoxConstraints constraints) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.overlayText!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.textColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: widget.fontFamily,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
