import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/web_image.dart';
import '../models/collage_layout.dart';
import '../providers/photo_provider.dart';

class PhotoSelectionScreen extends StatefulWidget {
  const PhotoSelectionScreen({super.key});

  @override
  State<PhotoSelectionScreen> createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends State<PhotoSelectionScreen> {
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  static const int _maxPhotos = 12;
  CollageLayout? _preselectedLayout;
  bool _hasLoadedArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load arguments only once
    if (!_hasLoadedArguments) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _preselectedLayout = args?['preselectedLayout'] as CollageLayout?;
      
      // Load pre-selected photos if available
      final selectedPhotos = args?['selectedPhotos'] as List<XFile>?;
      if (selectedPhotos != null && selectedPhotos.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(selectedPhotos.take(_maxPhotos));
        });
      }
      
      _hasLoadedArguments = true;
    }
  }

  Future<void> _pickImages() async {
    if (_selectedPhotos.length >= _maxPhotos) {
      _showMaxPhotosReachedDialog();
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        final int remainingSlots = _maxPhotos - _selectedPhotos.length;
        setState(() {
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
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
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
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Provider에 선택된 사진 동기화
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    photoProvider.setPhotos(_selectedPhotos.map((x) => x.path).toList());

    Navigator.pushNamed(
      context,
      '/collage-edit',
      arguments: {
        'photos': _selectedPhotos,
        'preselectedLayout': _preselectedLayout,
      },
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
    return Scaffold(
      backgroundColor: const Color(0xFF221019),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildPhotoGrid(context),
              ),
            ],
          ),
          // Floating selection dock at bottom
          if (_selectedPhotos.isNotEmpty)
            _buildFloatingDock(context),
        ],
      ),
      floatingActionButton: _selectedPhotos.isNotEmpty && _selectedPhotos.length < _maxPhotos
          ? FloatingActionButton(
              onPressed: _showImageSourceDialog,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF221019).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Text(
                    'Select Photos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Album filter chips
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('Recents', true),
                  const SizedBox(width: 12),
                  _buildFilterChip('Favorites', false),
                  const SizedBox(width: 12),
                  _buildFilterChip('Instagram', false),
                  const SizedBox(width: 12),
                  _buildFilterChip('Snapchat', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).primaryColor 
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: isSelected 
            ? null 
            : Border.all(color: Colors.transparent),
        boxShadow: isSelected ? [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : Colors.grey[300],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    if (_selectedPhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'No photos selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap + button to add photos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text(
                'Add Photos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4).copyWith(bottom: 200),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _selectedPhotos.length,
      itemBuilder: (context, index) {
        return _buildPhotoItem(index);
      },
    );
  }

  Widget _buildPhotoItem(int index) {
    final photo = _selectedPhotos[index];
    final photoIndex = _selectedPhotos.indexOf(photo);
    final isSelected = photoIndex != -1;
    
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          _removePhoto(index);
        }
      },
      child: Stack(
        children: [
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.grey[900],
              child: WebCompatibleImage(
                imageFile: photo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Selection overlay
          if (isSelected) ...[
            // Border
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                ),
              ),
            ),
            // Tint
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Number badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${photoIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Unselected indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingDock(BuildContext context) {
    final selectedCount = _selectedPhotos.length;
    final remaining = _maxPhotos - selectedCount;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF221019).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thumbnail tray
                SizedBox(
                  height: 72,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _maxPhotos,
                    itemBuilder: (context, index) {
                      if (index < _selectedPhotos.length) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildThumbnail(index),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildEmptySlot(index + 1),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Bottom action row
                Row(
                  children: [
                    // Counter
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$selectedCount',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              Text(
                                '/$_maxPhotos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Selected',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$remaining REMAINING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Collage button
                    Expanded(
                      child: GestureDetector(
                        onTap: _createCollage,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                blurRadius: 25,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 24),
                                child: Text(
                                  'Collage It',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    return Stack(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: WebCompatibleImage(
              imageFile: _selectedPhotos[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlot(int number) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 24,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
