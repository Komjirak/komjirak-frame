import 'package:flutter/foundation.dart';

class PhotoProvider with ChangeNotifier {
  final List<String> _selectedPhotos = [];
  final int maxPhotos = 12;

  List<String> get selectedPhotos => List.unmodifiable(_selectedPhotos);
  int get photoCount => _selectedPhotos.length;
  int get remainingSlots => maxPhotos - _selectedPhotos.length;
  bool get canAddMore => _selectedPhotos.length < maxPhotos;
  bool get hasMinimumPhotos => _selectedPhotos.isNotEmpty;

  void addPhoto(String photoPath) {
    if (canAddMore && !_selectedPhotos.contains(photoPath)) {
      _selectedPhotos.add(photoPath);
      notifyListeners();
    }
  }

  void addPhotos(List<String> photoPaths) {
    for (var path in photoPaths) {
      if (!canAddMore) break;
      if (!_selectedPhotos.contains(path)) {
        _selectedPhotos.add(path);
      }
    }
    notifyListeners();
  }

  void removePhoto(String photoPath) {
    _selectedPhotos.remove(photoPath);
    notifyListeners();
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _selectedPhotos.removeAt(oldIndex);
    _selectedPhotos.insert(newIndex, item);
    notifyListeners();
  }

  void clearPhotos() {
    _selectedPhotos.clear();
    notifyListeners();
  }

  void setPhotos(List<String> photos) {
    _selectedPhotos.clear();
    _selectedPhotos.addAll(photos.take(maxPhotos));
    notifyListeners();
  }

  // Swap two photos by their indices
  void swapPhotos(int index1, int index2) {
    if (index1 >= 0 && index1 < _selectedPhotos.length &&
        index2 >= 0 && index2 < _selectedPhotos.length) {
      final temp = _selectedPhotos[index1];
      _selectedPhotos[index1] = _selectedPhotos[index2];
      _selectedPhotos[index2] = temp;
      notifyListeners();
    }
  }

  // Replace a photo at a specific index with a new photo
  Future<void> replacePhoto(int index, String newPhotoPath) async {
    if (index >= 0 && index < _selectedPhotos.length) {
      _selectedPhotos[index] = newPhotoPath;
      notifyListeners();
    }
  }
}
