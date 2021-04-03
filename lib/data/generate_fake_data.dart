import 'package:prayer_app/data/item_link.dart';

import 'in_memory_data_store.dart';
import '../model/prayer_item.dart';

InMemoryDataStore generateFakeData() {
  final store = InMemoryDataStore();

  // return PrayerContext(
  //   breadcrumbs: [],
  //   current: PrayerItem(id: '1', description: 'pray for one'),
  //   children: [
  //     PrayerItem(id: '10', description: 'pray for 10'),
  //     PrayerItem(id: '11', description: 'pray for 11'),
  //     PrayerItem(id: '12', description: 'pray for 12'),
  //     PrayerItem(id: '13', description: 'pray for 13'),
  //   ],
  //   updates: [],
  // );

  final topChildren = [
    PrayerItem(id: '10', description: 'pray for 10'),
    PrayerItem(id: '11', description: 'pray for 11'),
    PrayerItem(id: '12', description: 'pray for 12'),
    PrayerItem(id: '13', description: 'pray for 13'),
  ];

  for (final child in topChildren) {
    store.prayerItems.add(child);
    store.prayerPrayerLinks
        .add(ItemLink(parentId: rootPrayerItem.id, childId: child.id));
  }

  return store;
}
