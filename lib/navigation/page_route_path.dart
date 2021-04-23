import 'package:prayer_app/navigation/page_type.dart';

class PageRoutePath {
  final List<String> prayerItemIdBreadcrumbs;
  final PageType pageType;

  PageRoutePath({
    required this.prayerItemIdBreadcrumbs,
    required this.pageType,
  });

  PageRoutePath.home()
      : prayerItemIdBreadcrumbs = [],
        pageType = PageType.home;
}
