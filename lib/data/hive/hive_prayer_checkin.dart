import 'package:hive/hive.dart';

part 'hive_prayer_checkin.g.dart';

@HiveType(typeId: 3)
class HivePrayerCheckin extends HiveObject {
  @HiveField(0)
  String prayerId;

  @HiveField(1)
  DateTime time;

  HivePrayerCheckin({
    this.prayerId = '',
    DateTime? time,
  }) : this.time = time ?? DateTime.now();
}

const boxIdPrayerCheckin = 'prayerCheckin';
