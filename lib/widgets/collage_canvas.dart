import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/collage_layout.dart';
import '../models/text_element.dart';

class CollageCanvas extends StatefulWidget {
  final CollageLayout layout;
  final List<String> imagePaths;
  final Function(int, Offset, double)? onImageTransformed;
  final Function(int)? onImageTapped;
  final Function(int)? onImageDoubleTapped;
  final Color frameColor;
  final String? overlayText;  // Legacy: single text support
  final List<TextElement>? textElements;  // New: multiple text elements
  final String? fontFamily;
  final Color? textColor;
  final Color? textBackgroundColor;
  final double? textSize;
  final GlobalKey? repaintKey;
  final double frameSpacing;
  final double aspectRatio;
  final Offset? textPosition;
  final Function(String?, Offset)? onTextPositionChanged;  // Updated: textId, position
  final Function(String?, double)? onTextSizeChanged;  // Updated: textId, size
  final Function(String)? onTextTapped;  // New: text element tapped
  final double cornerRadius;
  final bool editMode;  // New: Enable frame editing
  final Function(List<FrameCell>)? onLayoutChanged;  // New: Callback when layout changes

  const CollageCanvas({
    super.key,
    required this.layout,
    required this.imagePaths,
    this.onImageTransformed,
    this.onImageTapped,
    this.onImageDoubleTapped,
    this.frameColor = Colors.white,
    this.overlayText,
    this.textElements,
    this.fontFamily,
    this.textColor,
    this.textBackgroundColor,
    this.textSize,
    this.repaintKey,
    this.frameSpacing = 2.0,
    this.aspectRatio = 1.0,
    this.textPosition,
    this.onTextPositionChanged,
    this.onTextSizeChanged,
    this.onTextTapped,
    this.cornerRadius = 0.0,
    this.editMode = false,
    this.onLayoutChanged,
  });

  @override
  State<CollageCanvas> createState() => _CollageCanvasState();
}

class _CollageCanvasState extends State<CollageCanvas> {
  final Map<int, Offset> _positions = {};
  final Map<int, double> _scales = {};
  final Map<int, Offset> _focalPoints = {};
  late List<FrameCell> _editableCells;  // Local copy for editing
  bool _isDraggingDivider = false;  // Track if user is dragging a divider
  String? _hoveredDivider;  // Track which divider is being hovered

  @override
  void initState() {
    super.initState();
    _editableCells = List.from(widget.layout.cells);
  }

  @override
  void didUpdateWidget(CollageCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layout.id != widget.layout.id) {
      _editableCells = List.from(widget.layout.cells);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.frameColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Image cells - only render cells that have images
              ...List.generate(
                widget.imagePaths.length.clamp(0, _editableCells.length),
                (index) => _buildCell(index, constraints),
              ),
              // Draggable dividers - only show when hovering or dragging
              if (widget.editMode)
                ..._buildDividers(constraints),
              // Text overlays - support multiple text elements
              if (widget.textElements != null && widget.textElements!.isNotEmpty)
                ...widget.textElements!.map((textElement) => _buildTextOverlay(constraints, textElement))
              // Legacy: single text overlay support
              else if (widget.overlayText != null && widget.overlayText!.isNotEmpty)
                _buildTextOverlay(constraints, null, widget.overlayText),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCell(int index, BoxConstraints constraints) {
    final cell = _editableCells[index];
    final imagePath = widget.imagePaths[index];

    // Use custom bounds if available, otherwise calculate from grid
    final double left, top, width, height;
    
    if (cell.customLeft != null && cell.customTop != null && 
        cell.customWidth != null && cell.customHeight != null) {
      // Use custom bounds (normalized 0-1)
      left = cell.customLeft! * constraints.maxWidth;
      top = cell.customTop! * constraints.maxHeight;
      width = cell.customWidth! * constraints.maxWidth;
      height = cell.customHeight! * constraints.maxHeight;
    } else {
      // Calculate max grid columns dynamically (3 or 4 columns)
      double maxColumns = _editableCells.fold<int>(
        0,
        (max, cell) => (cell.column + cell.columnSpan) > max ? (cell.column + cell.columnSpan) : max,
      ).clamp(3, 4).toDouble();
      if (maxColumns == 0) maxColumns = 1.0;

      // Calculate max grid rows dynamically (3 or 4 rows)
      double maxRows = _editableCells.fold<int>(
        0,
        (max, cell) => (cell.row + cell.rowSpan) > max ? (cell.row + cell.rowSpan) : max,
      ).clamp(3, 4).toDouble();
      if (maxRows == 0) maxRows = 1.0;

      left = (cell.column / maxColumns) * constraints.maxWidth;
      top = (cell.row / maxRows) * constraints.maxHeight;
      width = (cell.columnSpan / maxColumns) * constraints.maxWidth;
      height = (cell.rowSpan / maxRows) * constraints.maxHeight;
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () {
          // Call onImageTapped callback if provided
          widget.onImageTapped?.call(index);
        },
        onLongPress: () {
          // Call onImageTapped callback for long press (to show options menu)
          widget.onImageTapped?.call(index);
        },
        onDoubleTap: () {
          // Reset image transform on double tap
          setState(() {
            _positions.remove(index);
            _scales.remove(index);
            _focalPoints.remove(index);
          });
          widget.onImageDoubleTapped?.call(index);
        },
        onScaleStart: (details) {
          // Store initial focal point
          setState(() {
            _focalPoints[index] = details.localFocalPoint;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            // Update scale
            final newScale = (_scales[index] ?? 1.0) * details.scale;
            _scales[index] = newScale.clamp(0.5, 3.0); // Limit zoom range
            
            // Update position for panning
            if (details.scale == 1.0) {
              final currentPos = _positions[index] ?? Offset.zero;
              _positions[index] = currentPos + details.focalPointDelta;
            }
          });
          widget.onImageTransformed?.call(
            index,
            _positions[index] ?? Offset.zero,
            _scales[index] ?? 1.0,
          );
        },
        onScaleEnd: (details) {
          // Reset base scale for next gesture
        },
        child: Container(
          margin: widget.frameSpacing > 0 ? EdgeInsets.all(widget.frameSpacing) : EdgeInsets.zero,
          decoration: BoxDecoration(
            border: widget.frameSpacing > 0 ? Border.all(
              color: widget.frameColor,
              width: 3,
            ) : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            child: Transform.scale(
              scale: _scales[index] ?? 1.0,
              child: Transform.translate(
                offset: _positions[index] ?? Offset.zero,
                child: _buildImage(imagePath),
              ),
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
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      // Handle file paths - remove file:// prefix if exists
      String cleanPath = imagePath.replaceFirst('file://', '');
      
      if (kIsWeb) {
        // On web, show placeholder or use network image
        return _buildErrorPlaceholder();
      }
      try {
        return Image.file(
          File(cleanPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      } catch (e) {
        return _buildErrorPlaceholder();
      }
    }
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

  Widget _buildTextOverlay(BoxConstraints constraints, [TextElement? textElement, String? legacyText]) {
    // Use TextElement if provided, otherwise use legacy single text
    final text = textElement?.text ?? legacyText ?? '';
    final safeMaxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 1.0;
    final safeMaxHeight = constraints.maxHeight > 0 ? constraints.maxHeight : 1.0;
    final position = textElement?.position ?? widget.textPosition ?? Offset(safeMaxWidth / 2, safeMaxHeight - 60);
    final textSize = textElement?.size ?? widget.textSize ?? 18.0;
    final fontFamily = textElement?.fontFamily ?? widget.fontFamily;
    final textColor = textElement?.textColor ?? widget.textColor ?? Colors.white;
    final backgroundColor = textElement?.backgroundColor ?? widget.textBackgroundColor ?? Colors.black.withValues(alpha: 0.6);
    final textId = textElement?.id;
    final isSelected = textElement?.isSelected ?? false;
    
    if (text.isEmpty) return const SizedBox.shrink();
    
    final clampMaxWidth = (safeMaxWidth - 200) > 0 ? (safeMaxWidth - 200) : 1.0;
    final clampMaxHeight = (safeMaxHeight - 100) > 0 ? (safeMaxHeight - 100) : 1.0;
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        children: [
          Positioned(
            left: position.dx.clamp(0.0, clampMaxWidth),
            top: position.dy.clamp(0.0, clampMaxHeight),
            child: GestureDetector(
              onTap: () {
                if (textId != null && widget.onTextTapped != null) {
                  widget.onTextTapped!(textId);
                }
              },
              onScaleStart: (details) {
                // Store initial state
              },
              onScaleUpdate: (details) {
                if (textId == null) {
                  // Legacy single text handling
                  if (details.scale != 1.0 && widget.onTextSizeChanged != null) {
                    final newSize = (textSize * details.scale).clamp(12.0, 48.0);
                    widget.onTextSizeChanged!(null, newSize);
                  }
                  if (details.focalPointDelta.dx != 0 || details.focalPointDelta.dy != 0) {
                    if (widget.onTextPositionChanged != null) {
                      widget.onTextPositionChanged!(
                        null,
                        Offset(
                          (position.dx + details.focalPointDelta.dx).clamp(0, clampMaxWidth),
                          (position.dy + details.focalPointDelta.dy).clamp(0, clampMaxHeight),
                        ),
                      );
                    }
                  }
                } else {
                  // Multiple text elements handling
                  if (details.scale != 1.0 && widget.onTextSizeChanged != null) {
                    final newSize = (textSize * details.scale).clamp(12.0, 48.0);
                    widget.onTextSizeChanged!(textId, newSize);
                  }
                  if (details.focalPointDelta.dx != 0 || details.focalPointDelta.dy != 0) {
                    if (widget.onTextPositionChanged != null) {
                      widget.onTextPositionChanged!(
                        textId,
                        Offset(
                          (position.dx + details.focalPointDelta.dx).clamp(0, constraints.maxWidth - 200),
                          (position.dy + details.focalPointDelta.dy).clamp(0, constraints.maxHeight - 100),
                        ),
                      );
                    }
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                      : null,
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: _getTextStyle(fontFamily, textSize, textColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getTextStyle(String? fontFamily, double fontSize, [Color? textColor]) {
    final color = textColor ?? widget.textColor ?? Colors.white;
    final baseStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.5),
          offset: const Offset(1, 1),
          blurRadius: 3,
        ),
      ],
    );

    if (fontFamily == null || fontFamily.isEmpty || fontFamily == 'Roboto') {
      return baseStyle;
    }

    try {
      switch (fontFamily) {
        case 'Noto Serif KR':
          return GoogleFonts.notoSerifKr(textStyle: baseStyle);
        case 'Black Han Sans':
          return GoogleFonts.blackHanSans(textStyle: baseStyle);
        case 'Nanum Pen Script':
          return GoogleFonts.nanumPenScript(textStyle: baseStyle);
        case 'Do Hyeon':
          return GoogleFonts.doHyeon(textStyle: baseStyle);
        case 'Pacifico':
          return GoogleFonts.pacifico(textStyle: baseStyle);
        case 'Bebas Neue':
          return GoogleFonts.bebasNeue(textStyle: baseStyle);
        case 'Dancing Script':
          return GoogleFonts.dancingScript(textStyle: baseStyle);
        case 'Monoton':
          return GoogleFonts.monoton(textStyle: baseStyle);
        case 'Righteous':
          return GoogleFonts.righteous(textStyle: baseStyle);
        default:
          return baseStyle;
      }
    } catch (e) {
      return baseStyle;
    }
  }

  // Build draggable dividers for frame editing
  List<Widget> _buildDividers(BoxConstraints constraints) {
    List<Widget> dividers = [];
    
    // Find all unique horizontal and vertical boundaries
    Set<double> horizontalBoundaries = {};
    Set<double> verticalBoundaries = {};
    
    for (var cell in _editableCells) {
      if (cell.customLeft != null && cell.customTop != null &&
          cell.customWidth != null && cell.customHeight != null) {
        // Use custom bounds
        horizontalBoundaries.add(cell.customTop!);
        horizontalBoundaries.add(cell.customTop! + cell.customHeight!);
        verticalBoundaries.add(cell.customLeft!);
        verticalBoundaries.add(cell.customLeft! + cell.customWidth!);
      } else {
        // Use grid bounds
        final maxColumns = _editableCells.fold<int>(
          0,
          (max, cell) => (cell.column + cell.columnSpan) > max ? (cell.column + cell.columnSpan) : max,
        ).clamp(3, 4).toDouble();
        
        final maxRows = _editableCells.fold<int>(
          0,
          (max, cell) => (cell.row + cell.rowSpan) > max ? (cell.row + cell.rowSpan) : max,
        ).clamp(3, 4).toDouble();
        
        horizontalBoundaries.add(cell.row / maxRows);
        horizontalBoundaries.add((cell.row + cell.rowSpan) / maxRows);
        verticalBoundaries.add(cell.column / maxColumns);
        verticalBoundaries.add((cell.column + cell.columnSpan) / maxColumns);
      }
    }
    
    // Remove boundaries at edges (0.0 and 1.0)
    horizontalBoundaries.remove(0.0);
    horizontalBoundaries.remove(1.0);
    verticalBoundaries.remove(0.0);
    verticalBoundaries.remove(1.0);
    
    // Create horizontal dividers
    for (var y in horizontalBoundaries) {
      final dividerId = 'h_$y';
      final isHovered = _hoveredDivider == dividerId;
      final shouldShow = isHovered || _isDraggingDivider;
      
      dividers.add(
        Positioned(
          left: 0,
          top: y * constraints.maxHeight - 8,
          width: constraints.maxWidth,
          height: 16,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            onEnter: (_) {
              setState(() {
                _hoveredDivider = dividerId;
              });
            },
            onExit: (_) {
              if (!_isDraggingDivider) {
                setState(() {
                  _hoveredDivider = null;
                });
              }
            },
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _isDraggingDivider = true;
                  _hoveredDivider = dividerId;
                });
              },
              onPanUpdate: (details) {
                _handleHorizontalDividerDrag(y, details.delta.dy, constraints);
              },
              onPanEnd: (_) {
                setState(() {
                  _isDraggingDivider = false;
                  _hoveredDivider = null;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: shouldShow ? 4 : 0,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: shouldShow ? 0.8 : 0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: shouldShow
                        ? Container(
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Create vertical dividers
    for (var x in verticalBoundaries) {
      final dividerId = 'v_$x';
      final isHovered = _hoveredDivider == dividerId;
      final shouldShow = isHovered || _isDraggingDivider;
      
      dividers.add(
        Positioned(
          left: x * constraints.maxWidth - 8,
          top: 0,
          width: 16,
          height: constraints.maxHeight,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            onEnter: (_) {
              setState(() {
                _hoveredDivider = dividerId;
              });
            },
            onExit: (_) {
              if (!_isDraggingDivider) {
                setState(() {
                  _hoveredDivider = null;
                });
              }
            },
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _isDraggingDivider = true;
                  _hoveredDivider = dividerId;
                });
              },
              onPanUpdate: (details) {
                _handleVerticalDividerDrag(x, details.delta.dx, constraints);
              },
              onPanEnd: (_) {
                setState(() {
                  _isDraggingDivider = false;
                  _hoveredDivider = null;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: shouldShow ? 4 : 0,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: shouldShow ? 0.8 : 0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: shouldShow
                        ? Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return dividers;
  }

  void _handleHorizontalDividerDrag(double currentY, double deltaY, BoxConstraints constraints) {
    setState(() {
      final normalizedDelta = deltaY / constraints.maxHeight;
      final newY = (currentY + normalizedDelta).clamp(0.05, 0.95);
      
      // Update cells that share this boundary
      for (int i = 0; i < _editableCells.length; i++) {
        final cell = _editableCells[i];
        
        // Initialize custom bounds if not set
        if (cell.customLeft == null) {
          final maxColumns = _editableCells.fold<int>(
            0,
            (max, c) => (c.column + c.columnSpan) > max ? (c.column + c.columnSpan) : max,
          ).clamp(3, 4).toDouble();
          
          final maxRows = _editableCells.fold<int>(
            0,
            (max, c) => (c.row + c.rowSpan) > max ? (c.row + c.rowSpan) : max,
          ).clamp(3, 4).toDouble();
          
          _editableCells[i] = cell.copyWith(
            customLeft: cell.column / maxColumns,
            customTop: cell.row / maxRows,
            customWidth: cell.columnSpan / maxColumns,
            customHeight: cell.rowSpan / maxRows,
          );
        }
        
        final updatedCell = _editableCells[i];
        final bottomEdge = updatedCell.customTop! + updatedCell.customHeight!;
        
        // If this divider is at the bottom of this cell
        if ((bottomEdge - currentY).abs() < 0.01) {
          final heightChange = newY - bottomEdge;
          _editableCells[i] = updatedCell.copyWith(
            customHeight: (updatedCell.customHeight! + heightChange).clamp(0.1, 0.9),
          );
        }
        // If this divider is at the top of this cell
        else if ((updatedCell.customTop! - currentY).abs() < 0.01) {
          final heightChange = updatedCell.customTop! - newY;
          _editableCells[i] = updatedCell.copyWith(
            customTop: newY,
            customHeight: (updatedCell.customHeight! + heightChange).clamp(0.1, 0.9),
          );
        }
      }
      
      widget.onLayoutChanged?.call(_editableCells);
    });
  }

  void _handleVerticalDividerDrag(double currentX, double deltaX, BoxConstraints constraints) {
    setState(() {
      final normalizedDelta = deltaX / constraints.maxWidth;
      final newX = (currentX + normalizedDelta).clamp(0.05, 0.95);
      
      // Update cells that share this boundary
      for (int i = 0; i < _editableCells.length; i++) {
        final cell = _editableCells[i];
        
        // Initialize custom bounds if not set
        if (cell.customLeft == null) {
          final maxColumns = _editableCells.fold<int>(
            0,
            (max, c) => (c.column + c.columnSpan) > max ? (c.column + c.columnSpan) : max,
          ).clamp(3, 4).toDouble();
          
          final maxRows = _editableCells.fold<int>(
            0,
            (max, c) => (c.row + c.rowSpan) > max ? (c.row + c.rowSpan) : max,
          ).clamp(3, 4).toDouble();
          
          _editableCells[i] = cell.copyWith(
            customLeft: cell.column / maxColumns,
            customTop: cell.row / maxRows,
            customWidth: cell.columnSpan / maxColumns,
            customHeight: cell.rowSpan / maxRows,
          );
        }
        
        final updatedCell = _editableCells[i];
        final rightEdge = updatedCell.customLeft! + updatedCell.customWidth!;
        
        // If this divider is at the right edge of this cell
        if ((rightEdge - currentX).abs() < 0.01) {
          final widthChange = newX - rightEdge;
          _editableCells[i] = updatedCell.copyWith(
            customWidth: (updatedCell.customWidth! + widthChange).clamp(0.1, 0.9),
          );
        }
        // If this divider is at the left edge of this cell
        else if ((updatedCell.customLeft! - currentX).abs() < 0.01) {
          final widthChange = updatedCell.customLeft! - newX;
          _editableCells[i] = updatedCell.copyWith(
            customLeft: newX,
            customWidth: (updatedCell.customWidth! + widthChange).clamp(0.1, 0.9),
          );
        }
      }
      
      widget.onLayoutChanged?.call(_editableCells);
    });
  }
}
