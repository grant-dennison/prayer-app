import 'page_type.dart';

class PageSpec {
  final PageType pageType;
  final String? prayerItemId;

  const PageSpec({
    required this.pageType,
    required this.prayerItemId,
  });

  const PageSpec.home()
      : pageType = PageType.home,
        prayerItemId = null;

  const PageSpec.list({required this.prayerItemId})
      : pageType = PageType.activeList;

  const PageSpec.details({required this.prayerItemId})
      : pageType = PageType.details;
}
