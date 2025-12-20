import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final photos = args?['photos'] as List<XFile>? ?? [];
    final layout = args?['layout'];
    final frameColor = args?['frameColor'] as Color? ?? Colors.white;
    final font = args?['font'] as String? ?? 'Roboto';
    final text = args?['text'] as String? ?? '';

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
                    child: _buildCollagePreview(photos, frameColor),
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

  Widget _buildCollagePreview(List<XFile> photos, Color frameColor) {
    if (photos.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Text('No photos to preview'),
        ),
      );
    }

    return Container(
      color: frameColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: _buildPhotoCell(photos, 0),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildPhotoCell(photos, 1)),
                const SizedBox(width: 8),
                Expanded(child: _buildPhotoCell(photos, 2)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildPhotoCell(photos, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCell(List<XFile> photos, int index) {
    if (index >= photos.length) {
      return Container(color: Colors.grey[800]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(photos[index].path),
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
