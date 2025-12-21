import 'package:flutter/material.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Share'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Export Quality',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQualityOption('High (4K)', '2048x2048', true),
            _buildQualityOption('Medium (HD)', '1920x1920', false),
            _buildQualityOption('Low (SD)', '1280x1280', false),
            const SizedBox(height: 32),
            const Text(
              'Share To',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildShareButton(
                    'Instagram',
                    Icons.camera_alt,
                    Colors.purple,
                    () => _shareToInstagram(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildShareButton(
                    'Snapchat',
                    Icons.chat,
                    Colors.yellow,
                    () => _shareToSnapchat(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildShareButton(
                    'Messages',
                    Icons.message,
                    Colors.green,
                    () => _shareToMessages(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildShareButton(
                    'More',
                    Icons.share,
                    Colors.blue,
                    () => _shareGeneric(),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveToGallery,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save to Gallery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String title, String subtitle, bool isSelected) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Radio<bool>(
        value: isSelected,
        toggleable: true,
      ),
    );
  }

  Widget _buildShareButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: color),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToGallery() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate saving
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to gallery successfully!')),
      );
    }
  }

  void _shareToInstagram() {
    // Implement Instagram sharing
  }

  void _shareToSnapchat() {
    // Implement Snapchat sharing
  }

  void _shareToMessages() {
    // Implement Messages sharing
  }

  void _shareGeneric() {
    // Implement generic sharing
  }
}
