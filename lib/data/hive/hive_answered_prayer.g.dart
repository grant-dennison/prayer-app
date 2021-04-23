// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_answered_prayer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAnsweredPrayerAdapter extends TypeAdapter<HiveAnsweredPrayer> {
  @override
  final int typeId = 3;

  @override
  HiveAnsweredPrayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAnsweredPrayer(
      prayerId: fields[0] as String,
      description: fields[1] as String,
      breadcrumbIds: (fields[3] as List).cast<String>(),
      breadcrumbDescriptions: (fields[4] as List).cast<String>(),
    )..answered = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, HiveAnsweredPrayer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.prayerId)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.answered)
      ..writeByte(3)
      ..write(obj.breadcrumbIds)
      ..writeByte(4)
      ..write(obj.breadcrumbDescriptions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAnsweredPrayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HiveAnsweredPrayer _$HiveAnsweredPrayerFromJson(Map<String, dynamic> json) {
  return HiveAnsweredPrayer(
    prayerId: json['prayerId'] as String,
    description: json['description'] as String,
    breadcrumbIds: (json['breadcrumbIds'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    breadcrumbDescriptions: (json['breadcrumbDescriptions'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
  )..answered = DateTime.parse(json['answered'] as String);
}

Map<String, dynamic> _$HiveAnsweredPrayerToJson(HiveAnsweredPrayer instance) =>
    <String, dynamic>{
      'prayerId': instance.prayerId,
      'description': instance.description,
      'answered': instance.answered.toIso8601String(),
      'breadcrumbIds': instance.breadcrumbIds,
      'breadcrumbDescriptions': instance.breadcrumbDescriptions,
    };
