import 'dart:collection';

import 'model/prayer_item.dart';
import 'model/prayer_update.dart';

class PrayerContext {
  final List<String> breadcrumbs;
  final PrayerItem current;
  final List<PrayerItem> children;
  final List<PrayerUpdate> updates;

  const PrayerContext({
    required this.breadcrumbs,
    required this.current,
    required this.children,
    required this.updates,
  });
}
