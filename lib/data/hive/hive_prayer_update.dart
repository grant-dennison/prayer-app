import 'package:hive/hive.dart';

part 'hive_prayer_update.g.dart';

@HiveType(typeId: 2)
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
  }) : this.created = time ?? DateTime.now();
}

const boxIdPrayerUpdate = 'prayerUpdate';
