import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/hive/hive_prayer.dart';
import 'package:prayer_app/data/hive/hive_prayer_cached_info.dart';
import 'package:prayer_app/data/hive/hive_prayer_checkin.dart';
import 'package:prayer_app/data/hive/hive_prayer_update.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/utils/uuid.dart';

import '../model/prayer_item.dart';
import '../model/prayer_item_stats.dart';
import '../model/prayer_update.dart';

class PrayerDataAccess {
  final Boxes _hiveBoxes;

  PrayerDataAccess(Boxes boxes) : _hiveBoxes = boxes;

  Future<PrayerItem> getRoot() async {
    return rootPrayerItem;
  }

  Future<PrayerItem?> getPrayerItem(String id) async {
    final hivePrayer = await _hiveBoxes.prayer.get(id);
    if (hivePrayer == null) {
      return null;
    }
    final cachedInfo = await _hiveBoxes.prayerCachedInfo.get(id);
    return PrayerItem(
      id: id,
      description: hivePrayer.description,
      lastPrayed: cachedInfo?.lastPrayed,
    );
  }

  bool prayerItemExists(String id) {
    return _hiveBoxes.prayer.containsKey(id);
  }

  Future<PrayerUpdate?> getPrayerUpdate(String id) async {
    final hivePrayerUpdate = await _hiveBoxes.prayerUpdate.get(id);
    if (hivePrayerUpdate == null) {
      return null;
    }
    return PrayerUpdate(
      id: id,
      time: hivePrayerUpdate.created,
      text: hivePrayerUpdate.description,
    );
  }

  Future<List<PrayerItem>> getChildren(PrayerItem prayerItem) async {
    final childIds = await _hiveBoxes.prayerChildIds.get(prayerItem.id);
    if (childIds == null) {
      return [];
    }
    return await Future.wait(
        childIds.where((e) => prayerItemExists(e)).map((e) async {
      final item = await getPrayerItem(e);
      return item!;
    }));
  }

  Future<List<PrayerUpdate>> getUpdates(PrayerItem prayerItem) async {
    final updateIds = await _hiveBoxes.prayerUpdateIds.get(prayerItem.id);
    if (updateIds == null) {
      return [];
    }
    return await Future.wait(updateIds.map((e) async {
      final item = await getPrayerUpdate(e);
      return item ??
          PrayerUpdate(id: e, time: DateTime.now(), text: '[NOT FOUND]');
    }));
  }

  Future<PrayerItemStats> getStats(PrayerItem prayerItem) async {
    return PrayerItemStats(
      numberPrayed: 3,
      firstPrayedTime: DateTime.utc(1989, 11, 9),
      lastPrayedTime: DateTime.now(),
    );
  }

  Future<void> createPrayerItem(PrayerItem prayerItem) async {
    await Future.wait([
      _hiveBoxes.prayer
          .put(prayerItem.id, HivePrayer(description: prayerItem.description)),
      _hiveBoxes.prayerChildIds.put(prayerItem.id, []),
      _hiveBoxes.prayerUpdateIds.put(prayerItem.id, []),
      _hiveBoxes.prayerCachedInfo.put(prayerItem.id, HivePrayerCachedInfo()),
    ]);
  }

  Future<void> linkChild({
    required PrayerItem parent,
    required PrayerItem child,
  }) async {
    final existingChildIds = await _hiveBoxes.prayerChildIds.get(parent.id);
    final newChildIds = List<String>.from(existingChildIds ?? []);
    newChildIds.add(child.id);
    await _hiveBoxes.prayerChildIds.put(parent.id, newChildIds);
  }

  Future<void> unlinkChild({
    required PrayerItem parent,
    required PrayerItem child,
  }) async {
    final existingChildIds = await _hiveBoxes.prayerChildIds.get(parent.id);
    final newChildIds = List<String>.from(existingChildIds ?? []);
    newChildIds.remove(child.id);
    await _hiveBoxes.prayerChildIds.put(parent.id, newChildIds);
  }

  Future<void> markPrayed(PrayerItem prayerItem, DateTime when) async {
    await Future.wait([
      () async {
        var hivePrayerCachedInfo =
            await _hiveBoxes.prayerCachedInfo.get(prayerItem.id);
        if (hivePrayerCachedInfo == null) {
          hivePrayerCachedInfo = HivePrayerCachedInfo();
        }
        if (hivePrayerCachedInfo.firstPrayed == null) {
          hivePrayerCachedInfo.firstPrayed = when;
        }
        hivePrayerCachedInfo.timesPrayed++;
        hivePrayerCachedInfo.lastPrayed = when;
        await _hiveBoxes.prayerCachedInfo
            .put(prayerItem.id, hivePrayerCachedInfo);
      }(),
      _hiveBoxes.prayerCheckin.put(
        genUuid(),
        HivePrayerCheckin(prayerId: prayerItem.id),
      ),
    ]);
  }

  Future<void> addUpdate(
      PrayerItem prayerItem, DateTime when, String text) async {
    final id = genUuid();
    final status = HivePrayerUpdate(
        prayerId: prayerItem.id, time: when, description: text);
    await Future.wait([
      _hiveBoxes.prayerUpdate.put(id, status),
      () async {
        final existingUpdateIds =
            await _hiveBoxes.prayerUpdateIds.get(prayerItem.id);
        final newUpdateIds = List<String>.from(existingUpdateIds ?? []);
        newUpdateIds.add(id);
        _hiveBoxes.prayerUpdateIds.put(prayerItem.id, newUpdateIds);
      }()
    ]);
  }
}
