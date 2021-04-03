import '../model/prayer_item.dart';

// enum PageCategory {
//   home,
//   prayer,
// }

// enum PrayerPageType {
//   list,
//   updates,
// }

class PrayerItemRoutePath {
  final List<String> prayerItemIdBreadcrumbs;
  // final PageCategory pageCategory;
  // final PrayerPageType prayerPageType;
  final bool isDetails;

  PrayerItemRoutePath({
    required this.prayerItemIdBreadcrumbs,
    // required this.pageCategory,
    // required this.prayerPageType,
    required this.isDetails,
  });

  PrayerItemRoutePath.home()
      : prayerItemIdBreadcrumbs = [],
        isDetails = false;

  // BookRoutePath.details(this.id) : isUnknown = false;

  // BookRoutePath.unknown()
  //     : id = null,
  //       isUnknown = true;
}
