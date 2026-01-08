import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/collage_layout.dart';
import '../models/frame_template.dart';
import '../models/magazine_layout.dart';
import '../models/project_model.dart';
import '../models/text_element.dart';
import '../widgets/collage_canvas.dart';
import '../providers/photo_provider.dart';
import '../services/storage_service.dart';

class CollageEditScreen extends StatefulWidget {
  final List<XFile>? photos;

  const CollageEditScreen({Key? key, this.photos}) : super(key: key);

  @override
  State<CollageEditScreen> createState() => _CollageEditScreenState();
}

class _CollageEditScreenState extends State<CollageEditScreen> {
  String _titlePosition = 'top'; // or 'bottom'
  final GlobalKey _repaintKey = GlobalKey();
  List<TextElement> _textElements = [];
  TextElement? _selectedTextElement;
  Color _textBackgroundColor = Colors.transparent;
  Color _textColor = Colors.white;
  double _frameSpacing = 8.0;
  double _cornerRadius = 12.0;
  double _aspectRatio = 0.8;
  Color _selectedFrameColor = Colors.white;
  final int _maxTextElements = 3;
  // State fields
  bool _isMagazineMode = false;
  CollageLayout? _selectedLayout;
  MagazineLayout? _magazineLayout;
  Project? _project;
  bool _hasLoadedArguments = false;
  bool _hasMagazinePresetApplied = false;
  bool _titleMode = false;
  String _collageText = '';
  String _selectedFont = 'Roboto';
  Color _selectedTextColor = Colors.white;
  double _textSize = 24.0;
  Offset _textPosition = const Offset(100, 100);
  bool _isDraggingText = false;
  Offset? _dragStartOffset;
  Offset? _textStartOffset;
  // Add any other fields as needed for your logic
  // (misplaced widget code removed)
  final List<String> _availableFonts = [
    'Roboto',              // 기본 산세리프
    'Noto Serif KR',       // 한글 명조체 (서제 느낌)
    'Black Han Sans',      // 한글 굵은체 (강렬한 느낌)
    'Nanum Pen Script',    // 한글 손글씨체
    'Do Hyeon',            // 한글 경쾌한 고딕체
    'Pacifico',            // 영문 스크립트 (감성적)
    'Bebas Neue',          // 영문 강인한 산세리프
    'Dancing Script',      // 영문 필기체
    'Monoton',             // 영문 레트로 라인
    'Righteous',           // 영문 둥근 고딕체
  ];

  final List<Color> _availableTextColors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    // Select first layout matching the photo count by default (only for regular collage mode)
    if (widget.photos != null) {
      final photoCount = widget.photos!.length;
      final matchingTemplates = FrameTemplates.getTemplatesForPhotoCount(photoCount);
      _selectedLayout = matchingTemplates.isNotEmpty 
          ? matchingTemplates.first 
          : FrameTemplates.getAllTemplates().first;
    } else {
      // Magazine mode - layout will be set in didChangeDependencies
      _selectedLayout = FrameTemplates.getAllTemplates().first;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load arguments only once
    if (!_hasLoadedArguments) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      // Check for magazine layout
      final magazineLayout = args?['magazineLayout'] as MagazineLayout?;
      final project = args?['project'] as Project?;
      
      if (magazineLayout != null && project != null) {
        setState(() {
          _magazineLayout = magazineLayout;
          _project = project;
          _isMagazineMode = true;
          // Apply magazine preset: title mode on, default text 'Magazine'
          if (!_hasMagazinePresetApplied) {
            _titleMode = true;
            _collageText = 'Magazine';
            _hasMagazinePresetApplied = true;
          }
        });
      } else {
        // Regular collage mode
        final preselectedLayout = args?['preselectedLayout'] as CollageLayout?;
        
        if (preselectedLayout != null) {
          setState(() {
            _selectedLayout = preselectedLayout;
          });
        }
      }
      
      _hasLoadedArguments = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        // Get image paths - from project for magazine mode, from photoProvider for regular mode
        final imagePaths = _isMagazineMode && _project != null
            ? _project!.photoPaths
            : photoProvider.selectedPhotos;

        return Scaffold(
          backgroundColor: const Color(0xFF221019),
          body: Column(
            children: [
              // Top App Bar
              _buildAppBar(context),
              // Main Canvas Area - Expand to fill available space
              Expanded(
                child: Center(
                  child: _buildCanvasArea(imagePaths),
                ),
              ),
              // Bottom Controls Section - Fixed height
              _buildControlsSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            // Title
            Text(
              _isMagazineMode ? 'Edit Magazine' : 'Edit Collage',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            // Save button
            GestureDetector(
              onTap: _showQualityDialogAndSave,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea(List<String> imagePaths) {
    // Magazine mode rendering
    if (_isMagazineMode && _magazineLayout != null && _project != null) {
      const magazineFrameSpacing = 8.0; // Minimal spacing for magazine style
      const magazineCornerRadius = 0.0; // Sharp corners for editorial look
      
      return Padding(
        padding: const EdgeInsets.all(24),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
              child: Column(
                children: [
                  // Top title if enabled
                  if (_titleMode && _titlePosition == 'top' && _collageText.isNotEmpty)
                    _buildMagazineTitle(),
                  // Magazine canvas
                  Expanded(
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              // Clean white background
                              Container(color: const Color(0xFFFAFAFA)),
                              // Magazine frames with padding
                              Padding(
                                padding: const EdgeInsets.all(magazineFrameSpacing),
                                child: Stack(
                                  children: _magazineLayout!.frames.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final frame = entry.value;
                                    final photoPath = index < _project!.photoPaths.length 
                                        ? _project!.photoPaths[index] 
                                        : null;

                                    // Calculate position with spacing
                                    final availableWidth = constraints.maxWidth - (magazineFrameSpacing * 2);
                                    final availableHeight = constraints.maxHeight - (magazineFrameSpacing * 2);

                                    return Positioned(
                                      left: frame.x * availableWidth,
                                      top: frame.y * availableHeight,
                                      width: frame.width * availableWidth,
                                      height: frame.height * availableHeight,
                                      child: Transform.rotate(
                                        angle: frame.rotation * 3.14159 / 180,
                                        child: Container(
                                          margin: const EdgeInsets.all(2), // Thin gap between photos
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(magazineCornerRadius),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: photoPath != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(magazineCornerRadius),
                                                  child: Image.file(
                                                    File(photoPath),
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(magazineCornerRadius),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              // Text overlays when title mode is OFF
                              if (!_titleMode) ...[
                                // Multiple text elements
                                ..._textElements.map((textElement) {
                                  return Positioned(
                                    left: textElement.position.dx.clamp(0.0, constraints.maxWidth - 200),
                                    top: textElement.position.dy.clamp(0.0, constraints.maxHeight - 100),
                                    child: GestureDetector(
                                      onTap: () => _selectTextElement(textElement),
                                      onPanUpdate: (details) {
                                        setState(() {
                                          final index = _textElements.indexWhere((e) => e.id == textElement.id);
                                          if (index != -1) {
                                            _textElements[index] = _textElements[index].copyWith(
                                              position: Offset(
                                                (textElement.position.dx + details.delta.dx).clamp(0, constraints.maxWidth - 200),
                                                (textElement.position.dy + details.delta.dy).clamp(0, constraints.maxHeight - 100),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: textElement.backgroundColor,
                                          borderRadius: BorderRadius.circular(8),
                                          border: textElement.isSelected
                                              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                                              : null,
                                        ),
                                        child: Text(
                                          textElement.text,
                                          style: GoogleFonts.getFont(
                                            textElement.fontFamily,
                                            fontSize: textElement.size,
                                            fontWeight: FontWeight.w700,
                                            color: textElement.textColor,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                // Legacy single text (if no text elements)
                                if (_textElements.isEmpty && _collageText.isNotEmpty)
                                  Positioned(
                                    left: _textPosition.dx.clamp(0.0, constraints.maxWidth - 200),
                                    top: _textPosition.dy.clamp(0.0, constraints.maxHeight - 100),
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        setState(() {
                                          _textPosition = Offset(
                                            (_textPosition.dx + details.delta.dx).clamp(0, constraints.maxWidth - 200),
                                            (_textPosition.dy + details.delta.dy).clamp(0, constraints.maxHeight - 100),
                                          );
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _textBackgroundColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _collageText,
                                          style: GoogleFonts.getFont(
                                            _selectedFont,
                                            fontSize: _textSize,
                                            fontWeight: FontWeight.w700,
                                            color: _textColor,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // Bottom title if enabled
                  if (_titleMode && _titlePosition == 'bottom' && _collageText.isNotEmpty)
                    _buildMagazineTitle(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Regular collage mode rendering
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2a1520),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 4,
            ),
          ),
          child: Column(
            children: [
              // Top title if enabled
              if (_titleMode && _titlePosition == 'top' && _collageText.isNotEmpty)
                _buildExternalTitle(),
              // Collage canvas
              Expanded(
                child: Stack(
                  children: [
                    // Collage Canvas - Fill entire area
                    RepaintBoundary(
                  key: _repaintKey,
                  child: CollageCanvas(
                    layout: _selectedLayout,
                    imagePaths: imagePaths,
                    frameColor: _selectedFrameColor,
                    overlayText: _titleMode ? null : (_collageText.isEmpty && _textElements.isEmpty ? null : _collageText),
                    textElements: _titleMode ? null : (_textElements.isEmpty ? null : _textElements),
                    fontFamily: _selectedFont,
                    textColor: _textColor,
                    textBackgroundColor: _textBackgroundColor,
                    textSize: _textSize,
                    frameSpacing: _frameSpacing,
                    cornerRadius: _cornerRadius,
                    aspectRatio: _aspectRatio,
                    textPosition: _textPosition,
                    editMode: true,  // Always enabled with auto-detection
                    onLayoutChanged: (updatedCells) {
                      // Layout changed callback
                      debugPrint('Layout updated with ${updatedCells.length} cells');
                    },
                    onImageTapped: (index) => _showPhotoOptions(context, index),
                    onImageDoubleTapped: (index) {
                      setState(() {
                        // Reset image transform
                      });
                    },
                    onTextPositionChanged: (textId, newPosition) {
                      setState(() {
                        if (textId != null) {
                          final index = _textElements.indexWhere((e) => e.id == textId);
                          if (index != -1) {
                            _textElements[index] = _textElements[index].copyWith(position: newPosition);
                          }
                        } else {
                          _textPosition = newPosition;
                        }
                      });
                    },
                    onTextSizeChanged: (textId, newSize) {
                      setState(() {
                        if (textId != null) {
                          final index = _textElements.indexWhere((e) => e.id == textId);
                          if (index != -1) {
                            _textElements[index] = _textElements[index].copyWith(size: newSize);
                          }
                        } else {
                          _textSize = newSize;
                        }
                      });
                    },
                    onTextTapped: (textId) {
                      setState(() {
                        final element = _textElements.firstWhere((e) => e.id == textId);
                        _selectTextElement(element);
                      });
                    },
                  ),
                ),
                // Floating ratio badge
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        '4:5 RATIO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom title if enabled
          if (_titleMode && _titlePosition == 'bottom' && _collageText.isNotEmpty)
            _buildExternalTitle(),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    final isExpanded = _selectedToolIndex != null;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF22111a),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Draggable handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Tool tabs
            _buildToolTabs(),
            // Expanded content
            if (isExpanded) ...[
              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
                margin: const EdgeInsets.symmetric(vertical: 6),
              ),
              // Contextual controls with reduced height (40% smaller)
              SizedBox(
                height: 108,
                child: _buildContextualControls(),
              ),
              const SizedBox(height: 8),
            ] else ...[
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToolTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildToolTab(Icons.grid_view, 'Layout', 0),
          _buildToolTab(Icons.aspect_ratio, 'Ratio', 1),
          _buildToolTab(Icons.border_outer, 'Frame', 2),
          _buildToolTab(Icons.text_fields, 'Text', 3),
        ],
      ),
    );
  }

  int? _selectedToolIndex;

  Widget _buildToolTab(IconData icon, String label, int index) {
    final isSelected = _selectedToolIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedToolIndex == index) {
            // Toggle off if already selected
            _selectedToolIndex = null;
          } else {
            // Select new tab
            _selectedToolIndex = index;
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : const Color(0xFF2a1520),
              borderRadius: BorderRadius.circular(16),
              border: isSelected 
                  ? null 
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ] : null,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualControls() {
    switch (_selectedToolIndex) {
      case 1:
        return _buildRatioControls();
      case 2:
        return _buildFrameControls();
      case 3:
        return _buildTextControls();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLayoutControls() {
    // Magazine mode: show magazine layouts only
    if (_isMagazineMode) {
      final allMagazineLayouts = MagazineLayouts.getAllLayouts();
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Magazine Layouts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allMagazineLayouts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final layout = allMagazineLayouts[index];
                  final isSelected = _magazineLayout?.id == layout.id;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _magazineLayout = layout;
                      });
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${layout.frames.length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            layout.name,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    
    // Regular collage mode
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final photoCount = photoProvider.selectedPhotos.length;
    final availableTemplates = FrameTemplates.getTemplatesForPhotoCount(photoCount);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Templates',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal scroll layout with Shuffle button first
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Shuffle button first
                _buildShuffleButton(),
                const SizedBox(width: 12),
                // Templates
                ...availableTemplates.asMap().entries.map((entry) {
                  final template = entry.value;
                  final isSelected = _selectedLayout.id == template.id;
                  final isNew = entry.key == 0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildTemplateOption(template, isSelected, isNew),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateOption(CollageLayout template, bool isSelected, bool isNew) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayout = template;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2a1520),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: _buildTemplatePreview(template),
          ),
          if (isNew)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplatePreview(CollageLayout template) {
    // Simple grid preview based on layout type
    return CustomPaint(
      painter: _TemplatePreviewPainter(template),
    );
  }

  Widget _buildShuffleButton() {
    return GestureDetector(
      onTap: () {
        if (_isMagazineMode) return;
        final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
        final photoCount = photoProvider.selectedPhotos.length;
        final availableTemplates = FrameTemplates.getTemplatesForPhotoCount(photoCount);
        if (availableTemplates.isNotEmpty) {
          setState(() {
            _selectedLayout = (availableTemplates..shuffle()).first;
          });
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
              Colors.purple.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shuffle,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Shuffle',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioControls() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aspect Ratio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildRatioOption('1:1', 1.0),
                  _buildRatioOption('4:5', 0.8),
                  _buildRatioOption('3:4', 0.75),
                  _buildRatioOption('9:16', 0.5625),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioOption(String label, double ratio) {
    final isSelected = (_aspectRatio - ratio).abs() < 0.01;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _aspectRatio = ratio;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : const Color(0xFF2a1520),
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? null 
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildFrameControls() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Spacing control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spacing',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_frameSpacing.toInt()}px',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.space_bar,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: const Color(0xFF2a1520),
                    thumbColor: Colors.white,
                    overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _frameSpacing,
                    min: 0,
                    max: 30,
                    onChanged: (value) {
                      setState(() {
                        _frameSpacing = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.border_style,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Corner radius control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Corner Radius',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_cornerRadius.toInt()}px',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.crop_square,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: const Color(0xFF2a1520),
                    thumbColor: Colors.white,
                    overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _cornerRadius,
                    min: 0,
                    max: 50,
                    onChanged: (value) {
                      setState(() {
                        _cornerRadius = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.rounded_corner,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildTextControls() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Add Text button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Text Elements',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  onPressed: _titleMode || _textElements.length >= _maxTextElements
                      ? null
                      : _addTextElement,
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: 'Add Text',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Title Mode',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _titleMode,
                  onChanged: (value) {
                    setState(() {
                      _titleMode = value;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_titleMode && _textElements.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _textElements.map((element) {
                  final isSelected = _selectedTextElement?.id == element.id;
                  return InputChip(
                    label: Text(
                      element.text,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _selectTextElement(element),
                    onDeleted: () => _deleteTextElement(element.id),
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    deleteIconColor: Colors.white70,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (!_titleMode) ...[
                  const Text(
                    'Font',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedFont,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                    ),
                    dropdownColor: const Color(0xFF2a1520),
                    items: _availableFonts.map((font) {
                      return DropdownMenuItem(
                        value: font,
                        child: Text(
                          _getFontDisplayName(font),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedFont = value;
                      });
                      _updateSelectedTextElement(fontFamily: value);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  Slider(
                    value: _textSize,
                    min: 12,
                    max: 60,
                    onChanged: (value) {
                      setState(() {
                        _textSize = value;
                      });
                      _updateSelectedTextElement(size: value);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Text Color',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableTextColors.map((color) {
                      final isSelected = _textColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _textColor = color;
                          });
                          _updateSelectedTextElement(textColor: color);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Background',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildBackgroundSwatch(Colors.transparent),
                      ..._availableTextColors.map(_buildBackgroundSwatch),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundSwatch(Color color) {
    final isSelected = _textBackgroundColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _textBackgroundColor = color;
        });
        _updateSelectedTextElement(backgroundColor: color);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color == Colors.transparent ? Colors.white.withValues(alpha: 0.05) : color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: color == Colors.transparent
            ? const Icon(Icons.clear, size: 14, color: Colors.white70)
            : null,
      ),
    );
  }

  void _showQualityDialogAndSave() {
    // TODO: Implement actual dialog and save logic
  }

  Widget _buildQualityOption(BuildContext context, String title, String subtitle, double pixelRatio) {
    return InkWell(
      onTap: () => Navigator.pop(context, pixelRatio),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToGallery(double pixelRatio) async {
    try {
      debugPrint('[CollageEdit] Starting save process...');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2a1520),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Saving to gallery...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      debugPrint('[CollageEdit] Finding RepaintBoundary...');
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[CollageEdit] ❌ RepaintBoundary not found');
        throw Exception('Could not find render boundary');
      }

      debugPrint('[CollageEdit] Converting to image with pixelRatio: $pixelRatio');
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      debugPrint('[CollageEdit] Image size: ${image.width}x${image.height}');
      
      debugPrint('[CollageEdit] Converting to bytes...');
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        debugPrint('[CollageEdit] ❌ Could not convert to bytes');
        throw Exception('Could not convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();
      debugPrint('[CollageEdit] Byte size: ${pngBytes.length}');
      
      // Save bytes to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'collage_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      debugPrint('[CollageEdit] Saving to temp file: $filePath');
      
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      
      final fileExists = await file.exists();
      debugPrint('[CollageEdit] File exists: $fileExists');

      debugPrint('[CollageEdit] Calling StorageService.saveToGallery...');
      final saveResult = await StorageService.saveToGallery(file);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      saveResult.fold(
        (error) {
          debugPrint('[CollageEdit] ❌ Save failed: ${error.displayMessage}');
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF2a1520),
                title: Row(
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Save Failed',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                content: Text(
                  error.displayMessage,
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        (success) {
          if (success) {
        debugPrint('[CollageEdit] ✅ Save successful');
        // Show success message
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF2a1520),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Success!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Text(
                Platform.isMacOS
                    ? 'Collage saved to Documents/saved_collages folder'
                    : 'Collage saved to gallery',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.popUntil(context, (route) => route.isFirst); // Go to home
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
          } else {
            debugPrint('[CollageEdit] ❌ Save returned false');
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2a1520),
                  title: const Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Save Failed',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  content: const Text(
                    '저장에 실패했습니다.',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'OK',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[CollageEdit] ❌ Error during save: $e');
      debugPrint('[CollageEdit] Stack trace: $stackTrace');
      
      // Close loading dialog if open
      if (mounted) {
        // Close all dialogs
        int popCount = 0;
        Navigator.popUntil(context, (route) {
          if (route.isFirst || !route.willHandlePopInternally) {
            return true;
          }
          popCount++;
          return false;
        });
        
        // Show detailed error dialog
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF2a1520),
                title: Row(
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Save Failed',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                content: Text(
                  'Could not save collage: $e\n\nPlease check permissions and try again.',
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            );
          }
        });
      }
    }
  }

  Widget _buildExternalTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: const Color(0xFF1a0d15),
      child: Center(
        child: Text(
          _collageText,
          style: _getTitleTextStyle(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMagazineTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: const Color(0xFFFAFAFA),
      child: Center(
        child: Text(
          _collageText,
          style: _getMagazineTitleTextStyle(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  TextStyle _getMagazineTitleTextStyle() {
    final baseStyle = TextStyle(
      color: Colors.black87,
      fontSize: _textSize * 1.8,  // Larger for magazine title
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    );

    if (_selectedFont.isEmpty || _selectedFont == 'Roboto') {
      return baseStyle;
    }

    try {
      switch (_selectedFont) {
        case 'Noto Serif KR':
          return GoogleFonts.notoSerifKr(textStyle: baseStyle);
        case 'Black Han Sans':
          return GoogleFonts.blackHanSans(textStyle: baseStyle);
        case 'Nanum Pen Script':
          return GoogleFonts.nanumPenScript(textStyle: baseStyle);
        case 'Do Hyeon':
          return GoogleFonts.doHyeon(textStyle: baseStyle);
        case 'Pacifico':
          return GoogleFonts.pacifico(textStyle: baseStyle);
        case 'Bebas Neue':
          return GoogleFonts.bebasNeue(textStyle: baseStyle);
        case 'Dancing Script':
          return GoogleFonts.dancingScript(textStyle: baseStyle);
        case 'Monoton':
          return GoogleFonts.monoton(textStyle: baseStyle);
        case 'Righteous':
          return GoogleFonts.righteous(textStyle: baseStyle);
        default:
          return baseStyle;
      }
    } catch (e) {
      return baseStyle;
    }
  }

  TextStyle _getTitleTextStyle() {
    final baseStyle = TextStyle(
      color: _textColor,
      fontSize: _textSize * 1.5,  // Larger for title
      fontWeight: FontWeight.bold,
    );

    if (_selectedFont.isEmpty || _selectedFont == 'Roboto') {
      return baseStyle;
    }

    try {
      switch (_selectedFont) {
        case 'Noto Serif KR':
          return GoogleFonts.notoSerifKr(textStyle: baseStyle);
        case 'Black Han Sans':
          return GoogleFonts.blackHanSans(textStyle: baseStyle);
        case 'Nanum Pen Script':
          return GoogleFonts.nanumPenScript(textStyle: baseStyle);
        case 'Do Hyeon':
          return GoogleFonts.doHyeon(textStyle: baseStyle);
        case 'Pacifico':
          return GoogleFonts.pacifico(textStyle: baseStyle);
        case 'Bebas Neue':
          return GoogleFonts.bebasNeue(textStyle: baseStyle);
        case 'Dancing Script':
          return GoogleFonts.dancingScript(textStyle: baseStyle);
        case 'Monoton':
          return GoogleFonts.monoton(textStyle: baseStyle);
        case 'Righteous':
          return GoogleFonts.righteous(textStyle: baseStyle);
        default:
          return baseStyle;
      }
    } catch (e) {
      return baseStyle;
    }
  }

  String _getFontDisplayName(String font) {
    switch (font) {
      case 'Roboto':
        return 'Basic';
      case 'Noto Serif KR':
        return '명조';
      case 'Black Han Sans':
        return '굵은체';
      case 'Nanum Pen Script':
        return '손글씨';
      case 'Do Hyeon':
        return '고딕';
      case 'Pacifico':
        return 'Script';
      case 'Bebas Neue':
        return 'Bold';
      case 'Dancing Script':
        return 'Handwrite';
      case 'Monoton':
        return 'Retro';
      case 'Righteous':
        return 'Rounded';
      default:
        return font;
    }
  }

  // Text Element Management Methods
  void _addTextElement() {
    if (_textElements.length >= _maxTextElements) return;
    
    setState(() {
      final newText = TextElement(
        text: '텍스트',
        position: Offset(100 + (_textElements.length * 20), 100 + (_textElements.length * 30)),
        size: _textSize,
        fontFamily: _selectedFont,
        textColor: _textColor,
        backgroundColor: _textBackgroundColor,
      );
      _textElements.add(newText);
      _selectedTextElement = newText;
    });
  }

  void _deleteTextElement(String id) {
    setState(() {
      _textElements.removeWhere((element) => element.id == id);
      if (_selectedTextElement?.id == id) {
        _selectedTextElement = _textElements.isNotEmpty ? _textElements.first : null;
      }
    });
  }

  void _selectTextElement(TextElement element) {
    setState(() {
      _selectedTextElement = element;
      // Update global text properties to match selected element
      _selectedFont = element.fontFamily;
      _textColor = element.textColor;
      _textBackgroundColor = element.backgroundColor;
      _textSize = element.size;
    });
  }

  void _updateSelectedTextElement({
    String? fontFamily,
    Color? textColor,
    Color? backgroundColor,
    double? size,
  }) {
    if (_selectedTextElement == null) return;
    
    setState(() {
      final index = _textElements.indexWhere((e) => e.id == _selectedTextElement!.id);
      if (index != -1) {
        _textElements[index] = _textElements[index].copyWith(
          fontFamily: fontFamily,
          textColor: textColor,
          backgroundColor: backgroundColor,
          size: size,
        );
        _selectedTextElement = _textElements[index];
        
        // Update global properties
        if (fontFamily != null) _selectedFont = fontFamily;
        if (textColor != null) _textColor = textColor;
        if (backgroundColor != null) _textBackgroundColor = backgroundColor;
        if (size != null) _textSize = size;
      }
    });
  }

  void _showPhotoOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2a1520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor),
                title: const Text('Replace Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _replacePhoto(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.shuffle, color: Theme.of(context).primaryColor),
                title: const Text('Swap with Another Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSwapDialog(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _replacePhoto(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? newImage = await picker.pickImage(source: ImageSource.gallery);
    
    if (newImage != null) {
      final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
      photoProvider.replacePhoto(index, newImage.path);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo replaced successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSwapDialog(int sourceIndex) {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final photos = photoProvider.selectedPhotos;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a1520),
          title: const Text('Select Photo to Swap', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (context, targetIndex) {
                if (targetIndex == sourceIndex) return const SizedBox.shrink();
                
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _swapPhotos(sourceIndex, targetIndex);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photos[targetIndex]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _swapPhotos(int index1, int index2) {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    photoProvider.swapPhotos(index1, index2);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photos swapped successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Custom painter for template preview (클래스 바깥으로 이동)
class _TemplatePreviewPainter extends CustomPainter {
  final CollageLayout layout;

  _TemplatePreviewPainter(this.layout);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Calculate grid dimensions
    int maxColumns = 0;
    int maxRows = 0;
    for (var cell in layout.cells) {
      maxColumns = (cell.column + cell.columnSpan) > maxColumns 
          ? cell.column + cell.columnSpan 
          : maxColumns;
      maxRows = (cell.row + cell.rowSpan) > maxRows 
          ? cell.row + cell.rowSpan 
          : maxRows;
    }

    final cellWidth = size.width / maxColumns;
    final cellHeight = size.height / maxRows;

    for (var cell in layout.cells) {
      final rect = Rect.fromLTWH(
        cell.column * cellWidth,
        cell.row * cellHeight,
        cell.columnSpan * cellWidth,
        cell.rowSpan * cellHeight,
      );
      
      final rrect = RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(2));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
