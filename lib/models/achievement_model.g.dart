// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 4;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      requiredValue: fields[4] as int,
      type: fields[5] as AchievementType,
      isUnlocked: fields[6] as bool,
      unlockedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.requiredValue)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.isUnlocked)
      ..writeByte(7)
      ..write(obj.unlockedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementTypeAdapter extends TypeAdapter<AchievementType> {
  @override
  final int typeId = 5;

  @override
  AchievementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementType.tasksCompleted;
      case 1:
        return AchievementType.streak;
      case 2:
        return AchievementType.dailyGoal;
      case 3:
        return AchievementType.perfectWeek;
      case 4:
        return AchievementType.earlyBird;
      case 5:
        return AchievementType.productivity;
      default:
        return AchievementType.tasksCompleted;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementType obj) {
    switch (obj) {
      case AchievementType.tasksCompleted:
        writer.writeByte(0);
        break;
      case AchievementType.streak:
        writer.writeByte(1);
        break;
      case AchievementType.dailyGoal:
        writer.writeByte(2);
        break;
      case AchievementType.perfectWeek:
        writer.writeByte(3);
        break;
      case AchievementType.earlyBird:
        writer.writeByte(4);
        break;
      case AchievementType.productivity:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
