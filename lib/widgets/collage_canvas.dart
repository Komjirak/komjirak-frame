import 'package:flutter/material.dart';
import '../models/collage_layout.dart';

class CollageCanvas extends StatefulWidget {
  final CollageLayout layout;
  final List<String> imagePaths;
  final Function(int, Offset, double)? onImageTransformed;

  const CollageCanvas({
    Key? key,
    required this.layout,
    required this.imagePaths,
    this.onImageTransformed,
  }) : super(key: key);

  @override
  State<CollageCanvas> createState() => _CollageCanvasState();
}

class _CollageCanvasState extends State<CollageCanvas> {
  final Map<int, Offset> _positions = {};
  final Map<int, double> _scales = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                children: List.generate(
                  widget.layout.cells.length,
                  (index) => _buildCell(index, constraints),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index, BoxConstraints constraints) {
    if (index >= widget.imagePaths.length) {
      return const SizedBox.shrink();
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
              color: Colors.white,
              width: 2,
            ),
          ),
          child: ClipRect(
            child: Transform.scale(
              scale: _scales[index] ?? 1.0,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
