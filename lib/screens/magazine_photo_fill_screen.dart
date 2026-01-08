import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/magazine_layout.dart';
import '../models/project_model.dart';

class MagazinePhotoFillScreen extends StatefulWidget {
  const MagazinePhotoFillScreen({super.key});

  @override
  State<MagazinePhotoFillScreen> createState() => _MagazinePhotoFillScreenState();
}

class _MagazinePhotoFillScreenState extends State<MagazinePhotoFillScreen> {
  final ImagePicker _picker = ImagePicker();
  MagazineLayout? _selectedLayout;
  Map<int, String> _framePhotos = {}; // frameIndex -> photoPath
  int? _selectedFrameIndex;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedLayout == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['layout'] != null) {
        setState(() {
          _selectedLayout = args['layout'] as MagazineLayout;
        });
      }
    }
  }

  Future<void> _pickPhoto(int frameIndex) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      
      if (image != null) {
        setState(() {
          _framePhotos[frameIndex] = image.path;
          _selectedFrameIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택 실패: $e')),
        );
      }
    }
  }

  Future<void> _pickMultiplePhotos() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      
      if (images.isNotEmpty && _selectedLayout != null) {
        setState(() {
          // Fill empty frames with selected photos
          int photoIndex = 0;
          for (int i = 0; i < _selectedLayout!.frames.length && photoIndex < images.length; i++) {
            if (!_framePhotos.containsKey(i)) {
              _framePhotos[i] = images[photoIndex].path;
              photoIndex++;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택 실패: $e')),
        );
      }
    }
  }

  void _removePhoto(int frameIndex) {
    setState(() {
      _framePhotos.remove(frameIndex);
    });
  }

  bool get _canProceed {
    if (_selectedLayout == null) return false;
    return _framePhotos.length == _selectedLayout!.frames.length;
  }

  void _proceedToEdit() {
    if (!_canProceed || _selectedLayout == null) return;

    // Create a Project with magazine layout info
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Magazine ${_selectedLayout!.name}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      photoPaths: _framePhotos.values.toList(),
      isMagazineLayout: true,
      magazineLayoutId: _selectedLayout!.id,
    );

    Navigator.pushReplacementNamed(
      context,
      '/collage-edit',
      arguments: {
        'project': project,
        'magazineLayout': _selectedLayout,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedLayout == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final emptyFramesCount = _selectedLayout!.frames.length - _framePhotos.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedLayout!.name,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _canProceed ? _proceedToEdit : null,
            child: Text(
              '완료',
              style: TextStyle(
                color: _canProceed ? Colors.white : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Layout preview
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 60,
                    spreadRadius: 0,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const magazineFrameSpacing = 8.0;
                    final availableWidth = constraints.maxWidth - (magazineFrameSpacing * 2);
                    final availableHeight = constraints.maxHeight - (magazineFrameSpacing * 2);
                    
                    return Stack(
                      children: [
                        // Clean white background
                        Container(color: const Color(0xFFFAFAFA)),
                        // Frames with padding
                        Padding(
                          padding: const EdgeInsets.all(magazineFrameSpacing),
                          child: Stack(
                            children: _selectedLayout!.frames.asMap().entries.map((entry) {
                              final index = entry.key;
                              final frame = entry.value;
                              final photoPath = _framePhotos[index];
                              final isSelected = _selectedFrameIndex == index;

                              return Positioned(
                                left: frame.x * availableWidth,
                                top: frame.y * availableHeight,
                                width: frame.width * availableWidth,
                                height: frame.height * availableHeight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFrameIndex = index;
                                    });
                                    _pickPhoto(index);
                                  },
                                  child: Transform.rotate(
                                    angle: frame.rotation * 3.14159 / 180,
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                                          width: isSelected ? 3 : 0,
                                        ),
                                        boxShadow: photoPath != null
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.08),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: photoPath != null
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                ClipRRect(
                                                  child: Image.file(
                                                    File(photoPath),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: GestureDetector(
                                                    onTap: () => _removePhoto(index),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.7),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                  strokeAlign: BorderSide.strokeAlignInside,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.add_photo_alternate_outlined,
                                                  color: Colors.grey.shade400,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // Instructions and actions
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (emptyFramesCount > 0) ...[
                  Text(
                    '남은 사진: $emptyFramesCount장',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '각 프레임을 탭하여 사진을 추가하세요',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickMultiplePhotos,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('여러 장 한번에 추가'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '모든 사진이 추가되었습니다!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '완료를 눌러 편집 화면으로 이동하세요',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
