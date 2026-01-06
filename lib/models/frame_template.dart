import 'collage_layout.dart';

class FrameTemplates {
  static List<CollageLayout> getAllTemplates() {
    return [
      // 2장
      _verticalSplit2(),
      _verticalSplit2Variant(),  // 새 변형
      _largeSmall2(),
      _largeSmall2Variant(),  // 새 변형
      _horizontalSplit2(),
      _topBottom2(),
      
      // 3장
      _verticalSplit3(),
      _classic3(),
      _classic3Variant(),  // 새 변형
      _grid2x2Top3(),
      _largeWithSmall3(),
      _magazine3Feature(),
      
      // 4장
      _classicQuad4(),
      _oneLarge4(),
      _oneLarge4Variant(),
      _leftRight4(),  // 새 추가
      _topBottom4(),  // 새 추가
      _lShape4(),  // 새 추가
      _magazine4Spread(),
      
      // 5장
      _heroCenter5(),
      _grid5(),
      _pyramid5(),  // 새 추가
      _leftStack5(),  // 새 추가
      _crossPattern5(),  // 새 추가
      _magazine5Essay(),
      
      // 6장
      _grid2x3(),
      _grid3x2(),
      _grid6Hero(),
      _grid6HeroVariant(),
      _grid6Mosaic(),
      _doubleColumn6(),  // 새 추가
      _filmStrip6(),  // 새 추가
      _pyramid6(),  // 새 추가
      _magazine6Modular(),
      
      // 7장
      _grid7(),
      _heroCenter7(),
      _lShape7(),
      _magazine7Story(),
      
      // 8장
      _grid8(),
      _grid2x4(),
      _heroPair8(),
      _magazine8Event(),
      
      // 9장
      _grid9(),
      _grid3x3(),
      _heroPlus9(),
      _magazine9MoodBoard(),
      
      // 10장
      _grid10(),
      _grid5x2(),
      _filmStrip10(),
      _magazine10Gallery(),
      
      // 11-12장
      _complexGridA11(),
      _mosaic11(),
      _grid3x4(),
      _grid4x3(),
      _heroPlusGrid12(),
    ];
  }

  static List<CollageLayout> getTemplatesForPhotoCount(int photoCount) {
    return getAllTemplates()
        .where((layout) => layout.minPhotos <= photoCount && layout.maxPhotos >= photoCount)
        .toList();
  }

  // ===== 2장 레이아웃 =====
  
  // 2장 - 수직 분할 (Vertical Split)
  static CollageLayout _verticalSplit2() {
    return CollageLayout(
      id: 'vertical_split_2',
      name: 'Vertical Split',
      type: LayoutType.split,
      minPhotos: 2,
      maxPhotos: 2,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 3, columnSpan: 2),
      ],
    );
  }

  // 2장 - 좌우 분할 변형 (왼쪽 크게)
  static CollageLayout _verticalSplit2Variant() {
    return CollageLayout(
      id: 'vertical_split_2_variant',
      name: 'Vertical Split L',
      type: LayoutType.split,
      minPhotos: 2,
      maxPhotos: 2,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 4, columnSpan: 3),  // 왼쪽 크게
        FrameCell(row: 0, column: 3, rowSpan: 4, columnSpan: 1),  // 오른쪽 작게
      ],
    );
  }

  // 2장 - 상하 큰작 (Large-Small)
  static CollageLayout _largeSmall2() {
    return CollageLayout(
      id: 'large_small_2',
      name: 'Large-Small',
      type: LayoutType.classic,
      minPhotos: 2,
      maxPhotos: 2,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 3),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 3),
      ],
    );
  }

  // 2장 - 상하 큰작 변형 (작은 것 더 작게)
  static CollageLayout _largeSmall2Variant() {
    return CollageLayout(
      id: 'large_small_2_variant',
      name: 'Large-Small XL',
      type: LayoutType.classic,
      minPhotos: 2,
      maxPhotos: 2,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 4),  // 상단 매우 크게
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 4),  // 하단 작게
      ],
    );
  }

  // 2장 - 좌우 분할 (Horizontal Split)
  static CollageLayout _horizontalSplit2() {
    return CollageLayout(
      id: 'horizontal_split_2',
      name: 'Side by Side',
      type: LayoutType.split,
      minPhotos: 2,
      maxPhotos: 2,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 3, columnSpan: 1),
      ],
    );
  }

  // 2장 - 상하 분할 (Top-Bottom)
  static CollageLayout _topBottom2() {
    return CollageLayout(
      id: 'top_bottom_2',
      name: 'Top-Bottom',
      type: LayoutType.split,
      minPhotos: 2,
      maxPhotos: 2,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 3),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 3),
      ],
    );
  }

  // ===== 3장 레이아웃 =====
  
  // 3장 - 수직 3분할 (Vertical Split)
  static CollageLayout _verticalSplit3() {
    return CollageLayout(
      id: 'vertical_split_3',
      name: 'Vertical Split',
      type: LayoutType.split,
      minPhotos: 3,
      maxPhotos: 3,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 3, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 3, columnSpan: 1),
      ],
    );
  }

  // 3장 - 클래식 (큰사진 + 작은사진 2개)
  static CollageLayout _classic3() {
    return CollageLayout(
      id: 'classic_3',
      name: 'Classic',
      type: LayoutType.classic,
      minPhotos: 3,
      maxPhotos: 3,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 2, columnSpan: 1),
      ],
    );
  }

  // 3장 - 클래식 변형 (큰사진 더 크게)
  static CollageLayout _classic3Variant() {
    return CollageLayout(
      id: 'classic_3_variant',
      name: 'Classic Wide',
      type: LayoutType.classic,
      minPhotos: 3,
      maxPhotos: 3,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 4, columnSpan: 3),  // 왼쪽 매우 크게
        FrameCell(row: 0, column: 3, rowSpan: 2, columnSpan: 1),  // 오른쪽 상단
        FrameCell(row: 2, column: 3, rowSpan: 2, columnSpan: 1),  // 오른쪽 하단
      ],
    );
  }

  // 3장 - 2x2 그리드 위쪽 (Grid 2x2 Top)
  static CollageLayout _grid2x2Top3() {
    return CollageLayout(
      id: 'grid_2x2_top_3',
      name: 'Grid Top',
      type: LayoutType.grid,
      minPhotos: 3,
      maxPhotos: 3,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 3),
      ],
    );
  }

  // 3장 - 큰사진 하나 + 작은사진 여러개
  static CollageLayout _largeWithSmall3() {
    return CollageLayout(
      id: 'large_with_small_3',
      name: 'Large Focus',
      type: LayoutType.classic,
      minPhotos: 3,
      maxPhotos: 3,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 3),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // ===== 4장 레이아웃 =====
  
  // 4장 - 클래식 쿼드 (Classic Quad) - 2x2 균등 그리드
  static CollageLayout _classicQuad4() {
    return CollageLayout(
      id: 'classic_quad_4',
      name: 'Classic Quad',
      type: LayoutType.grid,
      minPhotos: 4,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // 4장 - 큰사진 하나 + 작은사진 여러개
  static CollageLayout _oneLarge4() {
    return CollageLayout(
      id: 'one_large_4',
      name: 'One Large',
      type: LayoutType.classic,
      minPhotos: 4,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 4),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 3, column: 3, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 4장 - 큰사진 하나 + 작은사진 여러개 변형 (하단 더 작게)
  static CollageLayout _oneLarge4Variant() {
    return CollageLayout(
      id: 'one_large_4_variant',
      name: 'One Large XL',
      type: LayoutType.classic,
      minPhotos: 4,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 4),  // 상단 매우 크게
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),  // 하단 3개 작게
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 4장 - 좌우 2분할 (Left-Right)
  static CollageLayout _leftRight4() {
    return CollageLayout(
      id: 'left_right_4',
      name: 'Left-Right',
      type: LayoutType.split,
      minPhotos: 4,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // 4장 - 상하 2분할 (Top-Bottom)
  static CollageLayout _topBottom4() {
    return CollageLayout(
      id: 'top_bottom_4',
      name: 'Top-Bottom',
      type: LayoutType.split,
      minPhotos: 4,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // 4장 - L자 레이아웃
  static CollageLayout _lShape4() {
    return CollageLayout(
      id: 'l_shape_4',
      name: 'L-Shape',
      type: LayoutType.classic,
      minPhotos: 4,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 2),  // 왼쪽 큰 사진
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // ===== 5장 레이아웃 =====
  
  // 5장 - 히어로 센터
  static CollageLayout _heroCenter5() {
    return CollageLayout(
      id: 'hero_center_5',
      name: 'Hero Center',
      type: LayoutType.classic,
      minPhotos: 5,
      maxPhotos: 5,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // 5장 - 그리드
  static CollageLayout _grid5() {
    return CollageLayout(
      id: 'grid_5',
      name: 'Grid 5',
      type: LayoutType.grid,
      minPhotos: 5,
      maxPhotos: 5,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // 5장 - 피라미드 레이아웃
  static CollageLayout _pyramid5() {
    return CollageLayout(
      id: 'pyramid_5',
      name: 'Pyramid',
      type: LayoutType.classic,
      minPhotos: 5,
      maxPhotos: 5,
      cells: [
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 2),  // 상단 중앙
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 2),  // 중간 왼쪽
        FrameCell(row: 1, column: 2, rowSpan: 2, columnSpan: 2),  // 중간 오른쪽
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 2),  // 하단 왼쪽
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 2),  // 하단 오른쪽
      ],
    );
  }

  // 5장 - 왼쪽 스택 레이아웃
  static CollageLayout _leftStack5() {
    return CollageLayout(
      id: 'left_stack_5',
      name: 'Left Stack',
      type: LayoutType.classic,
      minPhotos: 5,
      maxPhotos: 5,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 4, columnSpan: 2),  // 왼쪽 큰 사진
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 5장 - 십자 패턴
  static CollageLayout _crossPattern5() {
    return CollageLayout(
      id: 'cross_pattern_5',
      name: 'Cross',
      type: LayoutType.classic,
      minPhotos: 5,
      maxPhotos: 5,
      cells: [
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 2),  // 상단
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 1),  // 왼쪽
        FrameCell(row: 1, column: 1, rowSpan: 2, columnSpan: 2),  // 중앙 큰 사진
        FrameCell(row: 1, column: 3, rowSpan: 2, columnSpan: 1),  // 오른쪽
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 2),  // 하단
      ],
    );
  }

  // ===== 6장 레이아웃 =====
  
  // 6장 - 2x3 그리드 (3 columns, 2 rows)
  static CollageLayout _grid2x3() {
    return CollageLayout(
      id: 'grid_2x3',
      name: 'Grid 2x3',
      type: LayoutType.grid,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 1),
      ],
    );
  }

  // 6장 - 3x2 그리드 (2 columns, 3 rows)
  static CollageLayout _grid3x2() {
    return CollageLayout(
      id: 'grid_3x2',
      name: 'Grid 3x2',
      type: LayoutType.grid,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // 6장 - 히어로 스타일 (큰 이미지 1개 + 작은 이미지 5개)
  static CollageLayout _grid6Hero() {
    return CollageLayout(
      id: 'grid_6_hero',
      name: 'Hero Style',
      type: LayoutType.classic,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 6장 - 히어로 스타일 변형 (히어로 이미지 더 크게)
  static CollageLayout _grid6HeroVariant() {
    return CollageLayout(
      id: 'grid_6_hero_variant',
      name: 'Hero XL',
      type: LayoutType.classic,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 3),  // 히어로 더 크게
        FrameCell(row: 0, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 6장 - 모자이크 스타일
  static CollageLayout _grid6Mosaic() {
    return CollageLayout(
      id: 'grid_6_mosaic',
      name: 'Mosaic',
      type: LayoutType.mosaic,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 6장 - 더블 컬럼
  static CollageLayout _doubleColumn6() {
    return CollageLayout(
      id: 'double_column_6',
      name: 'Double Column',
      type: LayoutType.grid,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 6장 - 필름 스트립
  static CollageLayout _filmStrip6() {
    return CollageLayout(
      id: 'film_strip_6',
      name: 'Film Strip',
      type: LayoutType.film,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 4),  // 상단 와이드
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 4),  // 하단 와이드
      ],
    );
  }

  // 6장 - 피라미드
  static CollageLayout _pyramid6() {
    return CollageLayout(
      id: 'pyramid_6',
      name: 'Pyramid',
      type: LayoutType.classic,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 2),  // 상단 1개
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),  // 중간 3개
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 1, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 2),  // 하단 2개
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // ===== 7장 레이아웃 =====
  
  // 7장 - 그리드
  static CollageLayout _grid7() {
    return CollageLayout(
      id: 'grid_7',
      name: 'Grid 7',
      type: LayoutType.grid,
      minPhotos: 7,
      maxPhotos: 7,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 3),
      ],
    );
  }

  // 7장 - Hero Center
  static CollageLayout _heroCenter7() {
    return CollageLayout(
      id: 'hero_center_7',
      name: 'Hero Center',
      type: LayoutType.mosaic,
      minPhotos: 7,
      maxPhotos: 7,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 3), // Hero
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 7장 - L-Shape
  static CollageLayout _lShape7() {
    return CollageLayout(
      id: 'l_shape_7',
      name: 'L-Shape',
      type: LayoutType.mosaic,
      minPhotos: 7,
      maxPhotos: 7,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2), // Large
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 3),
      ],
    );
  }

  // ===== 8-10장 레이아웃 =====
  
  // 8장 - 그리드
  static CollageLayout _grid8() {
    return CollageLayout(
      id: 'grid_8',
      name: 'Grid 8',
      type: LayoutType.grid,
      minPhotos: 8,
      maxPhotos: 8,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 8장 - 2x4 Grid
  static CollageLayout _grid2x4() {
    return CollageLayout(
      id: 'grid_2x4',
      name: 'Grid 2x4',
      type: LayoutType.grid,
      minPhotos: 8,
      maxPhotos: 8,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 8장 - Hero Pair
  static CollageLayout _heroPair8() {
    return CollageLayout(
      id: 'hero_pair_8',
      name: 'Hero Pair',
      type: LayoutType.mosaic,
      minPhotos: 8,
      maxPhotos: 8,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 1), // Hero Left
        FrameCell(row: 1, column: 1, rowSpan: 2, columnSpan: 1), // Hero Right
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 4, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 4, column: 1, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 9장 - 그리드
  static CollageLayout _grid9() {
    return CollageLayout(
      id: 'grid_9',
      name: 'Grid 9',
      type: LayoutType.grid,
      minPhotos: 9,
      maxPhotos: 9,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 9장 - 3x3 Grid (Perfect Square)
  static CollageLayout _grid3x3() {
    return CollageLayout(
      id: 'grid_3x3',
      name: 'Perfect Grid',
      type: LayoutType.grid,
      minPhotos: 9,
      maxPhotos: 9,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 9장 - Hero Plus
  static CollageLayout _heroPlus9() {
    return CollageLayout(
      id: 'hero_plus_9',
      name: 'Hero Plus',
      type: LayoutType.mosaic,
      minPhotos: 9,
      maxPhotos: 9,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 2), // Hero
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 10장 - 비대칭 혼합
  static CollageLayout _grid10() {
    return CollageLayout(
      id: 'grid_10',
      name: 'Mixed 10',
      type: LayoutType.mosaic,
      minPhotos: 10,
      maxPhotos: 10,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 10장 - 5x2 Grid
  static CollageLayout _grid5x2() {
    return CollageLayout(
      id: 'grid_5x2',
      name: 'Grid 5x2',
      type: LayoutType.grid,
      minPhotos: 10,
      maxPhotos: 10,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 4, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 4, column: 1, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 10장 - Film Strip
  static CollageLayout _filmStrip10() {
    return CollageLayout(
      id: 'film_strip_10',
      name: 'Film Strip',
      type: LayoutType.mosaic,
      minPhotos: 10,
      maxPhotos: 10,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 4),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 4),
      ],
    );
  }

  // ===== 11-12장 레이아웃 =====
  
  // 11장 - 복합 그리드 A
  static CollageLayout _complexGridA11() {
    return CollageLayout(
      id: 'complex_grid_a_11',
      name: 'Complex Grid A',
      type: LayoutType.grid,
      minPhotos: 11,
      maxPhotos: 11,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 4),
      ],
    );
  }

  // 11장 - Mosaic
  static CollageLayout _mosaic11() {
    return CollageLayout(
      id: 'mosaic_11',
      name: 'Mosaic',
      type: LayoutType.mosaic,
      minPhotos: 11,
      maxPhotos: 11,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2), // Large
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 2),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 12장 - 3x4 그리드
  static CollageLayout _grid3x4() {
    return CollageLayout(
      id: 'grid_3x4',
      name: 'Grid 3x4',
      type: LayoutType.grid,
      minPhotos: 12,
      maxPhotos: 12,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 3, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 12장 - 4x3 Grid
  static CollageLayout _grid4x3() {
    return CollageLayout(
      id: 'grid_4x3',
      name: 'Grid 4x3',
      type: LayoutType.grid,
      minPhotos: 12,
      maxPhotos: 12,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 12장 - Hero Plus Grid
  static CollageLayout _heroPlusGrid12() {
    return CollageLayout(
      id: 'hero_plus_grid_12',
      name: 'Hero Plus Grid',
      type: LayoutType.mosaic,
      minPhotos: 12,
      maxPhotos: 12,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2), // Hero
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 0, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 3, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 3, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // ===== 매거진 스타일 레이아웃 =====
  
  // 3장 - 피처 스토리 (Feature Story)
  static CollageLayout _magazine3Feature() {
    return CollageLayout(
      id: 'magazine_3_feature',
      name: 'Feature Story',
      type: LayoutType.magazine,
      minPhotos: 3,
      maxPhotos: 3,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 4, columnSpan: 2), // 큰 메인 이미지
        FrameCell(row: 0, column: 2, rowSpan: 2, columnSpan: 1), // 작은 이미지 1
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 1), // 작은 이미지 2
      ],
    );
  }

  // 4장 - 스프레드 (Magazine Spread)
  static CollageLayout _magazine4Spread() {
    return CollageLayout(
      id: 'magazine_4_spread',
      name: 'Spread',
      type: LayoutType.magazine,
      minPhotos: 4,
      maxPhotos: 4,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 2),
      ],
    );
  }

  // 5장 - 포토 에세이 (Photo Essay)
  static CollageLayout _magazine5Essay() {
    return CollageLayout(
      id: 'magazine_5_essay',
      name: 'Photo Essay',
      type: LayoutType.magazine,
      minPhotos: 5,
      maxPhotos: 5,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 3, columnSpan: 2), // 큰 히어로 이미지
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 3), // 하단 와이드
      ],
    );
  }

  // 6장 - 모듈러 그리드 (Modular Grid)
  static CollageLayout _magazine6Modular() {
    return CollageLayout(
      id: 'magazine_6_modular',
      name: 'Modular Grid',
      type: LayoutType.magazine,
      minPhotos: 6,
      maxPhotos: 6,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2),
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 2, columnSpan: 1),
      ],
    );
  }

  // 7장 - 스토리텔링 (Story Layout)
  static CollageLayout _magazine7Story() {
    return CollageLayout(
      id: 'magazine_7_story',
      name: 'Storytelling',
      type: LayoutType.magazine,
      minPhotos: 7,
      maxPhotos: 7,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2), // 큰 오프닝
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 3), // 하단 와이드
      ],
    );
  }

  // 8장 - 이벤트 모자이크 (Event Mosaic)
  static CollageLayout _magazine8Event() {
    return CollageLayout(
      id: 'magazine_8_event',
      name: 'Event Mosaic',
      type: LayoutType.magazine,
      minPhotos: 8,
      maxPhotos: 8,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 1, columnSpan: 2), // 상단 와이드
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 0, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 1, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 2, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 2),
      ],
    );
  }

  // 9장 - 무드보드 (Mood Board)
  static CollageLayout _magazine9MoodBoard() {
    return CollageLayout(
      id: 'magazine_9_moodboard',
      name: 'Mood Board',
      type: LayoutType.magazine,
      minPhotos: 9,
      maxPhotos: 9,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2), // 중앙 큰 이미지
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 1),
      ],
    );
  }

  // 10장 - 갤러리 (Gallery Layout)
  static CollageLayout _magazine10Gallery() {
    return CollageLayout(
      id: 'magazine_10_gallery',
      name: 'Gallery',
      type: LayoutType.magazine,
      minPhotos: 10,
      maxPhotos: 10,
      cells: [
        FrameCell(row: 0, column: 0, rowSpan: 2, columnSpan: 2), // 큰 메인 이미지
        FrameCell(row: 0, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 1, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 2, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 0, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 1, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 3, column: 2, rowSpan: 1, columnSpan: 1),
        FrameCell(row: 4, column: 0, rowSpan: 1, columnSpan: 3), // 하단 와이드
      ],
    );
  }
}
