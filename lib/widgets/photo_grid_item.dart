import 'package:flutter/material.dart';

class PhotoGridItem extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final int? selectionIndex;

  const PhotoGridItem({
    super.key,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    this.selectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          if (isSelected && selectionIndex != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${selectionIndex! + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
