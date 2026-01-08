import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import '../services/image_service.dart';
import '../widgets/collage_canvas.dart';
import '../models/collage_layout.dart';

enum ExportQuality {
  high,
  medium,
  low,
}

class ExportScreen extends StatefulWidget {
  final String? collageImagePath;
  final Widget? collagePreview;

  const ExportScreen({
    super.key,
    this.collageImagePath,
    this.collagePreview,
  });

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ExportQuality _selectedQuality = ExportQuality.high;
  bool _allowRemixing = true;
  bool _addWatermark = false;
  bool _isSaving = false;
  bool _isSaved = false;
  final GlobalKey _repaintKey = GlobalKey();

  // Collage parameters
  List<String> _imagePaths = [];
  CollageLayout? _layout;
  Color _frameColor = Colors.white;
  Color _textColor = Colors.white;
  double _frameSpacing = 2.0;
  double _cornerRadius = 0.0;
  double _aspectRatio = 1.0;
  Offset? _textPosition;
  String _collageText = '';
  String _fontFamily = 'Roboto';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Extract arguments once
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _imagePaths = args['imagePaths'] as List<String>? ?? [];
      _layout = args['layout'] as CollageLayout?;
      _frameColor = args['frameColor'] as Color? ?? Colors.white;
      _textColor = args['textColor'] as Color? ?? Colors.white;
      _frameSpacing = args['frameSpacing'] as double? ?? 2.0;
      _cornerRadius = args['cornerRadius'] as double? ?? 0.0;
      _aspectRatio = args['aspectRatio'] as double? ?? 1.0;
      _textPosition = args['textPosition'] as Offset?;
      _collageText = args['text'] as String? ?? '';
      _fontFamily = args['font'] as String? ?? 'Roboto';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_layout == null) {
      return const Scaffold(
        body: Center(child: Text('No layout data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Collage'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Collage Preview
            _buildCollagePreview(),

            const SizedBox(height: 24),

            // Quality Options Section
            _buildQualitySection(),

            const SizedBox(height: 24),

            // Social Sharing Section
            _buildSharingSection(),

            const SizedBox(height: 24),

            // Advanced Options Section
            _buildAdvancedOptions(),

            const SizedBox(height: 24),

            // Save to Gallery Button
            _buildSaveButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCollagePreview() {
    if (_layout == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        height: 300,
        color: Colors.grey[800],
        child: const Center(child: Text('No layout')),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: RepaintBoundary(
        key: _repaintKey,
        child: CollageCanvas(
          layout: _layout!,
          imagePaths: _imagePaths,
          frameColor: _frameColor,
          overlayText: _collageText.isEmpty ? null : _collageText,
          fontFamily: _fontFamily,
          textColor: _textColor,
          frameSpacing: _frameSpacing,
          cornerRadius: _cornerRadius,
          aspectRatio: _aspectRatio,
          textPosition: _textPosition,
        ),
      ),
    );
  }

  Widget _buildQualitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Quality',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildQualityOption(
                  quality: ExportQuality.high,
                  title: 'High Quality',
                  subtitle: 'Best for printing (4K)',
                  icon: Icons.high_quality,
                ),
                const Divider(height: 1, indent: 56),
                _buildQualityOption(
                  quality: ExportQuality.medium,
                  title: 'Medium Quality',
                  subtitle: 'Balanced size and quality (1080p)',
                  icon: Icons.hd,
                ),
                const Divider(height: 1, indent: 56),
                _buildQualityOption(
                  quality: ExportQuality.low,
                  title: 'Low Quality',
                  subtitle: 'Smaller file size (720p)',
                  icon: Icons.sd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityOption({
    required ExportQuality quality,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedQuality == quality;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[400],
        ),
      ),
      trailing: Radio<ExportQuality>(
        value: quality,
        toggleable: true,
      ),
      onTap: () {
        setState(() {
          _selectedQuality = quality;
        });
      },
    );
  }

  Widget _buildSharingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share To',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                gradient: const LinearGradient(
                  colors: [Color(0xFF405DE6), Color(0xFF5B51D8), Color(0xFF833AB4), Color(0xFFC13584), Color(0xFFE1306C), Color(0xFFFD1D1D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _shareToSocial('Instagram'),
              ),
              _buildSocialButton(
                icon: Icons.music_note,
                label: 'TikTok',
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F2EA), Color(0xFFFF0050)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _shareToSocial('TikTok'),
              ),
              _buildSocialButton(
                icon: Icons.flash_on,
                label: 'Snapchat',
                color: const Color(0xFFFFFC00),
                onTap: () => _shareToSocial('Snapchat'),
              ),
              _buildSocialButton(
                icon: Icons.message,
                label: 'Messages',
                color: const Color(0xFF007AFF),
                onTap: () => _shareToSocial('Messages'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _shareToSocial('More'),
              icon: const Icon(Icons.share),
              label: const Text('More Options'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    Color? color,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: gradient,
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (color ?? Colors.black).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color == const Color(0xFFFFFC00) ? Colors.black : Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.loop),
                  title: const Text('Allow Remixing'),
                  subtitle: Text(
                    'Let others create their own versions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  value: _allowRemixing,
                  onChanged: (bool value) {
                    setState(() {
                      _allowRemixing = value;
                    });
                  },
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.branding_watermark),
                  title: const Text('Add Watermark'),
                  subtitle: Text(
                    'Include app branding on export',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  value: _addWatermark,
                  onChanged: (bool value) {
                    setState(() {
                      _addWatermark = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveToGallery,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _isSaved ? Colors.green : Theme.of(context).primaryColor,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isSaved ? Icons.check_circle : Icons.save_alt),
                  const SizedBox(width: 8),
                  Text(
                    _isSaved ? 'Saved to Gallery!' : 'Save to Gallery',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveToGallery() async {
    print('[SaveToGallery] Starting save process...');
    setState(() {
      _isSaving = true;
    });

    try {
      // Check if RepaintBoundary is ready
      if (_repaintKey.currentContext == null) {
        throw Exception('RepaintBoundary context is null. Widget not rendered yet.');
      }
      
      print('[SaveToGallery] Finding RenderRepaintBoundary...');
      final renderObject = _repaintKey.currentContext!.findRenderObject();
      if (renderObject == null) {
        throw Exception('RenderObject is null');
      }
      
      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('RenderObject is not a RenderRepaintBoundary');
      }
      
      final RenderRepaintBoundary boundary = renderObject;
      
      print('[SaveToGallery] Capturing widget as image...');
      // Capture at high resolution
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      print('[SaveToGallery] Image captured: ${image.width}x${image.height}');
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }
      
      print('[SaveToGallery] Image converted to bytes: ${byteData.lengthInBytes} bytes');

      // Convert to File
      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/collage_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(buffer);
      print('[SaveToGallery] Temp file created: ${tempFile.path}');

      // Request permissions
      debugPrint('[SaveToGallery] Requesting storage permissions...');
      final permissionResult = await StorageService.requestPermissions();
      
      if (permissionResult.isFailure) {
        final error = permissionResult.errorOrNull;
        throw Exception(error?.displayMessage ?? 'Storage permission denied. Please grant permission in Settings.');
      }

      // Apply quality settings if needed
      File processedImage = tempFile;
      int quality = _selectedQuality == ExportQuality.high
          ? 100
          : _selectedQuality == ExportQuality.medium
              ? 85
              : 70;

      debugPrint('[SaveToGallery] Selected quality: $quality');

      if (quality < 100) {
        debugPrint('[SaveToGallery] Compressing image...');
        final compressResult = await ImageService.compressImage(tempFile, quality: quality);
        compressResult.fold(
          (error) {
            debugPrint('[SaveToGallery] Compression failed: ${error.message}');
            // 압축 실패해도 원본 파일 사용
          },
          (compressed) {
            processedImage = compressed;
            debugPrint('[SaveToGallery] Compression complete');
          },
        );
      }

      // Save to gallery
      debugPrint('[SaveToGallery] Saving to gallery...');
      final saveResult = await StorageService.saveToGallery(processedImage);

      if (!mounted) return;

      saveResult.fold(
        (error) {
          debugPrint('[SaveToGallery] Save failed: ${error.displayMessage}');
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            _showErrorSnackBar('저장 실패: ${error.displayMessage}');
          }
        },
        (success) {
          if (success) {
            if (mounted) {
              setState(() {
                _isSaving = false;
                _isSaved = true;
              });

              final message = Platform.isMacOS
                  ? 'Collage saved to Downloads folder successfully!'
                  : 'Collage saved to gallery successfully!';
              _showSuccessSnackBar(message);
              debugPrint('[SaveToGallery] ✅ Save completed successfully!');

              // Reset the saved state after 3 seconds
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _isSaved = false;
                  });
                }
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _isSaving = false;
              });
              _showErrorSnackBar('저장에 실패했습니다.');
            }
          }
        },
      );
    } catch (e, stackTrace) {
      print('[SaveToGallery] ❌ Error: $e');
      print('[SaveToGallery] Stack trace: $stackTrace');
      
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showErrorSnackBar('Failed to save collage: $e');
    }
  }

  Future<void> _shareToSocial(String platform) async {
    try {
      if (widget.collageImagePath == null && widget.collagePreview == null) {
        throw Exception('No collage image to share');
      }

      File? imageFile;
      if (widget.collageImagePath != null) {
        imageFile = File(widget.collageImagePath!);
      } else {
        throw Exception('Please generate the collage first');
      }

      _showInfoSnackBar('Preparing to share to $platform...');

      ShareResult? result;
      switch (platform) {
        case 'Instagram':
          result = await ShareService.shareToInstagramStory(imageFile);
          break;
        case 'TikTok':
          result = await ShareService.shareToTikTok(imageFile);
          break;
        case 'Snapchat':
          result = await ShareService.shareToSnapchat(imageFile);
          break;
        case 'Messages':
          result = await ShareService.shareToMessages(imageFile);
          break;
        default:
          result = await ShareService.shareImage(imageFile);
      }

      if (result != null && mounted) {
        if (result.status == ShareResultStatus.success) {
          _showSuccessSnackBar('Shared successfully!');
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to share: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
