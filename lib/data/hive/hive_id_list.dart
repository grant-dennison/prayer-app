import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hive_id_list.g.dart';

@HiveType(typeId: 20)
@JsonSerializable()
class HiveIdList extends HiveObject {
  @HiveField(0)
  int length = 0;
  @HiveField(1)
  String firstChunkId = '';

  HiveIdList();

  factory HiveIdList.fromJson(Map<String, dynamic> json) =>
      _$HiveIdListFromJson(json);
  Map<String, dynamic> toJson() => _$HiveIdListToJson(this);
}

const boxIdIdList = 'idList';
