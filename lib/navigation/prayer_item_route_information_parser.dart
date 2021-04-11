import 'package:flutter/material.dart';
import 'package:prayer_app/navigation/prayer_item_route_path.dart';

const _prayerSegment = 'prayer';
const _detailsSegment = 'details';
const _listSegment = 'list';

class PrayerItemRouteInformationParser
    extends RouteInformationParser<PrayerItemRoutePath> {
  @override
  Future<PrayerItemRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');

    // Handle '/prayer/:id1/.../:idN/details'
    if (uri.pathSegments.length > 2) {
      if (uri.pathSegments[0] != _prayerSegment) {
        return PrayerItemRoutePath.home();
      }
      final remaining =
          uri.pathSegments.getRange(1, uri.pathSegments.length).toList();
      final last = remaining.removeLast();
      return PrayerItemRoutePath(
        prayerItemIdBreadcrumbs: remaining,
        isDetails: last == _detailsSegment,
      );
    }

    return PrayerItemRoutePath.home();
  }

  @override
  RouteInformation restoreRouteInformation(PrayerItemRoutePath path) {
    if (path.prayerItemIdBreadcrumbs.isEmpty) {
      return const RouteInformation(location: '/');
    }
    return RouteInformation(
      location: [
        _prayerSegment,
        ...path.prayerItemIdBreadcrumbs,
        if (path.isDetails) _detailsSegment else _listSegment
      ].join('/'),
    );
  }
}
