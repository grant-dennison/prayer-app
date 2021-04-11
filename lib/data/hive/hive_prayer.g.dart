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
      updateIdListId: fields[2] as String,
      answeredChildIdListId: fields[7] as String,
    )
      ..created = fields[1] as DateTime
      ..activeChildIds = (fields[3] as List).cast<String>()
      ..timesPrayed = fields[4] as int
      ..lastPrayed = fields[5] as DateTime?
      ..answered = fields[6] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, HivePrayer obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.created)
      ..writeByte(2)
      ..write(obj.updateIdListId)
      ..writeByte(3)
      ..write(obj.activeChildIds)
      ..writeByte(4)
      ..write(obj.timesPrayed)
      ..writeByte(5)
      ..write(obj.lastPrayed)
      ..writeByte(6)
      ..write(obj.answered)
      ..writeByte(7)
      ..write(obj.answeredChildIdListId);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HivePrayer _$HivePrayerFromJson(Map<String, dynamic> json) {
  return HivePrayer(
    description: json['description'] as String,
    updateIdListId: json['updateIdListId'] as String,
    answeredChildIdListId: json['answeredChildIdListId'] as String,
  )
    ..created = DateTime.parse(json['created'] as String)
    ..activeChildIds = (json['activeChildIds'] as List<dynamic>)
        .map((e) => e as String)
        .toList()
    ..timesPrayed = json['timesPrayed'] as int
    ..lastPrayed = json['lastPrayed'] == null
        ? null
        : DateTime.parse(json['lastPrayed'] as String)
    ..answered = json['answered'] == null
        ? null
        : DateTime.parse(json['answered'] as String);
}

Map<String, dynamic> _$HivePrayerToJson(HivePrayer instance) =>
    <String, dynamic>{
      'description': instance.description,
      'created': instance.created.toIso8601String(),
      'updateIdListId': instance.updateIdListId,
      'activeChildIds': instance.activeChildIds,
      'timesPrayed': instance.timesPrayed,
      'lastPrayed': instance.lastPrayed?.toIso8601String(),
      'answered': instance.answered?.toIso8601String(),
      'answeredChildIdListId': instance.answeredChildIdListId,
    };
