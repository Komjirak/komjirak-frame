import 'collage_layout.dart';

class FrameTemplates {
  static List<CollageLayout> getAllTemplates() {
    return [
      _classicLayout(),
      _splitLayout(),
      _mosaicLayout(),
      _filmLayout(),
      _polaroidLayout(),
      _bubblesLayout(),
    ];
  }

  static CollageLayout _classicLayout() {
    return CollageLayout(
      id: 'classic',
      name: 'Classic',
      type: LayoutType.classic,
      minPhotos: 3,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  static CollageLayout _splitLayout() {
    return CollageLayout(
      id: 'split',
      name: 'Split',
      type: LayoutType.split,
      minPhotos: 2,
      maxPhotos: 2,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  static CollageLayout _mosaicLayout() {
    return CollageLayout(
      id: 'mosaic',
      name: 'Mosaic',
      type: LayoutType.mosaic,
      minPhotos: 4,
      maxPhotos: 9,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  static CollageLayout _filmLayout() {
    return CollageLayout(
      id: 'film',
      name: 'Film',
      type: LayoutType.film,
      minPhotos: 3,
      maxPhotos: 5,
      cells: List.generate(
        3,
        (index) => FrameCell(row: index, column: 0, rowSpan: 1, columnSpan: 1),
      ),
    );
  }

  static CollageLayout _polaroidLayout() {
    return CollageLayout(
      id: 'polaroid',
      name: 'Polaroid',
      type: LayoutType.polaroid,
      minPhotos: 1,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  static CollageLayout _bubblesLayout() {
    return CollageLayout(
      id: 'bubbles',
      name: 'Bubbles',
      type: LayoutType.bubbles,
      minPhotos: 4,
      maxPhotos: 8,
      cells: List.generate(
        4,
        (index) => FrameCell(
          row: index ~/ 2,
          column: index % 2,
          rowSpan: 1,
          columnSpan: 1,
        ),
      ),
    );
  }
}
