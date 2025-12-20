import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoSelectionScreen extends StatefulWidget {
  const PhotoSelectionScreen({super.key});

  @override
  State<PhotoSelectionScreen> createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends State<PhotoSelectionScreen> {
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  static const int _maxPhotos = 10;

  Future<void> _pickImages() async {
    if (_selectedPhotos.length >= _maxPhotos) {
      _showMaxPhotosReachedDialog();
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          int remainingSlots = _maxPhotos - _selectedPhotos.length;
          _selectedPhotos.addAll(images.take(remainingSlots));
        });

        if (images.length > remainingSlots) {
          _showMaxPhotosReachedDialog();
        }
      }
    } catch (e) {
      _showErrorDialog('Error picking images: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (_selectedPhotos.length >= _maxPhotos) {
      _showMaxPhotosReachedDialog();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        setState(() {
          _selectedPhotos.add(image);
        });
      }
    } catch (e) {
      _showErrorDialog('Error taking photo: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _showMaxPhotosReachedDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Maximum $_maxPhotos photos allowed'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _createCollage() {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one photo'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/collage-edit',
      arguments: _selectedPhotos,
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _selectedPhotos.length / _maxPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Photos'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Progress Bar Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Photos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${_selectedPhotos.length}/$_maxPhotos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _selectedPhotos.length >= _maxPhotos
                                ? Colors.orange
                                : Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _selectedPhotos.length >= _maxPhotos
                        ? Colors.orange
                        : Theme.of(context).primaryColor,
                  ),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Grid Display of Selected Photos
          Expanded(
            child: _selectedPhotos.isEmpty
                ? Center(
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
                          'No photos selected',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add photos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _selectedPhotos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _removePhoto(index),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Photo
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedPhotos[index].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Numbered Badge
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            // Remove Indicator (X icon on tap)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Add Photos FAB
          if (_selectedPhotos.length < _maxPhotos)
            FloatingActionButton(
              onPressed: _showImageSourceDialog,
              heroTag: 'add_photos',
              child: const Icon(Icons.add_photo_alternate),
            ),
          const SizedBox(height: 16),
          // Create Collage FAB
          FloatingActionButton.extended(
            onPressed: _createCollage,
            heroTag: 'create_collage',
            icon: const Icon(Icons.collections),
            label: const Text('Create Collage'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
