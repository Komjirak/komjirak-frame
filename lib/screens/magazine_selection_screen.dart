import 'package:flutter/material.dart';
import '../models/magazine_layout.dart';

class MagazineSelectionScreen extends StatelessWidget {
  const MagazineSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF221019),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildLayoutGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF221019).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Magazine Layouts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Choose your editorial style',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutGrid(BuildContext context) {
    final layouts = MagazineLayouts.getAllLayouts();
    
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,  // Slightly taller to reduce overflow
      ),
      itemCount: layouts.length,
      itemBuilder: (context, index) {
        return _buildLayoutCard(context, layouts[index]);
      },
    );
  }

  Widget _buildLayoutCard(BuildContext context, MagazineLayout layout) {
    return GestureDetector(
      onTap: () {
        // Custom Canvas goes to a different screen
        if (layout.id == 'custom_canvas') {
          Navigator.pushNamed(context, '/custom-canvas');
        } else {
          Navigator.pushNamed(
            context,
            '/magazine-photo-fill',
            arguments: {'layout': layout},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview - 실제 결과물 형태로 표시
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFFAFAFA), // 매거진 배경색
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _MagazinePreviewWidget(layout: layout),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        layout.icon,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          layout.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    layout.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${layout.photoCount} photos',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 실제 매거진 결과물 형태의 프리뷰 위젯
class _MagazinePreviewWidget extends StatelessWidget {
  final MagazineLayout layout;

  const _MagazinePreviewWidget({required this.layout});

  // 샘플 이미지용 그라데이션 색상 팔레트
  static final List<List<Color>> _sampleGradients = [
    [const Color(0xFF667EEA), const Color(0xFF764BA2)], // 보라-파랑
    [const Color(0xFFF093FB), const Color(0xFFF5576C)], // 핑크-빨강
    [const Color(0xFF4FACFE), const Color(0xFF00F2FE)], // 하늘색
    [const Color(0xFF43E97B), const Color(0xFF38F9D7)], // 민트-그린
    [const Color(0xFFFA709A), const Color(0xFFFEE140)], // 핑크-노랑
    [const Color(0xFF30CFD0), const Color(0xFF330867)], // 청록-보라
    [const Color(0xFFA8EDEA), const Color(0xFFFED6E3)], // 파스텔
    [const Color(0xFFD299C2), const Color(0xFFFEF9D7)], // 라벤더-크림
    [const Color(0xFF89F7FE), const Color(0xFF66A6FF)], // 하늘-파랑
    [const Color(0xFFFAD961), const Color(0xFFF76B1C)], // 노랑-오렌지
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const magazineFrameSpacing = 4.0;
        final availableWidth = constraints.maxWidth - (magazineFrameSpacing * 2);
        final availableHeight = constraints.maxHeight - (magazineFrameSpacing * 2);

        // zIndex 순서대로 정렬
        final sortedFrames = layout.frames.asMap().entries.toList()
          ..sort((a, b) => a.value.zIndex.compareTo(b.value.zIndex));

        return Container(
          color: const Color(0xFFFAFAFA), // 매거진 배경색
          child: Stack(
            children: sortedFrames.map((entry) {
              final index = entry.key;
              final frame = entry.value;
              
              // 샘플 그라데이션 선택 (프레임 인덱스 기반)
              final gradientColors = _sampleGradients[index % _sampleGradients.length];

              return Positioned(
                left: magazineFrameSpacing + (frame.x * availableWidth),
                top: magazineFrameSpacing + (frame.y * availableHeight),
                width: frame.width * availableWidth,
                height: frame.height * availableHeight,
                child: Transform.rotate(
                  angle: frame.rotation,
                  child: Container(
                    margin: const EdgeInsets.all(1.5), // 프레임 간 간격
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0), // 매거진 스타일 - 날카로운 모서리
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradientColors,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // 그라데이션 배경 (실제 사진처럼 보이도록)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    gradientColors[0],
                                    gradientColors[1],
                                  ],
                                ),
                              ),
                            ),
                            // 사진 느낌의 오버레이 (그림자 효과)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                            // 사진 아이콘 (작은 프레임에는 표시 안 함)
                            if (frame.width * availableWidth > 25 && frame.height * availableHeight > 25)
                              Center(
                                child: Icon(
                                  Icons.photo,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  size: (frame.width * availableWidth * frame.height * availableHeight) / 250,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
