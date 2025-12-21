import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import '../services/image_service.dart';

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

  @override
  Widget build(BuildContext context) {
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
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: widget.collagePreview ??
              (widget.collageImagePath != null
                  ? Image.network(
                      widget.collageImagePath!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    )),
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
    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.collageImagePath == null && widget.collagePreview == null) {
        throw Exception('No collage image to save');
      }

      File? imageFile;
      if (widget.collageImagePath != null) {
        imageFile = File(widget.collageImagePath!);
      } else {
        // If we have a widget preview, we need to capture it
        // This would typically be done in the preview/edit screen
        throw Exception('Please generate the collage first');
      }

      // Request permissions
      final hasPermission = await StorageService.requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Apply quality settings if needed
      File? processedImage = imageFile;
      int quality = _selectedQuality == ExportQuality.high
          ? 100
          : _selectedQuality == ExportQuality.medium
              ? 85
              : 70;

      if (quality < 100) {
        processedImage = await ImageService.compressImage(imageFile, quality: quality);
        processedImage ??= imageFile;
      }

      // Save to gallery
      final success = await StorageService.saveToGallery(processedImage);

      if (!mounted) return;

      if (success) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });

        _showSuccessSnackBar('Collage saved to gallery successfully!');

        // Reset the saved state after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isSaved = false;
            });
          }
        });
      } else {
        throw Exception('Failed to save to gallery');
      }
    } catch (e) {
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
