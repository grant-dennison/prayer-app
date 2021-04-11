// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_prayer_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivePrayerUpdateAdapter extends TypeAdapter<HivePrayerUpdate> {
  @override
  final int typeId = 2;

  @override
  HivePrayerUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePrayerUpdate(
      prayerId: fields[0] as String,
      description: fields[1] as String,
    )..created = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, HivePrayerUpdate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.prayerId)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePrayerUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HivePrayerUpdate _$HivePrayerUpdateFromJson(Map<String, dynamic> json) {
  return HivePrayerUpdate(
    prayerId: json['prayerId'] as String,
    description: json['description'] as String,
  )..created = DateTime.parse(json['created'] as String);
}

Map<String, dynamic> _$HivePrayerUpdateToJson(HivePrayerUpdate instance) =>
    <String, dynamic>{
      'prayerId': instance.prayerId,
      'description': instance.description,
      'created': instance.created.toIso8601String(),
    };
