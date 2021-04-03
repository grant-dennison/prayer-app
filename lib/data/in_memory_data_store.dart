import '../model/prayer_checkin.dart';
import '../model/prayer_item.dart';
import '../model/prayer_update.dart';
import 'item_link.dart';

const rootPrayerItem = PrayerItem(id: 'root', description: 'Everything');

class InMemoryDataStore {
  final List<PrayerItem> prayerItems = [rootPrayerItem];
  final List<ItemLink> prayerPrayerLinks = [];
  final List<PrayerUpdate> prayerUpdates = [];
  final List<ItemLink> prayerUpdateLinks = [];
  final List<PrayerCheckin> prayerCheckins = [];
}
