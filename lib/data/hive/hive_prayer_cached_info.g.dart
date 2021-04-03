// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_prayer_cached_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivePrayerCachedInfoAdapter extends TypeAdapter<HivePrayerCachedInfo> {
  @override
  final int typeId = 10;

  @override
  HivePrayerCachedInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePrayerCachedInfo()
      ..timesPrayed = fields[0] as int
      ..firstPrayed = fields[1] as DateTime?
      ..lastPrayed = fields[2] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, HivePrayerCachedInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.timesPrayed)
      ..writeByte(1)
      ..write(obj.firstPrayed)
      ..writeByte(2)
      ..write(obj.lastPrayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePrayerCachedInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
