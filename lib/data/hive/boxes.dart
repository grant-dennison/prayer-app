import 'package:hive/hive.dart';

import 'hive_prayer.dart';
import 'hive_prayer_cached_info.dart';
import 'hive_prayer_checkin.dart';
import 'hive_prayer_child_ids.dart';
import 'hive_prayer_update.dart';
import 'hive_prayer_update_ids.dart';

class Boxes {
  final prayer = Hive.lazyBox<HivePrayer>(boxIdPrayer);
  final prayerCachedInfo =
      Hive.lazyBox<HivePrayerCachedInfo>(boxIdPrayerCachedInfo);
  final prayerCheckin = Hive.lazyBox<HivePrayerCheckin>(boxIdPrayerCheckin);
  final prayerChildIds = Hive.lazyBox<List<String>>(boxIdPrayerChildIds);
  final prayerUpdate = Hive.lazyBox<HivePrayerUpdate>(boxIdPrayerUpdate);
  final prayerUpdateIds = Hive.lazyBox<List<String>>(boxIdPrayerUpdateIds);
}
