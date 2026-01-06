import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/frame_template.dart';
import '../models/collage_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF221019),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Main Create Button
                      SizedBox(
                        height: 520,
                        child: Center(
                          child: _buildMainCreateButton(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Template Selector
                      _buildTemplateSelector(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Collage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Z',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF221019),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.tune,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCreateButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Directly open image picker
        final ImagePicker picker = ImagePicker();
        try {
          final List<XFile> images = await picker.pickMultiImage();
          
          if (images.isNotEmpty) {
            // Navigate to preview/confirmation screen
            Navigator.pushNamed(
              context,
              '/photo-selection',
              arguments: {'selectedPhotos': images},
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error selecting images: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 520,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image with overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAUOa4XGfv5PAdTqVxEodD9b1wn_Gxc3cgMvZuQwwPGX9Il5aDdiTCB9kfdaOtUVZQ0wzZpxCTQhPZ6F_A2BytMLVsyEY3jA3jfzAMmEFypYocluIyY_whp5GHsC7ao0Z1wymf2cYR8cdGIARCX0eUuIrv4LQRXjJJBMT8uFJryegeZbjEik9JI9eDdmnW6Q--OsmGrSU1NncgPds9Mt6xZ3pKNxtKfl5SZyyk4xV8bQHxLHRau5NkK3ehKwqBUTrAoupgRrcoVBWUa',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.6),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[900]);
                      },
                    ),
                  ),
                  // Gradient overlays
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        backgroundBlendMode: BlendMode.overlay,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with glow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'New\nCollage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.9,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'TAP TO START CREATING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 2,
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

  Widget _buildTemplateSelector(BuildContext context) {
    final templates = FrameTemplates.getAllTemplates();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'SELECT LAYOUT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: 16,
                  left: index == 0 ? 0 : 0,
                ),
                child: _buildTemplateItem(context, template),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateItem(BuildContext context, CollageLayout template) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/photo-selection',
          arguments: {'preselectedLayout': template},
        );
      },
      child: SizedBox(
        width: 80,
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF221019),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: CustomPaint(
                  painter: _LayoutPreviewPainter(
                    cells: template.cells.take(4).toList(),
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                template.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for layout preview
class _LayoutPreviewPainter extends CustomPainter {
  final List<FrameCell> cells;
  final Color color;

  _LayoutPreviewPainter({required this.cells, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final cell in cells) {
      final left = (cell.column / 3) * size.width;
      final top = (cell.row / 3) * size.height;
      final width = (cell.columnSpan / 3) * size.width;
      final height = (cell.rowSpan / 3) * size.height;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left + 2,
          top + 2,
          width - 4,
          height - 4,
        ),
        const Radius.circular(6),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_LayoutPreviewPainter oldDelegate) {
    return oldDelegate.cells != cells || oldDelegate.color != color;
  }
}
