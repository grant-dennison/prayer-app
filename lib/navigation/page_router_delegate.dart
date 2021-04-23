import 'package:flutter/material.dart';
import 'package:prayer_app/page/answered_prayer_list_page.dart';
import 'package:prayer_app/page/home_page.dart';
import 'package:prayer_app/page/prayer_item_details_page.dart';
import 'package:prayer_app/page/prayer_item_list_page.dart';

import 'navigation_controller.dart';
import 'page_route_path.dart';
import 'page_spec.dart';
import 'page_type.dart';

class PageRouterDelegate extends RouterDelegate<PageRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageRoutePath>
    implements NavigationController {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final List<PageSpec> _pageStack = [PageSpec.home()];

  PageRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  PageRoutePath get currentConfiguration {
    return PageRoutePath(
      prayerItemIdBreadcrumbs: _getBreadcrumbsAt(_pageStack.length - 1),
      pageType: _pageStack.last.pageType,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('page stack has ${_pageStack.length} elements');
    final pages = <Page>[];
    for (var i = 0; i < _pageStack.length; i++) {
      pages.add(_getPageAt(i));
    }
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        popContext();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PageRoutePath path) async {
    _pageStack.clear();
    _pageStack.add(PageSpec.home());
    for (var i = 0; i < path.prayerItemIdBreadcrumbs.length - 1; i++) {
      _pageStack.add(
        PageSpec(
          pageType: PageType.activeList,
          prayerItemId: path.prayerItemIdBreadcrumbs[i],
        ),
      );
    }
    if (path.prayerItemIdBreadcrumbs.isNotEmpty) {
      _pageStack.add(
        PageSpec(
          pageType: path.pageType,
          prayerItemId: path.prayerItemIdBreadcrumbs.last,
        ),
      );
    }
  }

  @override
  void popContext() {
    print('popContext()');
    if (_pageStack.length == 1) {
      print('not popping because home page would go away');
      return;
    }
    _pageStack.removeLast();
    notifyListeners();
  }

  @override
  void pushContext(PageSpec pageSpec) {
    print('pushContext()');
    _pageStack.add(pageSpec);
    notifyListeners();
  }

  Page _getPageAt(int i) {
    final pageSpec = _pageStack[i];
    final breadcrumbs = _getBreadcrumbsAt(i);
    switch (pageSpec.pageType) {
      case PageType.home:
        print('home page');
        return HomePage();
      case PageType.activeList:
        print('list page');
        return PrayerItemListPage(breadcrumbs: breadcrumbs);
      case PageType.answeredList:
        print('answered page');
        return AnsweredPrayerListPage(breadcrumbs: breadcrumbs);
      case PageType.details:
        return PrayerItemDetailsPage(breadcrumbs: breadcrumbs);
    }
  }

  List<String> _getBreadcrumbsAt(int i) {
    final rawBreadcrumbs =
        _pageStack.getRange(0, i + 1).map((e) => e.prayerItemId).toList();
    var breadcrumbs = <String>[];
    String? last;
    for (final b in rawBreadcrumbs) {
      if (b != null && b != last) {
        breadcrumbs.add(b);
        last = b;
      }
    }
    return breadcrumbs;
  }
}
