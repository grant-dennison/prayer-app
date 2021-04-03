import 'package:hive/hive.dart';

import 'hive_prayer.dart';
import 'hive_prayer_cached_info.dart';
import 'hive_prayer_checkin.dart';
import 'hive_prayer_child_ids.dart';
import 'hive_prayer_update.dart';
import 'hive_prayer_update_ids.dart';

Future<Boxes> openBoxes() async {
  final prayer = await Hive.openLazyBox<HivePrayer>(boxIdPrayer);
  final prayerCachedInfo =
      await Hive.openLazyBox<HivePrayerCachedInfo>(boxIdPrayerCachedInfo);
  final prayerCheckin =
      await Hive.openLazyBox<HivePrayerCheckin>(boxIdPrayerCheckin);
  final prayerChildIds =
      await Hive.openLazyBox<List<dynamic>>(boxIdPrayerChildIds);
  final prayerUpdate =
      await Hive.openLazyBox<HivePrayerUpdate>(boxIdPrayerUpdate);
  final prayerUpdateIds =
      await Hive.openLazyBox<List<dynamic>>(boxIdPrayerUpdateIds);
  print('all boxes opened');
  return Boxes(
    prayer: prayer,
    prayerCachedInfo: prayerCachedInfo,
    prayerCheckin: prayerCheckin,
    prayerChildIds: prayerChildIds,
    prayerUpdate: prayerUpdate,
    prayerUpdateIds: prayerUpdateIds,
  );
}

class Boxes {
  final LazyBox<HivePrayer> prayer;
  final LazyBox<HivePrayerCachedInfo> prayerCachedInfo;
  final LazyBox<HivePrayerCheckin> prayerCheckin;
  // FTODO: Can we make this not dynamic?
  final LazyBox<List<dynamic>> prayerChildIds;
  final LazyBox<HivePrayerUpdate> prayerUpdate;
  // FTODO: Can we make this not dynamic?
  final LazyBox<List<dynamic>> prayerUpdateIds;

  Boxes({
    required this.prayer,
    required this.prayerCachedInfo,
    required this.prayerCheckin,
    required this.prayerChildIds,
    required this.prayerUpdate,
    required this.prayerUpdateIds,
  });

  Future<void> dispose() async {
    await Future.wait([
      prayer.close(),
      prayerCachedInfo.close(),
      prayerCheckin.close(),
      prayerChildIds.close(),
      prayerUpdate.close(),
      prayerUpdateIds.close(),
    ]);
  }
}
