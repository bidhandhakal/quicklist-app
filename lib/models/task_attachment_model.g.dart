// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_attachment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAttachmentAdapter extends TypeAdapter<TaskAttachment> {
  @override
  final int typeId = 3;

  @override
  TaskAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskAttachment(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      fileType: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskAttachment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
