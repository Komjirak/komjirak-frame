import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/collage_layout.dart';
import '../../models/frame_template.dart';
import '../../widgets/frame_selector.dart';
import '../../widgets/web_image.dart';

class CollageEditScreen extends StatefulWidget {
  const CollageEditScreen({super.key});

  @override
  State<CollageEditScreen> createState() => _CollageEditScreenState();
}

class _CollageEditScreenState extends State<CollageEditScreen> {
  List<XFile> _photos = [];
  CollageLayout? _selectedLayout;
  final List<CollageLayout> _layouts = FrameTemplates.getAllTemplates();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<XFile>) {
      _photos = args;
    } else if (args is List) {
      // Handle generic list
      try {
        _photos = args.cast<XFile>();
      } catch (e) {
        debugPrint('Error casting photos: $e');
      }
    }
    _selectedLayout ??= _layouts.isNotEmpty ? _layouts.first : null;
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
              child: _selectedLayout != null && _photos.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            return WebCompatibleImage(
                              imageFile: _photos[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No photos selected',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
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
