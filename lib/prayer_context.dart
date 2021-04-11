import 'package:prayer_app/model/prayer_update_list_helper.dart';

import 'model/prayer_item.dart';

class PrayerContext {
  final List<String> breadcrumbs;
  final PrayerItem current;
  final List<PrayerItem> children;
  final PrayerUpdateListHelper updates;

  const PrayerContext({
    required this.breadcrumbs,
    required this.current,
    required this.children,
    required this.updates,
  });
}
