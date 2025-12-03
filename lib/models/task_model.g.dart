// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      deadline: fields[5] as DateTime?,
      categoryId: fields[6] as String?,
      priority: fields[7] as int,
      completedAt: fields[8] as DateTime?,
      reminderEnabled: fields[9] as bool,
      reminderTime: fields[10] as DateTime?,
      tags: (fields[11] as List?)?.cast<String>(),
      recurrence: fields[12] as RecurrencePattern?,
      subtasks: (fields[13] as List?)?.cast<Subtask>(),
      attachments: (fields[14] as List?)?.cast<TaskAttachment>(),
      nextRecurrenceDate: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.deadline)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.reminderEnabled)
      ..writeByte(10)
      ..write(obj.reminderTime)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.recurrence)
      ..writeByte(13)
      ..write(obj.subtasks)
      ..writeByte(14)
      ..write(obj.attachments)
      ..writeByte(15)
      ..write(obj.nextRecurrenceDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrencePatternAdapter extends TypeAdapter<RecurrencePattern> {
  @override
  final int typeId = 1;

  @override
  RecurrencePattern read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrencePattern.daily;
      case 1:
        return RecurrencePattern.weekly;
      case 2:
        return RecurrencePattern.monthly;
      case 3:
        return RecurrencePattern.yearly;
      default:
        return RecurrencePattern.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrencePattern obj) {
    switch (obj) {
      case RecurrencePattern.daily:
        writer.writeByte(0);
        break;
      case RecurrencePattern.weekly:
        writer.writeByte(1);
        break;
      case RecurrencePattern.monthly:
        writer.writeByte(2);
        break;
      case RecurrencePattern.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrencePatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
