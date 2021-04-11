import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hive_prayer_update.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class HivePrayerUpdate extends HiveObject {
  @HiveField(0)
  String prayerId;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime created;

  HivePrayerUpdate({
    this.prayerId = '',
    this.description = '',
    DateTime? time,
  }) : created = time ?? DateTime.now();

  factory HivePrayerUpdate.fromJson(Map<String, dynamic> json) =>
      _$HivePrayerUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$HivePrayerUpdateToJson(this);
}

const boxIdPrayerUpdate = 'prayerUpdate';
