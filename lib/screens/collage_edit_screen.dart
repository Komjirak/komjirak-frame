import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CollageEditScreen extends StatefulWidget {
  final List<XFile> photos;

  const CollageEditScreen({
    Key? key,
    required this.photos,
  }) : super(key: key);

  @override
  State<CollageEditScreen> createState() => _CollageEditScreenState();
}

class _CollageEditScreenState extends State<CollageEditScreen> {
  // Frame layout types
  enum FrameLayout {
    classic,
    split,
    mosaic,
    film,
    polaroid,
    bubbles,
  }

  // Toggle between frame and font selector
  enum SelectorMode {
    frame,
    font,
  }

  FrameLayout _selectedLayout = FrameLayout.classic;
  SelectorMode _selectorMode = SelectorMode.frame;
  String _selectedFont = 'Roboto';
  Color _selectedFrameColor = Colors.white;
  String _collageText = '';

  final List<String> _availableFonts = [
    'Roboto',
    'Lato',
    'Open Sans',
    'Montserrat',
    'Raleway',
    'Pacifico',
  ];

  final List<Color> _availableFrameColors = [
    Colors.white,
    Colors.black,
    Colors.grey,
    Colors.brown,
    Colors.blue,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _navigateToPreview,
            tooltip: 'Preview',
          ),
        ],
      ),
      body: Column(
        children: [
          // Collage preview area
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildLayoutPreview(),
              ),
            ),
          ),

          // Selector toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectorMode = SelectorMode.frame;
                      });
                    },
                    icon: const Icon(Icons.border_all),
                    label: const Text('Frame'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectorMode == SelectorMode.frame
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      foregroundColor: _selectorMode == SelectorMode.frame
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectorMode = SelectorMode.font;
                      });
                    },
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Font'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectorMode == SelectorMode.font
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      foregroundColor: _selectorMode == SelectorMode.font
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selector content area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _selectorMode == SelectorMode.frame
                  ? _buildFrameSelector()
                  : _buildFontSelector(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _navigateToPreview,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text(
            'Continue to Preview',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutPreview() {
    switch (_selectedLayout) {
      case FrameLayout.classic:
        return _buildClassicLayout();
      case FrameLayout.split:
        return _buildSplitLayout();
      case FrameLayout.mosaic:
        return _buildMosaicLayout();
      case FrameLayout.film:
        return _buildFilmLayout();
      case FrameLayout.polaroid:
        return _buildPolaroidLayout();
      case FrameLayout.bubbles:
        return _buildBubblesLayout();
    }
  }

  Widget _buildClassicLayout() {
    return Container(
      color: _selectedFrameColor,
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: widget.photos.length > 4 ? 4 : widget.photos.length,
        itemBuilder: (context, index) {
          return _buildPhotoTile(widget.photos[index]);
        },
      ),
    );
  }

  Widget _buildSplitLayout() {
    return Container(
      color: _selectedFrameColor,
      child: Row(
        children: [
          Expanded(
            child: widget.photos.isNotEmpty
                ? _buildPhotoTile(widget.photos[0])
                : Container(color: Colors.grey[300]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: widget.photos.length > 1
                      ? _buildPhotoTile(widget.photos[1])
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: widget.photos.length > 2
                      ? _buildPhotoTile(widget.photos[2])
                      : Container(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosaicLayout() {
    return Container(
      color: _selectedFrameColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: widget.photos.isNotEmpty
                      ? _buildPhotoTile(widget.photos[0])
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: widget.photos.length > 1
                      ? _buildPhotoTile(widget.photos[1])
                      : Container(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: widget.photos.length > 2
                      ? _buildPhotoTile(widget.photos[2])
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: widget.photos.length > 3
                      ? _buildPhotoTile(widget.photos[3])
                      : Container(color: Colors.grey[300]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: widget.photos.length > 4
                      ? _buildPhotoTile(widget.photos[4])
                      : Container(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmLayout() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Film strip holes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _selectedFrameColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Photos
          Expanded(
            child: Row(
              children: widget.photos.take(3).map((photo) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildPhotoTile(photo),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Film strip holes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _selectedFrameColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidLayout() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: widget.photos.length > 4 ? 4 : widget.photos.length,
        itemBuilder: (context, index) {
          return Transform.rotate(
            angle: (index % 2 == 0) ? -0.05 : 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: _selectedFrameColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildPhotoTile(widget.photos[index]),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBubblesLayout() {
    return Container(
      color: Colors.grey[100],
      child: Stack(
        children: [
          if (widget.photos.isNotEmpty)
            Positioned(
              top: 20,
              left: 20,
              child: _buildCircularPhoto(widget.photos[0], 120),
            ),
          if (widget.photos.length > 1)
            Positioned(
              top: 40,
              right: 30,
              child: _buildCircularPhoto(widget.photos[1], 100),
            ),
          if (widget.photos.length > 2)
            Positioned(
              bottom: 80,
              left: 40,
              child: _buildCircularPhoto(widget.photos[2], 90),
            ),
          if (widget.photos.length > 3)
            Positioned(
              bottom: 40,
              right: 40,
              child: _buildCircularPhoto(widget.photos[3], 110),
            ),
          if (widget.photos.length > 4)
            Positioned(
              top: 150,
              left: 150,
              child: _buildCircularPhoto(widget.photos[4], 80),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularPhoto(XFile photo, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _selectedFrameColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.file(
          File(photo.path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPhotoTile(XFile photo) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(photo.path)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFrameSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Frame Layout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildFrameOption(FrameLayout.classic, Icons.grid_on, 'Classic'),
              _buildFrameOption(FrameLayout.split, Icons.view_column, 'Split'),
              _buildFrameOption(FrameLayout.mosaic, Icons.dashboard, 'Mosaic'),
              _buildFrameOption(FrameLayout.film, Icons.movie, 'Film'),
              _buildFrameOption(
                  FrameLayout.polaroid, Icons.photo_camera, 'Polaroid'),
              _buildFrameOption(FrameLayout.bubbles, Icons.bubble_chart, 'Bubbles'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Frame Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableFrameColors.length,
            itemBuilder: (context, index) {
              final color = _availableFrameColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFrameColor = color;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: _selectedFrameColor == color
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      width: _selectedFrameColor == color ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFrameOption(FrameLayout layout, IconData icon, String label) {
    final isSelected = _selectedLayout == layout;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayout = layout;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Font',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _availableFonts.length,
            itemBuilder: (context, index) {
              final font = _availableFonts[index];
              final isSelected = _selectedFont == font;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  title: Text(
                    font,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedFont = font;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Add Text to Collage',
            border: OutlineInputBorder(),
            hintText: 'Enter your text here...',
          ),
          onChanged: (value) {
            setState(() {
              _collageText = value;
            });
          },
        ),
      ],
    );
  }

  void _navigateToPreview() {
    // Navigate to preview screen with selected options
    // Note: You'll need to create the PreviewScreen separately
    Navigator.pushNamed(
      context,
      '/preview',
      arguments: {
        'photos': widget.photos,
        'layout': _selectedLayout,
        'frameColor': _selectedFrameColor,
        'font': _selectedFont,
        'text': _collageText,
      },
    );
  }
}
