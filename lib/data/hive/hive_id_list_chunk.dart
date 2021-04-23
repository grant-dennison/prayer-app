import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hive_id_list_chunk.g.dart';

@HiveType(typeId: 21)
@JsonSerializable()
class HiveIdListChunk extends HiveObject {
  @HiveField(0)
  String parentListId = '';
  @HiveField(1)
  String? previousChunkId;
  @HiveField(2)
  String? nextChunkId;
  @HiveField(3)
  List<String> ids = [];

  HiveIdListChunk();

  factory HiveIdListChunk.fromJson(Map<String, dynamic> json) =>
      _$HiveIdListChunkFromJson(json);
  Map<String, dynamic> toJson() => _$HiveIdListChunkToJson(this);
}

const boxIdIdListChunk = 'idListChunk';
