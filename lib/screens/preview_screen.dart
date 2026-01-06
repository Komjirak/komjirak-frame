import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/collage_canvas.dart';
import '../models/collage_layout.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late String _collageText;
  late String _fontFamily;
  bool _showWatermark = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _collageText = args?['text'] as String? ?? '';
    _fontFamily = args?['font'] as String? ?? 'Roboto';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final photos = args?['photos'] as List<XFile>? ?? [];
    final imagePaths = args?['imagePaths'] as List<String>? ?? photos.map((p) => p.path).toList();
    final layout = args?['layout'] as CollageLayout?;
    final frameColor = args?['frameColor'] as Color? ?? Colors.white;
    final textColor = args?['textColor'] as Color? ?? Colors.white;
    final frameSpacing = args?['frameSpacing'] as double? ?? 2.0;
    final cornerRadius = args?['cornerRadius'] as double? ?? 0.0;
    final aspectRatio = args?['aspectRatio'] as double? ?? 1.0;
    final textPosition = args?['textPosition'] as Offset?;
    
    if (layout == null) {
      return const Scaffold(
        body: Center(child: Text('No layout selected')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF221019),
      body: Stack(
        children: [
          // Background gradient orb
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: _buildMainContent(
                  context,
                  layout,
                  imagePaths,
                  frameColor,
                  textColor,
                  frameSpacing,
                  cornerRadius,
                  aspectRatio,
                  textPosition,
                ),
              ),
              _buildBottomSheet(context, photos, imagePaths, layout, frameColor, textColor, frameSpacing, cornerRadius, aspectRatio, textPosition),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF221019).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const Text(
                'It\'s a Masterpiece ✨',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    CollageLayout layout,
    List<String> imagePaths,
    Color frameColor,
    Color textColor,
    double frameSpacing,
    double cornerRadius,
    double aspectRatio,
    Offset? textPosition,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Collage preview card
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 50,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      CollageCanvas(
                        layout: layout,
                        imagePaths: imagePaths,
                        frameColor: frameColor,
                        overlayText: _collageText.isEmpty ? null : _collageText,
                        fontFamily: _fontFamily,
                        textColor: textColor,
                        frameSpacing: frameSpacing,
                        cornerRadius: cornerRadius,
                        aspectRatio: aspectRatio,
                        textPosition: textPosition,
                      ),
                      if (_showWatermark)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Text(
                              '✨ COLLAGE APP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Watermark toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.branding_watermark,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'App Watermark',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showWatermark = !_showWatermark;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _showWatermark 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Align(
                        alignment: _showWatermark ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    List<XFile> photos,
    List<String> imagePaths,
    CollageLayout layout,
    Color frameColor,
    Color textColor,
    double frameSpacing,
    double cornerRadius,
    double aspectRatio,
    Offset? textPosition,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF221019),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Save to Gallery button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/export',
                        arguments: {
                          'photos': photos,
                          'imagePaths': imagePaths,
                          'layout': layout,
                          'frameColor': frameColor,
                          'textColor': textColor,
                          'frameSpacing': frameSpacing,
                          'cornerRadius': cornerRadius,
                          'aspectRatio': aspectRatio,
                          'textPosition': textPosition,
                          'text': _collageText,
                          'font': _fontFamily,
                        },
                      );
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Save to Gallery',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Share to label
                  Text(
                    'SHARE TO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Social share buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSocialButton(
                        'Story',
                        Icons.add_a_photo,
                        const Color(0xFFE1306C),
                        isGradient: true,
                      ),
                      _buildSocialButton(
                        'TikTok',
                        Icons.music_note,
                        Colors.black,
                      ),
                      _buildSocialButton(
                        'Snap',
                        Icons.notifications,
                        const Color(0xFFFFFC00),
                        iconColor: Colors.black,
                      ),
                      _buildSocialButton(
                        'Copy',
                        Icons.link,
                        Colors.grey.shade800,
                      ),
                      _buildSocialButton(
                        'More',
                        Icons.more_horiz,
                        Colors.transparent,
                        hasBorder: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Start new collage link
                  TextButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: Text(
                      'Start New Collage',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String label,
    IconData icon,
    Color color, {
    bool isGradient = false,
    Color? iconColor,
    bool hasBorder = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sharing to $label...')),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isGradient
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFCAF45),
                        Color(0xFFE1306C),
                        Color(0xFFC13584),
                      ],
                    )
                  : null,
              color: isGradient ? null : color,
              border: hasBorder
                  ? Border.all(
                      color: Colors.grey.shade700,
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: isGradient
                ? Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF221019),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? const Color(0xFFE1306C),
                      size: 24,
                    ),
                  )
                : Icon(
                    icon,
                    color: iconColor ?? Colors.white,
                    size: 24,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
