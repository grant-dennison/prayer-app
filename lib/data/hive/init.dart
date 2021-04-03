import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_app/data/root_prayer_item.dart';

import 'hive_prayer.dart';
import 'hive_prayer_cached_info.dart';
import 'hive_prayer_checkin.dart';
import 'hive_prayer_update.dart';

const _v1 = 'v1';

Future<void> initHive() async {
  await Hive.initFlutter(_v1);
  Hive.registerAdapter(HivePrayerAdapter());
  Hive.registerAdapter(HivePrayerCachedInfoAdapter());
  Hive.registerAdapter(HivePrayerCheckinAdapter());
  Hive.registerAdapter(HivePrayerUpdateAdapter());

  final prayerBox = await Hive.openLazyBox<HivePrayer>(boxIdPrayer);
  if (!prayerBox.containsKey(rootPrayerItem.id)) {
    await prayerBox.put(
        rootPrayerItem.id, HivePrayer(description: rootPrayerItem.description));
  }
  prayerBox.close();
}
