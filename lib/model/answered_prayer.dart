import 'prayer_item.dart';

class AnsweredPrayer {
  final PrayerItem? prayerItem;
  final String description;
  final DateTime time;
  final List<String> breadcrumbDescriptions;

  const AnsweredPrayer({
    required this.prayerItem,
    required this.description,
    required this.time,
    required this.breadcrumbDescriptions,
  });
}
