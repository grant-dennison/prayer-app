import 'package:hive/hive.dart';

part 'hive_id_list_chunk.g.dart';

@HiveType(typeId: 21)
class HiveIdListChunk extends HiveObject {
  @HiveField(0)
  String parentListId = '';
  @HiveField(1)
  String? previousChunkId;
  @HiveField(2)
  String? nextChunkId;
  @HiveField(3)
  List<String> ids = [];
}

const boxIdIdListChunk = 'idListChunk';
