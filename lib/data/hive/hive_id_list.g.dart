// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_id_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveIdListAdapter extends TypeAdapter<HiveIdList> {
  @override
  final int typeId = 20;

  @override
  HiveIdList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveIdList()
      ..length = fields[0] as int
      ..firstChunkId = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, HiveIdList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.length)
      ..writeByte(1)
      ..write(obj.firstChunkId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveIdListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
