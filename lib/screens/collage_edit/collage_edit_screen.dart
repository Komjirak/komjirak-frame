import 'package:flutter/material.dart';
import '../../models/collage_layout.dart';
import '../../models/frame_template.dart';
import '../../widgets/frame_selector.dart';
import '../../widgets/collage_canvas.dart';

class CollageEditScreen extends StatefulWidget {
  const CollageEditScreen({Key? key}) : super(key: key);

  @override
  State<CollageEditScreen> createState() => _CollageEditScreenState();
}

class _CollageEditScreenState extends State<CollageEditScreen> {
  late List<String> _photos;
  CollageLayout? _selectedLayout;
  final List<CollageLayout> _layouts = FrameTemplates.getAllTemplates();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _photos = args?['photos'] ?? [];
    _selectedLayout ??= _layouts.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndPreview,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Frame',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FrameSelector(
            layouts: _layouts,
            selectedLayout: _selectedLayout,
            onLayoutSelected: (layout) {
              setState(() {
                _selectedLayout = layout;
              });
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _selectedLayout != null
                  ? CollageCanvas(
                      layout: _selectedLayout!,
                      imagePaths: _photos,
                      onImageTransformed: (index, position, scale) {
                        // Handle image transformation
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Add more photos
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Photos'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveAndPreview,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveAndPreview() {
    Navigator.pushNamed(
      context,
      '/preview',
      arguments: {
        'layout': _selectedLayout,
        'photos': _photos,
      },
    );
  }
}
