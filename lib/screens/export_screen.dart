import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

enum ExportQuality {
  high,
  medium,
  low,
}

class ExportScreen extends StatefulWidget {
  final String? collageImagePath;
  final Widget? collagePreview;

  const ExportScreen({
    Key? key,
    this.collageImagePath,
    this.collagePreview,
  }) : super(key: key);

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
            color: Colors.black.withOpacity(0.3),
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
                  ? Image.file(
                      File(widget.collageImagePath!),
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
        groupValue: _selectedQuality,
        onChanged: (ExportQuality? value) {
          if (value != null) {
            setState(() {
              _selectedQuality = value;
            });
          }
        },
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
                  color: (color ?? Colors.black).withOpacity(0.3),
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
      // Simulate save operation
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual save to gallery logic
      // This would typically involve:
      // 1. Rendering the collage at the selected quality
      // 2. Adding watermark if enabled
      // 3. Saving to device gallery using packages like:
      //    - image_gallery_saver
      //    - gallery_saver
      //    - or using platform channels

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showErrorSnackBar('Failed to save collage: $e');
    }
  }

  void _shareToSocial(String platform) {
    // TODO: Implement sharing logic for each platform
    // This would typically involve:
    // 1. Exporting the collage at appropriate quality
    // 2. Using share_plus package or platform-specific sharing
    // 3. For Instagram/TikTok: Deep linking to the app
    // 4. For Messages: Using native share sheet

    _showInfoSnackBar('Sharing to $platform...');

    // Simulate share operation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      // Example implementation placeholder
      debugPrint('Sharing to $platform with quality: $_selectedQuality');
      debugPrint('Allow remixing: $_allowRemixing');
      debugPrint('Add watermark: $_addWatermark');
    });
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
