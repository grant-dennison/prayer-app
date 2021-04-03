import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/prayer_context.dart';

Future<PrayerContext> buildPrayerContext(
  List<String> breadcrumbs,
  PrayerDataAccess dataAccess,
) async {
  final prayerItem = await dataAccess.getPrayerItem(breadcrumbs.last);
  if (prayerItem == null) {
    throw ('Prayer item not found');
  }
  final children = await dataAccess.getChildren(prayerItem);
  final updates = await dataAccess.getUpdates(prayerItem);
  return PrayerContext(
    breadcrumbs: breadcrumbs,
    current: prayerItem,
    children: children,
    updates: updates,
  );
}
