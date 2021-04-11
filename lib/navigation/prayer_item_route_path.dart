class PrayerItemRoutePath {
  final List<String> prayerItemIdBreadcrumbs;
  final bool isDetails;

  PrayerItemRoutePath({
    required this.prayerItemIdBreadcrumbs,
    required this.isDetails,
  });

  PrayerItemRoutePath.home()
      : prayerItemIdBreadcrumbs = [],
        isDetails = false;
}
