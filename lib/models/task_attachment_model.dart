import 'package:hive/hive.dart';

part 'task_attachment_model.g.dart';

@HiveType(typeId: 3)
class TaskAttachment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fileName;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  String fileType; // 'image', 'document', 'other'

  @HiveField(4)
  DateTime createdAt;

  TaskAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.createdAt,
  });

  TaskAttachment copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? fileType,
    DateTime? createdAt,
  }) {
    return TaskAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TaskAttachment(id: $id, fileName: $fileName, fileType: $fileType)';
  }
}
