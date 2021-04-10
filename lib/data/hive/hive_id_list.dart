import 'package:hive/hive.dart';

part 'hive_id_list.g.dart';

@HiveType(typeId: 20)
class HiveIdList extends HiveObject {
  @HiveField(0)
  int length = 0;
  @HiveField(1)
  String firstChunkId = '';
}
