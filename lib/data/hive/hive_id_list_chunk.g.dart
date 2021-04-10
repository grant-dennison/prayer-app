// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_id_list_chunk.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveIdListChunkAdapter extends TypeAdapter<HiveIdListChunk> {
  @override
  final int typeId = 21;

  @override
  HiveIdListChunk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveIdListChunk()
      ..parentListId = fields[0] as String
      ..previousChunkId = fields[1] as String?
      ..nextChunkId = fields[2] as String?
      ..ids = (fields[3] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, HiveIdListChunk obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.parentListId)
      ..writeByte(1)
      ..write(obj.previousChunkId)
      ..writeByte(2)
      ..write(obj.nextChunkId)
      ..writeByte(3)
      ..write(obj.ids);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveIdListChunkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
