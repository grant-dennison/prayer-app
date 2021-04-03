import 'package:prayer_app/data/generate_fake_data.dart';
import 'package:prayer_app/data/in_memory_data_store.dart';
import 'package:uuid/uuid.dart';

import '../model/prayer_checkin.dart';
import '../model/prayer_item.dart';
import '../model/prayer_item_stats.dart';
import '../model/prayer_update.dart';
import 'item_link.dart';

class PrayerDataAccess {
  final InMemoryDataStore _store = generateFakeData();

  PrayerItem getRoot() {
    return rootPrayerItem;
  }

  PrayerItem getPrayerItem(String id) {
    return _store.prayerItems.firstWhere((e) => e.id == id);
  }

  List<PrayerItem> getChildren(PrayerItem prayerItem) {
    return _store.prayerPrayerLinks
        .where((link) => link.parentId == prayerItem.id)
        .map((link) =>
            _store.prayerItems.firstWhere((item) => link.childId == item.id))
        .toList();
  }

  List<PrayerUpdate> getUpdates(PrayerItem prayerItem) {
    return _store.prayerUpdateLinks
        .where((link) => link.parentId == prayerItem.id)
        .map((link) =>
            _store.prayerUpdates.firstWhere((item) => link.childId == item.id))
        .toList();
  }

  PrayerItemStats getStats(PrayerItem prayerItem) {
    return PrayerItemStats(
      numberPrayed: 3,
      firstPrayedTime: DateTime.utc(1989, 11, 9),
      lastPrayedTime: DateTime.now(),
    );
  }

  void createPrayerItem(PrayerItem prayerItem) {
    _store.prayerItems.add(prayerItem);
  }

  void linkChild({
    required PrayerItem parent,
    required PrayerItem child,
  }) {
    _store.prayerPrayerLinks
        .add(ItemLink(parentId: parent.id, childId: child.id));
  }

  void unlinkChild({
    required PrayerItem parent,
    required PrayerItem child,
  }) {
    _store.prayerPrayerLinks.removeWhere(
        (link) => link.parentId == parent.id && link.childId == child.id);
  }

  void markPrayed(PrayerItem prayerItem, DateTime when) {
    _store.prayerCheckins
        .add(PrayerCheckin(prayerItemId: prayerItem.id, time: when));
    _store.prayerItems.remove(prayerItem);
    _store.prayerItems.add(PrayerItem(
      id: prayerItem.id,
      description: prayerItem.description,
      lastPrayed: when,
    ));
  }

  void addUpdate(PrayerItem prayerItem, DateTime when, String text) {
    final status = PrayerUpdate(id: Uuid().v4(), time: when, text: text);
    _store.prayerUpdates.add(status);
    _store.prayerUpdateLinks
        .add(ItemLink(parentId: prayerItem.id, childId: status.id));
  }
}
