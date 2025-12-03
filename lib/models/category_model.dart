import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  int iconCodePoint;

  @HiveField(5)
  DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.colorValue,
    required this.iconCodePoint,
    required this.createdAt,
  });

  // Get Color object from colorValue
  Color get color => Color(colorValue);

  // Get IconData from iconCodePoint
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Category copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    int? iconCodePoint,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, colorValue: $colorValue)';
  }
}
