import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/hive/hive_prayer.dart';
import 'package:prayer_app/data/hive/hive_prayer_update.dart';
import 'package:prayer_app/data/id_list_manager.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/model/prayer_update_list_helper.dart';
import 'package:prayer_app/utils/uuid.dart';

import '../model/prayer_item.dart';
import '../model/prayer_update.dart';

class PrayerDataAccess {
  final Boxes _hiveBoxes;
  final IdListManager _listManager;

  PrayerDataAccess(Boxes boxes)
      : _hiveBoxes = boxes,
        _listManager = IdListManager(
          listBox: boxes.idList,
          chunkBox: boxes.idListChunk,
        );

  Future<PrayerItem> getRoot() async {
    return rootPrayerItem;
  }

  Future<PrayerItem?> getPrayerItem(String id) async {
    final hivePrayer = await _hiveBoxes.prayer.get(id);
    if (hivePrayer == null) {
      return null;
    }
    return PrayerItem(
      id: id,
      description: hivePrayer.description,
      lastPrayed: hivePrayer.lastPrayed,
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

  Future<List<PrayerItem>> getActiveChildren(PrayerItem prayerItem) async {
    final hivePrayer = await _hiveBoxes.prayer.get(prayerItem.id);
    if (hivePrayer == null) {
      return [];
    }
    return Future.wait(hivePrayer.activeChildIds
        .where((e) => prayerItemExists(e))
        .map((e) async {
      final item = await getPrayerItem(e);
      return item!;
    }));
  }

  Future<PrayerUpdateListHelper> getUpdateHelper(PrayerItem prayerItem) async {
    final hivePrayer = await _hiveBoxes.prayer.get(prayerItem.id);
    if (hivePrayer == null) {
      return PrayerUpdateListHelper(listHelper: null, dataAccess: this);
    }
    return PrayerUpdateListHelper(
        listHelper: await _listManager.getList(hivePrayer.updateIdListId),
        dataAccess: this);
  }

  Future<void> createPrayerItem(PrayerItem prayerItem) async {
    await Future.wait([
      _hiveBoxes.prayer.put(
        prayerItem.id,
        HivePrayer(
          description: prayerItem.description,
          updateIdListId: await _listManager.createList(),
          answeredChildIdListId: await _listManager.createList(),
        ),
      ),
    ]);
  }

  Future<void> editPrayerItem(PrayerItem prayerItem, String description) async {
    final hivePrayer = await _hiveBoxes.prayer.get(prayerItem.id);
    if (hivePrayer != null) {
      hivePrayer.description = description;
      await _hiveBoxes.prayer.put(prayerItem.id, hivePrayer);
    }
  }

  Future<void> linkChild({
    required PrayerItem parent,
    required PrayerItem child,
  }) async {
    final hivePrayerParent = await _hiveBoxes.prayer.get(parent.id);
    if (hivePrayerParent == null) return;
    final newChildIds = List<String>.from(hivePrayerParent.activeChildIds);
    newChildIds.add(child.id);
    hivePrayerParent.activeChildIds = newChildIds;
    await _hiveBoxes.prayer.put(parent.id, hivePrayerParent);
  }

  Future<void> unlinkChild({
    required PrayerItem parent,
    required PrayerItem child,
  }) async {
    final hivePrayerParent = await _hiveBoxes.prayer.get(parent.id);
    if (hivePrayerParent == null) return;
    final newChildIds = List<String>.from(hivePrayerParent.activeChildIds);
    newChildIds.remove(child.id);
    hivePrayerParent.activeChildIds = newChildIds;
    await _hiveBoxes.prayer.put(parent.id, hivePrayerParent);
  }

  Future<void> markPrayed(PrayerItem prayerItem, DateTime when) async {
    final hivePrayer = await _hiveBoxes.prayer.get(prayerItem.id);
    if (hivePrayer != null) {
      hivePrayer.timesPrayed++;
      hivePrayer.lastPrayed = when;
      await _hiveBoxes.prayer.put(prayerItem.id, hivePrayer);
    }
  }

  Future<void> addUpdate(
      PrayerItem prayerItem, DateTime when, String text) async {
    final id = genUuid();
    final status = HivePrayerUpdate(
        prayerId: prayerItem.id, time: when, description: text);
    await Future.wait([
      _hiveBoxes.prayerUpdate.put(id, status),
      () async {
        final hivePrayer = await _hiveBoxes.prayer.get(prayerItem.id);
        if (hivePrayer == null) return;
        final listHelper =
            await _listManager.getList(hivePrayer.updateIdListId);
        await listHelper.insertId(0, id);
      }()
    ]);
  }
}
