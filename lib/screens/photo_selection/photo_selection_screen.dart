import 'package:flutter/material.dart';
import '../../widgets/photo_grid_item.dart';

class PhotoSelectionScreen extends StatefulWidget {
  const PhotoSelectionScreen({super.key});

  @override
  State<PhotoSelectionScreen> createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends State<PhotoSelectionScreen> {
  final List<String> _selectedPhotos = [];
  final List<String> _allPhotos = []; // This would be loaded from gallery

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Photos'),
        actions: [
          TextButton(
            onPressed: _selectedPhotos.isEmpty ? null : _continueToFrameSelection,
            child: Text(
              'Next',
              style: TextStyle(
                color: _selectedPhotos.isEmpty ? Colors.grey : Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedPhotos.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedPhotos.length} photo(s) selected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _allPhotos.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _allPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = _allPhotos[index];
                      final isSelected = _selectedPhotos.contains(photo);
                      final selectionIndex = _selectedPhotos.indexOf(photo);

                      return PhotoGridItem(
                        imagePath: photo,
                        isSelected: isSelected,
                        selectionIndex: isSelected ? selectionIndex : null,
                        onTap: () => _togglePhotoSelection(photo),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No photos found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _togglePhotoSelection(String photo) {
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
      } else {
        _selectedPhotos.add(photo);
      }
    });
  }

  void _continueToFrameSelection() {
    Navigator.pushNamed(
      context,
      '/collage-edit',
      arguments: {'photos': _selectedPhotos},
    );
  }
}
