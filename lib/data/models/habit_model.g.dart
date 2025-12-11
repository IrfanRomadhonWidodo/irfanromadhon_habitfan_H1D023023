// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    try {
      final numOfFields = reader.readByte();
      final fields = <int, dynamic>{};
      
      for (int i = 0; i < numOfFields; i++) {
        final key = reader.readByte();
        final value = reader.read();
        fields[key] = value;
      }
      
      return HabitModel(
        id: fields[0] as String? ?? '',
        name: fields[1] as String? ?? '',
        icon: fields[2] as String? ?? '🎯',
        createdAt: fields[3] as DateTime? ?? DateTime.now(),
        completedDates: _parseCompletedDates(fields[4]),
        reminderEnabled: fields[5] as bool? ?? false,
        reminderHour: fields[6] as int?,
        reminderMinute: fields[7] as int?,
      );
    } catch (e) {
      // Return a default habit if reading fails
      return HabitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Unknown',
        icon: '🎯',
        createdAt: DateTime.now(),
      );
    }
  }
  
  List<DateTime> _parseCompletedDates(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return value.whereType<DateTime>().toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.completedDates)
      ..writeByte(5)
      ..write(obj.reminderEnabled)
      ..writeByte(6)
      ..write(obj.reminderHour)
      ..writeByte(7)
      ..write(obj.reminderMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
