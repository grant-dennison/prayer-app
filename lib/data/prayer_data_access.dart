import 'package:prayer_app/data/answered_prayer_list.dart';
import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/hive/hive_answered_prayer.dart';
import 'package:prayer_app/data/hive/hive_prayer.dart';
import 'package:prayer_app/data/hive/hive_prayer_update.dart';
import 'package:prayer_app/data/id_list_manager.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/model/answered_prayer.dart';
import 'package:prayer_app/model/answered_prayer_list_helper.dart';
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
    final rootPrayerItem = await getPrayerItem(rootPrayerItemId);
    if (rootPrayerItem == null) {
      throw 'Root prayer item not found. Might need to restart app.';
    }
    return rootPrayerItem;
  }

  Future<PrayerItem?> getPrayerItem(String id) async {
    final hivePrayer = await _hiveBoxes.prayer.get(id);
    if (hivePrayer == null) {
      return null;
    }

    final updateList = await _listManager.getList(hivePrayer.updateIdListId);

    return PrayerItem(
      id: id,
      description: hivePrayer.description,
      timesPrayed: hivePrayer.timesPrayed,
      created: hivePrayer.created,
      lastPrayed: hivePrayer.lastPrayed,
      answered: hivePrayer.answered,
      childCount: hivePrayer.activeChildIds.length,
      updateCount: updateList.length,
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

  Future<AnsweredPrayer?> getAnsweredPrayer(String id) async {
    final hiveAnsweredPrayer = await _hiveBoxes.answeredPrayer.get(id);
    if (hiveAnsweredPrayer == null) {
      return null;
    }
    return AnsweredPrayer(
      prayerItem: await getPrayerItem(hiveAnsweredPrayer.prayerId),
      description: hiveAnsweredPrayer.description,
      time: hiveAnsweredPrayer.answered,
      breadcrumbDescriptions: hiveAnsweredPrayer.breadcrumbDescriptions,
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

  Future<AnsweredPrayerListHelper> getAnsweredPrayerListHelper([
    PrayerItem? prayerItem,
  ]) async {
    var listId = answeredPrayerListId;
    if (prayerItem != null) {
      final hivePrayer = await _hiveBoxes.prayer.get(prayerItem.id);
      if (hivePrayer == null) {
        throw 'Prayer not found';
      }
      // TODO: This isn't actually a list of IDs to HiveAnsweredPrayer but to HivePrayerItem.
      listId = hivePrayer.answeredChildIdListId;
    }
    return AnsweredPrayerListHelper(
        listHelper: await _listManager.getList(listId), dataAccess: this);
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

  Future<void> linkAnsweredChild({
    required PrayerItem parent,
    required PrayerItem child,
  }) async {
    final hivePrayerParent = await _hiveBoxes.prayer.get(parent.id);
    if (hivePrayerParent == null) return;
    final listId = hivePrayerParent.answeredChildIdListId;
    final listHelper = await _listManager.getList(listId);
    await listHelper.insertId(0, child.id);
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

  Future<void> markAnswered(
      PrayerItem prayerItem, DateTime when, List<String> breadcrumbIds) async {
    final answerId = genUuid();
    final hivePrayer = await _hiveBoxes.prayer.get(prayerItem.id);
    if (hivePrayer == null) {
      return;
    }
    final filteredBreadcrumbIds =
        breadcrumbIds.getRange(1, breadcrumbIds.length).toList();
    await Future.wait([
      () async {
        final breadcrumbDescriptions =
            await Future.wait(filteredBreadcrumbIds.map((e) async {
          final ancestor = await getPrayerItem(e);
          if (ancestor == null) {
            return '[UNKNOWN]';
          }
          return ancestor.description;
        }));
        final hiveAnsweredPrayer = HiveAnsweredPrayer(
          prayerId: prayerItem.id,
          description: prayerItem.description,
          time: when,
          breadcrumbIds: filteredBreadcrumbIds,
          breadcrumbDescriptions: breadcrumbDescriptions,
        );
        await _hiveBoxes.answeredPrayer.put(answerId, hiveAnsweredPrayer);
      }(),
      () async {
        hivePrayer.answered = when;
        await _hiveBoxes.prayer.put(prayerItem.id, hivePrayer);
      }(),
      () async {
        final listHelper = await _listManager.getList(answeredPrayerListId);
        await listHelper.insertId(0, answerId);
      }(),
    ]);
  }
}
