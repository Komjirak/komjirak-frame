import 'package:flutter/material.dart';

/// 텍스트 요소 모델
class TextElement {
  final String id;
  String text;
  Offset position;
  double size;
  String fontFamily;
  Color textColor;
  Color backgroundColor;
  bool isSelected;

  TextElement({
    String? id,
    required this.text,
    required this.position,
    this.size = 18.0,
    this.fontFamily = 'Roboto',
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.isSelected = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  TextElement copyWith({
    String? text,
    Offset? position,
    double? size,
    String? fontFamily,
    Color? textColor,
    Color? backgroundColor,
    bool? isSelected,
  }) {
    return TextElement(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      size: size ?? this.size,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': size,
      'fontFamily': fontFamily,
      'textColor': textColor.value,
      'backgroundColor': backgroundColor.value,
    };
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id'],
      text: json['text'],
      position: Offset(
        json['position']['dx']?.toDouble() ?? 0,
        json['position']['dy']?.toDouble() ?? 0,
      ),
      size: json['size']?.toDouble() ?? 18.0,
      fontFamily: json['fontFamily'] ?? 'Roboto',
      textColor: Color(json['textColor'] ?? Colors.white.value),
      backgroundColor: Color(json['backgroundColor'] ?? Colors.black.value),
    );
  }
}
