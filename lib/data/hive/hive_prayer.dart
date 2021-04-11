import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hive_prayer.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class HivePrayer extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  DateTime created = DateTime.now();

  @HiveField(2)
  String updateIdListId;

  @HiveField(3)
  List<String> activeChildIds = [];

  @HiveField(4)
  int timesPrayed = 0;
  @HiveField(5)
  DateTime? lastPrayed;

  @HiveField(6)
  DateTime? answered;

  @HiveField(7)
  String answeredChildIdListId;

  HivePrayer({
    this.description = '',
    required this.updateIdListId,
    required this.answeredChildIdListId,
  });

  factory HivePrayer.fromJson(Map<String, dynamic> json) =>
      _$HivePrayerFromJson(json);
  Map<String, dynamic> toJson() => _$HivePrayerToJson(this);
}

const boxIdPrayer = 'prayer';
