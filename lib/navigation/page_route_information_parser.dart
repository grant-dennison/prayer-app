import 'package:flutter/material.dart';
import 'package:prayer_app/navigation/page_route_path.dart';
import 'package:prayer_app/navigation/page_type.dart';

const _prayerSegment = 'prayer';
const _answersSegment = 'answers';
const _detailsSegment = 'details';
const _listSegment = 'list';

class PageRouteInformationParser extends RouteInformationParser<PageRoutePath> {
  @override
  Future<PageRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');

    // Handle '/prayer/:id1/.../:idN/details'
    if (uri.pathSegments.length > 2) {
      if (uri.pathSegments[0] != _prayerSegment) {
        return PageRoutePath.home();
      }
      final remaining =
          uri.pathSegments.getRange(1, uri.pathSegments.length).toList();
      final last = remaining.removeLast();
      PageType pageType;
      switch (last) {
        case _answersSegment:
          pageType = PageType.answeredList;
          break;
        case _detailsSegment:
          pageType = PageType.details;
          break;
        case _listSegment:
          pageType = PageType.activeList;
          break;
        default:
          pageType = PageType.details;
      }
      return PageRoutePath(
        prayerItemIdBreadcrumbs: remaining,
        pageType: pageType,
      );
    }

    return PageRoutePath.home();
  }

  @override
  RouteInformation restoreRouteInformation(PageRoutePath path) {
    if (path.pageType == PageType.home) {
      return const RouteInformation(location: '/');
    }

    if (path.prayerItemIdBreadcrumbs.isEmpty) {
      switch (path.pageType) {
        case PageType.answeredList:
          return RouteInformation(
            location: [
              _prayerSegment,
              _answersSegment,
            ].join('/'),
          );
        case PageType.home:
        default:
          return const RouteInformation(location: '/');
      }
    }

    String trailingSegment;
    switch (path.pageType) {
      case PageType.activeList:
        trailingSegment = _listSegment;
        break;
      case PageType.answeredList:
        trailingSegment = _answersSegment;
        break;
      case PageType.details:
      default:
        trailingSegment = _detailsSegment;
        break;
    }
    return RouteInformation(
      location: [
        _prayerSegment,
        ...path.prayerItemIdBreadcrumbs,
        trailingSegment,
      ].join('/'),
    );
  }
}
