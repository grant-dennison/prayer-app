import 'package:flutter/material.dart';
import 'package:prayer_app/model/prayer_item.dart';
import 'package:prayer_app/page/home_page.dart';
import 'package:prayer_app/page/prayer_item_details_page.dart';
import 'package:prayer_app/page/prayer_item_list_page.dart';

import 'navigation_controller.dart';
import 'prayer_item_route_path.dart';

class PrayerItemRouterDelegate extends RouterDelegate<PrayerItemRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PrayerItemRoutePath>
    implements NavigationController {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  List<String> _prayerItemIdBreadcrumbs = [];
  bool _isDetailsPage = false;

  PrayerItemRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  PrayerItemRoutePath get currentConfiguration {
    return PrayerItemRoutePath(
      prayerItemIdBreadcrumbs: _prayerItemIdBreadcrumbs,
      isDetails: _isDetailsPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final breadcrumbss = <List<String>>[];
    for (var i = 0; i < _prayerItemIdBreadcrumbs.length; i++) {
      breadcrumbss.add(_prayerItemIdBreadcrumbs.getRange(0, i + 1).toList());
    }
    return Navigator(
      key: navigatorKey,
      pages: [
        HomePage(),
        ...breadcrumbss.map((e) => PrayerItemListPage(breadcrumbs: e)),
        if (breadcrumbss.isNotEmpty && _isDetailsPage)
          PrayerItemDetailsPage(breadcrumbs: _prayerItemIdBreadcrumbs)
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_isDetailsPage) {
          toggleDetails(show: false);
        } else {
          popContext();
        }

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PrayerItemRoutePath path) async {
    _prayerItemIdBreadcrumbs = List.from(path.prayerItemIdBreadcrumbs);
    _isDetailsPage = path.isDetails;
  }

  @override
  void toggleDetails({bool? show}) {
    if (show == null) {
      _isDetailsPage = !_isDetailsPage;
    } else {
      _isDetailsPage = show;
    }
    notifyListeners();
  }

  @override
  void popContext() {
    _prayerItemIdBreadcrumbs.removeLast();
    notifyListeners();
  }

  @override
  void pushContext(PrayerItem targetPrayerItem) {
    _prayerItemIdBreadcrumbs.add(targetPrayerItem.id);
    notifyListeners();
  }
}
