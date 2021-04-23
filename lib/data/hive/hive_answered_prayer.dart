import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hive_answered_prayer.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class HiveAnsweredPrayer extends HiveObject {
  @HiveField(0)
  String prayerId;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime answered;

  @HiveField(3)
  List<String> breadcrumbIds;

  @HiveField(4)
  List<String> breadcrumbDescriptions;

  HiveAnsweredPrayer({
    this.prayerId = '',
    this.description = '',
    DateTime? time,
    this.breadcrumbIds = const [],
    this.breadcrumbDescriptions = const [],
  }) : answered = time ?? DateTime.now();

  factory HiveAnsweredPrayer.fromJson(Map<String, dynamic> json) =>
      _$HiveAnsweredPrayerFromJson(json);
  Map<String, dynamic> toJson() => _$HiveAnsweredPrayerToJson(this);
}

const boxIdAnsweredPrayer = 'answeredPrayer';
