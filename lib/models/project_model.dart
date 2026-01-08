import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;
  final List<String> photoPaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailPath;
  final bool isMagazineLayout;
  final String? magazineLayoutId;

  Project({
    String? id,
    required this.name,
    required this.photoPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.thumbnailPath,
    this.isMagazineLayout = false,
    this.magazineLayoutId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Project copyWith({
    String? name,
    List<String>? photoPaths,
    DateTime? updatedAt,
    String? thumbnailPath,
    bool? isMagazineLayout,
    String? magazineLayoutId,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isMagazineLayout: isMagazineLayout ?? this.isMagazineLayout,
      magazineLayoutId: magazineLayoutId ?? this.magazineLayoutId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoPaths': photoPaths,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'thumbnailPath': thumbnailPath,
      'isMagazineLayout': isMagazineLayout,
      'magazineLayoutId': magazineLayoutId,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      photoPaths: List<String>.from(json['photoPaths']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      thumbnailPath: json['thumbnailPath'],
      isMagazineLayout: json['isMagazineLayout'] ?? false,
      magazineLayoutId: json['magazineLayoutId'],
    );
  }
}
