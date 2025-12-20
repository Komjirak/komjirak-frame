import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/web_image.dart';

// Frame layout types matching CollageEditScreen
enum FrameLayout {
  classic,
  split,
  mosaic,
  film,
  polaroid,
  bubbles,
}

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final photos = args?['photos'] as List<XFile>? ?? [];
    final layoutName = args?['layout'];
    final frameColor = args?['frameColor'] as Color? ?? Colors.white;
    final font = args?['font'] as String? ?? 'Roboto';
    final text = args?['text'] as String? ?? '';
    
    // Convert layout name string to FrameLayout enum
    FrameLayout layout = FrameLayout.classic;
    if (layoutName != null) {
      final layoutStr = layoutName.toString().split('.').last;
      layout = FrameLayout.values.firstWhere(
        (e) => e.toString().split('.').last == layoutStr,
        orElse: () => FrameLayout.classic,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview Area
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _buildCollagePreview(photos, layout, frameColor),
                  ),
                ),
              ),
            ),
          ),

          // Quick Share Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share to Socials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      context,
                      'Instagram',
                      Icons.camera_alt,
                      Colors.purple,
                      () => _shareToInstagram(context),
                    ),
                    _buildSocialButton(
                      context,
                      'TikTok',
                      Icons.music_note,
                      Colors.black,
                      () => _shareToTikTok(context),
                    ),
                    _buildSocialButton(
                      context,
                      'Snapchat',
                      Icons.send,
                      Colors.yellow,
                      () => _shareToSnapchat(context),
                    ),
                    _buildSocialButton(
                      context,
                      'More',
                      Icons.more_horiz,
                      Colors.grey,
                      () => _shareMore(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareCollage(context),
                    icon: const Icon(Icons.ios_share),
                    label: const Text('SHARE'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/export',
                        arguments: {
                          'photos': photos,
                          'layout': layout,
                          'frameColor': frameColor,
                        },
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('SAVE TO GALLERY'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollagePreview(List<XFile> photos, FrameLayout layout, Color frameColor) {
    if (photos.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Text('No photos to preview'),
        ),
      );
    }

    switch (layout) {
      case FrameLayout.classic:
        return _buildClassicLayout(photos, frameColor);
      case FrameLayout.split:
        return _buildSplitLayout(photos, frameColor);
      case FrameLayout.mosaic:
        return _buildMosaicLayout(photos, frameColor);
      case FrameLayout.film:
        return _buildFilmLayout(photos, frameColor);
      case FrameLayout.polaroid:
        return _buildPolaroidLayout(photos, frameColor);
      case FrameLayout.bubbles:
        return _buildBubblesLayout(photos, frameColor);
      default:
        return _buildClassicLayout(photos, frameColor);
    }
  }

  Widget _buildClassicLayout(List<XFile> photos, Color frameColor) {
    return Container(
      color: frameColor,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: photos.length > 4 ? 4 : photos.length,
        itemBuilder: (context, index) {
          return _buildPhotoCell(photos, index);
        },
      ),
    );
  }

  Widget _buildSplitLayout(List<XFile> photos, Color frameColor) {
    return Container(
      color: frameColor,
      child: Row(
        children: [
          Expanded(
            child: photos.isNotEmpty
                ? _buildPhotoCell(photos, 0)
                : Container(color: Colors.grey[300]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: photos.length > 1
                      ? _buildPhotoCell(photos, 1)
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: photos.length > 2
                      ? _buildPhotoCell(photos, 2)
                      : Container(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosaicLayout(List<XFile> photos, Color frameColor) {
    return Container(
      color: frameColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: photos.isNotEmpty
                      ? _buildPhotoCell(photos, 0)
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: photos.length > 1
                      ? _buildPhotoCell(photos, 1)
                      : Container(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: photos.length > 2
                      ? _buildPhotoCell(photos, 2)
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: photos.length > 3
                      ? _buildPhotoCell(photos, 3)
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: photos.length > 4
                      ? _buildPhotoCell(photos, 4)
                      : Container(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmLayout(List<XFile> photos, Color frameColor) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Film strip holes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: frameColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Photos
          Expanded(
            child: Row(
              children: List.generate(
                photos.length > 3 ? 3 : photos.length,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildPhotoCell(photos, index),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Film strip holes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: frameColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidLayout(List<XFile> photos, Color frameColor) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: photos.length > 4 ? 4 : photos.length,
        itemBuilder: (context, index) {
          return Transform.rotate(
            angle: (index % 2 == 0) ? -0.05 : 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: frameColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildPhotoCell(photos, index),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBubblesLayout(List<XFile> photos, Color frameColor) {
    return Container(
      color: Colors.grey[100],
      child: Stack(
        children: [
          if (photos.isNotEmpty)
            Positioned(
              top: 20,
              left: 20,
              child: _buildCircularPhoto(photos, 0, frameColor, 120),
            ),
          if (photos.length > 1)
            Positioned(
              top: 40,
              right: 30,
              child: _buildCircularPhoto(photos, 1, frameColor, 100),
            ),
          if (photos.length > 2)
            Positioned(
              bottom: 80,
              left: 40,
              child: _buildCircularPhoto(photos, 2, frameColor, 90),
            ),
          if (photos.length > 3)
            Positioned(
              bottom: 40,
              right: 40,
              child: _buildCircularPhoto(photos, 3, frameColor, 110),
            ),
          if (photos.length > 4)
            Positioned(
              top: 150,
              left: 150,
              child: _buildCircularPhoto(photos, 4, frameColor, 80),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularPhoto(List<XFile> photos, int index, Color frameColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: frameColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: WebCompatibleImage(
          imageFile: photos[index],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPhotoCell(List<XFile> photos, int index) {
    if (index >= photos.length) {
      return Container(color: Colors.grey[800]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: WebCompatibleImage(
        imageFile: photos[index],
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color == Colors.yellow || color == Colors.grey
                  ? Colors.black
                  : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _shareToInstagram(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing to Instagram...')),
    );
  }

  void _shareToTikTok(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing to TikTok...')),
    );
  }

  void _shareToSnapchat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing to Snapchat...')),
    );
  }

  void _shareMore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening share menu...')),
    );
  }

  void _shareCollage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening share options...')),
    );
  }
}
