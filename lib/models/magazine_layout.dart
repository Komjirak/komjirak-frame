import 'package:flutter/material.dart';

/// Magazine Layout Frame - 절대 위치 기반 자유 배치
class MagazineFrame {
  final double x; // 0.0 ~ 1.0 (왼쪽에서 오른쪽)
  final double y; // 0.0 ~ 1.0 (위에서 아래)
  final double width; // 0.0 ~ 1.0
  final double height; // 0.0 ~ 1.0
  final int zIndex; // 레이어 순서 (높을수록 위)
  final double rotation; // 회전 각도 (라디안)
  final bool hasPlaceholder; // 플레이스홀더 표시 여부

  const MagazineFrame({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.zIndex = 0,
    this.rotation = 0,
    this.hasPlaceholder = true,
  });
}

/// Magazine Layout Model
class MagazineLayout {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int photoCount;
  final List<MagazineFrame> frames;
  final Color? accentColor;

  const MagazineLayout({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.photoCount,
    required this.frames,
    this.accentColor,
  });
}

/// Magazine Layouts Collection
class MagazineLayouts {
  static List<MagazineLayout> getAllLayouts() {
    return [
      customCanvas(),
      featureStory3(),
      photoEssay5(),
      eventMosaic8(),
      modularGrid6(),
      dynamicMoodBoard9(),
      galleryShowcase10(),
    ];
  }

  // Custom Canvas - 사용자가 자유롭게 배치할 수 있는 유연한 그리드
  static MagazineLayout customCanvas() {
    return const MagazineLayout(
      id: 'custom_canvas',
      name: 'Custom Canvas',
      description: 'Flexible grid for creative layouts',
      icon: Icons.brush,
      photoCount: 6,
      frames: [
        // 2x3 유연한 그리드 - 사용자가 원하는 대로 조합 가능
        MagazineFrame(x: 0.0, y: 0.0, width: 0.48, height: 0.32),
        MagazineFrame(x: 0.52, y: 0.0, width: 0.48, height: 0.32),
        MagazineFrame(x: 0.0, y: 0.34, width: 0.48, height: 0.32),
        MagazineFrame(x: 0.52, y: 0.34, width: 0.48, height: 0.32),
        MagazineFrame(x: 0.0, y: 0.68, width: 0.48, height: 0.32),
        MagazineFrame(x: 0.52, y: 0.68, width: 0.48, height: 0.32),
      ],
    );
  }

  // 3장 - Feature Story
  static MagazineLayout featureStory3() {
    return const MagazineLayout(
      id: 'feature_story_3',
      name: 'Feature Story',
      description: 'Bold hero image with supporting photos',
      icon: Icons.auto_stories,
      photoCount: 3,
      frames: [
        // 큰 메인 이미지 (왼쪽 2/3)
        MagazineFrame(x: 0.0, y: 0.0, width: 0.65, height: 1.0),
        // 작은 이미지 1 (오른쪽 상단)
        MagazineFrame(x: 0.68, y: 0.0, width: 0.32, height: 0.48),
        // 작은 이미지 2 (오른쪽 하단)
        MagazineFrame(x: 0.68, y: 0.52, width: 0.32, height: 0.48),
      ],
    );
  }

  // 5장 - Photo Essay
  static MagazineLayout photoEssay5() {
    return const MagazineLayout(
      id: 'photo_essay_5',
      name: 'Photo Essay',
      description: 'Narrative layout with hero and details',
      icon: Icons.article,
      photoCount: 5,
      frames: [
        // 큰 히어로 이미지 (왼쪽)
        MagazineFrame(x: 0.0, y: 0.0, width: 0.6, height: 0.7),
        // 작은 이미지들 (오른쪽)
        MagazineFrame(x: 0.63, y: 0.0, width: 0.37, height: 0.22),
        MagazineFrame(x: 0.63, y: 0.24, width: 0.37, height: 0.22),
        MagazineFrame(x: 0.63, y: 0.48, width: 0.37, height: 0.22),
        // 하단 와이드
        MagazineFrame(x: 0.0, y: 0.75, width: 1.0, height: 0.25),
      ],
    );
  }

  // 8장 - Event Mosaic
  static MagazineLayout eventMosaic8() {
    return const MagazineLayout(
      id: 'event_mosaic_8',
      name: 'Event Mosaic',
      description: 'Dynamic event highlights layout',
      icon: Icons.celebration,
      photoCount: 8,
      frames: [
        // 상단 와이드 배너
        MagazineFrame(x: 0.0, y: 0.0, width: 0.7, height: 0.25),
        MagazineFrame(x: 0.72, y: 0.0, width: 0.28, height: 0.25),
        // 중간 섹션
        MagazineFrame(x: 0.0, y: 0.27, width: 0.3, height: 0.35),
        MagazineFrame(x: 0.32, y: 0.27, width: 0.3, height: 0.35),
        MagazineFrame(x: 0.64, y: 0.27, width: 0.36, height: 0.35),
        // 하단 섹션
        MagazineFrame(x: 0.0, y: 0.64, width: 0.48, height: 0.36),
        MagazineFrame(x: 0.5, y: 0.64, width: 0.24, height: 0.36),
        MagazineFrame(x: 0.76, y: 0.64, width: 0.24, height: 0.36),
      ],
    );
  }

  // 6장 - Modular Grid
  static MagazineLayout modularGrid6() {
    return const MagazineLayout(
      id: 'modular_grid_6',
      name: 'Modular Grid',
      description: 'Clean architectural composition',
      icon: Icons.grid_on,
      photoCount: 6,
      frames: [
        // 큰 모듈 (왼쪽 상단)
        MagazineFrame(x: 0.0, y: 0.0, width: 0.6, height: 0.55),
        // 오른쪽 작은 모듈들
        MagazineFrame(x: 0.62, y: 0.0, width: 0.38, height: 0.26),
        MagazineFrame(x: 0.62, y: 0.28, width: 0.38, height: 0.27),
        // 하단 모듈들
        MagazineFrame(x: 0.0, y: 0.58, width: 0.3, height: 0.42),
        MagazineFrame(x: 0.32, y: 0.58, width: 0.32, height: 0.42),
        MagazineFrame(x: 0.66, y: 0.58, width: 0.34, height: 0.42),
      ],
    );
  }

  // 9장 - Dynamic Mood Board
  static MagazineLayout dynamicMoodBoard9() {
    return const MagazineLayout(
      id: 'mood_board_9',
      name: 'Mood Board',
      description: 'Creative scattered polaroid style',
      icon: Icons.auto_awesome,
      photoCount: 9,
      frames: [
        // 중앙 큰 이미지
        MagazineFrame(x: 0.15, y: 0.1, width: 0.5, height: 0.55, rotation: -0.03),
        // 주변 작은 이미지들 (폴라로이드 스타일)
        MagazineFrame(x: 0.02, y: 0.05, width: 0.22, height: 0.28, rotation: -0.08, zIndex: 1),
        MagazineFrame(x: 0.7, y: 0.08, width: 0.26, height: 0.32, rotation: 0.06, zIndex: 1),
        MagazineFrame(x: 0.05, y: 0.38, width: 0.2, height: 0.25, rotation: 0.05),
        MagazineFrame(x: 0.68, y: 0.45, width: 0.28, height: 0.35, rotation: -0.04),
        // 하단 이미지들
        MagazineFrame(x: 0.08, y: 0.7, width: 0.22, height: 0.27, rotation: 0.03),
        MagazineFrame(x: 0.32, y: 0.72, width: 0.2, height: 0.25, rotation: -0.05),
        MagazineFrame(x: 0.54, y: 0.68, width: 0.24, height: 0.3, rotation: 0.04),
        MagazineFrame(x: 0.78, y: 0.75, width: 0.18, height: 0.22, rotation: -0.06),
      ],
    );
  }

  // 10장 - Gallery Showcase
  static MagazineLayout galleryShowcase10() {
    return const MagazineLayout(
      id: 'gallery_10',
      name: 'Gallery Showcase',
      description: 'Professional portfolio presentation',
      icon: Icons.museum,
      photoCount: 10,
      frames: [
        // 큰 메인 이미지
        MagazineFrame(x: 0.0, y: 0.0, width: 0.55, height: 0.5),
        // 오른쪽 작은 이미지들
        MagazineFrame(x: 0.58, y: 0.0, width: 0.42, height: 0.24),
        MagazineFrame(x: 0.58, y: 0.26, width: 0.42, height: 0.24),
        // 중간 섹션
        MagazineFrame(x: 0.0, y: 0.53, width: 0.32, height: 0.22),
        MagazineFrame(x: 0.34, y: 0.53, width: 0.32, height: 0.22),
        MagazineFrame(x: 0.68, y: 0.53, width: 0.32, height: 0.22),
        // 하단 섹션
        MagazineFrame(x: 0.0, y: 0.77, width: 0.24, height: 0.23),
        MagazineFrame(x: 0.26, y: 0.77, width: 0.24, height: 0.23),
        MagazineFrame(x: 0.52, y: 0.77, width: 0.24, height: 0.23),
        MagazineFrame(x: 0.78, y: 0.77, width: 0.22, height: 0.23),
      ],
    );
  }
}
