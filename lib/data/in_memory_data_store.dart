import '../model/prayer_checkin.dart';
import '../model/prayer_item.dart';
import '../model/prayer_update.dart';
import 'item_link.dart';

class InMemoryDataStore {
  final PrayerItem rootPrayerItem =
      PrayerItem(id: 'root', description: 'Everything');
  final List<PrayerItem> prayerItems = [];
  final List<ItemLink> prayerPrayerLinks = [];
  final List<PrayerUpdate> prayerUpdates = [];
  final List<ItemLink> prayerUpdateLinks = [];
  final List<PrayerCheckin> prayerCheckins = [];
}
