import 'package:hive/hive.dart';

part 'hive_prayer_cached_info.g.dart';

@HiveType(typeId: 10)
class HivePrayerCachedInfo extends HiveObject {
  @HiveField(0)
  int timesPrayed = 0;

  @HiveField(1)
  DateTime? firstPrayed;

  @HiveField(2)
  DateTime? lastPrayed;
}

const boxIdPrayerCachedInfo = 'prayerCachedInfo';
