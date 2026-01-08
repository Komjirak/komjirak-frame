import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import '../models/project_model.dart';

class PhotoItem {
  String path;
  Offset position;
  double scale;
  double rotation;
  
  PhotoItem({
    required this.path,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class CustomCanvasScreen extends StatefulWidget {
  const CustomCanvasScreen({super.key});

  @override
  State<CustomCanvasScreen> createState() => _CustomCanvasScreenState();
}

class _CustomCanvasScreenState extends State<CustomCanvasScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<PhotoItem> _photos = [];
  int? _selectedPhotoIndex;
  Color _backgroundColor = Colors.white;
  
  final List<Color> _backgroundColors = [
    Colors.white,
    const Color(0xFFFAFAFA),
    const Color(0xFFF5F5F5),
    const Color(0xFFE8E8E8),
    Colors.black,
    const Color(0xFF1a1a1a),
    const Color(0xFFFFF8F0), // Cream
    const Color(0xFFFFF4E6), // Light peach
    const Color(0xFFE8F4F8), // Light blue
    const Color(0xFFF0F8E8), // Light green
    const Color(0xFFFFF0F5), // Light pink
    const Color(0xFFF5F0FF), // Light purple
  ];

  Future<void> _addPhotos() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            // Add photos in a cascading layout
            final offset = Offset(
              50.0 + (_photos.length * 30) % 200,
              50.0 + (_photos.length * 30) % 200,
            );
            _photos.add(PhotoItem(
              path: image.path,
              position: offset,
              scale: 0.3 + Random().nextDouble() * 0.2, // Random scale 0.3-0.5
              rotation: (Random().nextDouble() - 0.5) * 0.2, // Slight rotation
            ));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 추가 실패: $e')),
        );
      }
    }
  }

  void _removeSelectedPhoto() {
    if (_selectedPhotoIndex != null) {
      setState(() {
        _photos.removeAt(_selectedPhotoIndex!);
        _selectedPhotoIndex = null;
      });
    }
  }

  void _proceedToEdit() {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1장의 사진을 추가해주세요')),
      );
      return;
    }

    // Create a project with custom canvas data
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Custom Canvas',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      photoPaths: _photos.map((p) => p.path).toList(),
      isMagazineLayout: true,
      magazineLayoutId: 'custom_canvas',
    );

    Navigator.pushReplacementNamed(
      context,
      '/collage-edit',
      arguments: {
        'project': project,
        'customCanvas': true,
        'photoItems': _photos,
        'backgroundColor': _backgroundColor,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Custom Canvas',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          if (_photos.isNotEmpty)
            TextButton(
              onPressed: _proceedToEdit,
              child: const Text(
                '완료',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Canvas Area
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        // Photos
                        ..._photos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final photo = entry.value;
                          final isSelected = _selectedPhotoIndex == index;
                          
                          return Positioned(
                            left: photo.position.dx,
                            top: photo.position.dy,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPhotoIndex = isSelected ? null : index;
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _selectedPhotoIndex = index;
                                  photo.position += details.delta;
                                });
                              },
                              child: Transform.rotate(
                                angle: photo.rotation,
                                child: Transform.scale(
                                  scale: photo.scale,
                                  child: Container(
                                    width: 400,
                                    height: 400,
                                    decoration: BoxDecoration(
                                      border: isSelected
                                          ? Border.all(color: Colors.blue, width: 3)
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Image.file(
                                      File(photo.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        // Empty state
                        if (_photos.isEmpty)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 64,
                                  color: _backgroundColor == Colors.white
                                      ? Colors.grey.shade300
                                      : Colors.white.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '사진을 추가하여 자유롭게 배치하세요',
                                  style: TextStyle(
                                    color: _backgroundColor == Colors.white
                                        ? Colors.grey.shade500
                                        : Colors.white.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Background Color
                const Text(
                  'Background Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _backgroundColors.length,
                    itemBuilder: (context, index) {
                      final color = _backgroundColors[index];
                      final isSelected = _backgroundColor == color;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _backgroundColor = color;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.white.withValues(alpha: 0.2),
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Photo Controls
                if (_selectedPhotoIndex != null) ...[
                  Row(
                    children: [
                      const Text(
                        'Selected Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _removeSelectedPhoto,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Scale
                  Row(
                    children: [
                      const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
                      Expanded(
                        child: Slider(
                          value: _photos[_selectedPhotoIndex!].scale,
                          min: 0.1,
                          max: 1.0,
                          onChanged: (value) {
                            setState(() {
                              _photos[_selectedPhotoIndex!].scale = value;
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
                    ],
                  ),
                  // Rotation
                  Row(
                    children: [
                      const Icon(Icons.rotate_left, color: Colors.white70, size: 20),
                      Expanded(
                        child: Slider(
                          value: _photos[_selectedPhotoIndex!].rotation,
                          min: -pi,
                          max: pi,
                          onChanged: (value) {
                            setState(() {
                              _photos[_selectedPhotoIndex!].rotation = value;
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.rotate_right, color: Colors.white70, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // Add Photos Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _addPhotos,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(_photos.isEmpty ? '사진 추가' : '더 추가하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
}
