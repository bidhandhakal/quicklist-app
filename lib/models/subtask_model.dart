import 'package:hive/hive.dart';

part 'subtask_model.g.dart';

@HiveType(typeId: 2)
class Subtask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime createdAt;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Subtask(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
