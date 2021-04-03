// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_prayer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivePrayerAdapter extends TypeAdapter<HivePrayer> {
  @override
  final int typeId = 1;

  @override
  HivePrayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePrayer(
      description: fields[0] as String,
    )..created = fields[1] as DateTime;
  }

  @override
  void write(BinaryWriter writer, HivePrayer obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePrayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
