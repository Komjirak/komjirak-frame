enum LayoutType {
  classic,
  split,
  mosaic,
  film,
  polaroid,
  bubbles,
  grid,
  magazine,
  storybook,
  collage,
}

class CollageLayout {
  final String id;
  final String name;
  final LayoutType type;
  final int minPhotos;
  final int maxPhotos;
  final List<FrameCell> cells;

  CollageLayout({
    required this.id,
    required this.name,
    required this.type,
    required this.minPhotos,
    required this.maxPhotos,
    required this.cells,
  });
}

class FrameCell {
  final int row;
  final int column;
  final int rowSpan;
  final int columnSpan;
  final double? aspectRatio;
  
  // Custom bounds for dynamic sizing (0.0 to 1.0 normalized coordinates)
  double? customLeft;
  double? customTop;
  double? customWidth;
  double? customHeight;

  FrameCell({
    required this.row,
    required this.column,
    this.rowSpan = 1,
    this.columnSpan = 1,
    this.aspectRatio,
    this.customLeft,
    this.customTop,
    this.customWidth,
    this.customHeight,
  });
  
  FrameCell copyWith({
    double? customLeft,
    double? customTop,
    double? customWidth,
    double? customHeight,
  }) {
    return FrameCell(
      row: row,
      column: column,
      rowSpan: rowSpan,
      columnSpan: columnSpan,
      aspectRatio: aspectRatio,
      customLeft: customLeft ?? this.customLeft,
      customTop: customTop ?? this.customTop,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
    );
  }
}
