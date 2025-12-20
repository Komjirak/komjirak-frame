import 'package:flutter/material.dart';
import '../models/collage_layout.dart';

class FrameSelector extends StatelessWidget {
  final List<CollageLayout> layouts;
  final CollageLayout? selectedLayout;
  final Function(CollageLayout) onLayoutSelected;

  const FrameSelector({
    Key? key,
    required this.layouts,
    this.selectedLayout,
    required this.onLayoutSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: layouts.length,
        itemBuilder: (context, index) {
          final layout = layouts[index];
          final isSelected = selectedLayout?.id == layout.id;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onLayoutSelected(layout),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getLayoutIcon(layout.type),
                      size: 48,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      layout.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getLayoutIcon(LayoutType type) {
    switch (type) {
      case LayoutType.classic:
        return Icons.grid_view;
      case LayoutType.split:
        return Icons.view_column;
      case LayoutType.mosaic:
        return Icons.dashboard;
      case LayoutType.film:
        return Icons.view_agenda;
      case LayoutType.polaroid:
        return Icons.crop_portrait;
      case LayoutType.bubbles:
        return Icons.bubble_chart;
      case LayoutType.grid:
        return Icons.grid_on;
      case LayoutType.magazine:
        return Icons.auto_stories;
    }
  }
}
