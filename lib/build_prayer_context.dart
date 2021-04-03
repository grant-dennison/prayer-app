import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/prayer_context.dart';

PrayerContext buildPrayerContext(
  List<String> breadcrumbs,
  PrayerDataAccess dataAccess,
) {
  final prayerItem = dataAccess.getPrayerItem(breadcrumbs.last);
  final children = dataAccess.getChildren(prayerItem);
  final updates = dataAccess.getUpdates(prayerItem);
  return PrayerContext(
    breadcrumbs: breadcrumbs,
    current: prayerItem,
    children: children,
    updates: updates,
  );
}
