import 'package:flutter/material.dart';
import '../../models/collage_layout.dart';
import '../../widgets/collage_canvas.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final layout = args?['layout'] as CollageLayout?;
    final photos = args?['photos'] as List<String>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _navigateToExport(context, layout, photos),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: layout != null
              ? CollageCanvas(
                  layout: layout,
                  imagePaths: photos,
                  cornerRadius: 0.0,
                )
              : const Text('No layout selected'),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () => _navigateToExport(context, layout, photos),
          icon: const Icon(Icons.save_alt),
          label: const Text('Save & Share'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  void _navigateToExport(BuildContext context, CollageLayout? layout, List<String> photos) {
    Navigator.pushNamed(
      context,
      '/export',
      arguments: {
        'layout': layout,
        'photos': photos,
      },
    );
  }
}
