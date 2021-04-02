import 'package:prayer_app/model/prayer_item.dart';
import 'package:prayer_app/prayer_context.dart';
import 'package:prayer_app/data/prayer_data_access.dart';

PrayerContext buildPrayerContext(
  List<PrayerItem> breadcrumbs,
  PrayerDataAccess dataAccess,
  PrayerItem prayerItem,
) {
  final children = dataAccess.getChildren(prayerItem);
  final updates = dataAccess.getUpdates(prayerItem);
  return PrayerContext(
    breadcrumbs: breadcrumbs,
    current: prayerItem,
    children: children,
    updates: updates,
  );
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
}
