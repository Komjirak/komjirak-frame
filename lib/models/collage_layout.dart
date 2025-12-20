enum LayoutType {
  classic,
  split,
  mosaic,
  film,
  polaroid,
  bubbles,
  grid,
  magazine,
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

  FrameCell({
    required this.row,
    required this.column,
    this.rowSpan = 1,
    this.columnSpan = 1,
    this.aspectRatio,
  });
}
