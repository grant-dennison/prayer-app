import 'package:flutter/material.dart';

class PrayerItemDetailsPage extends Page {
  final List<String> breadcrumbs;

  PrayerItemDetailsPage({
    required this.breadcrumbs,
  }) : super(key: ValueKey(breadcrumbs.join('/') + '/details-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return PrayerItemDetailsScreen(
          breadcrumbs: breadcrumbs,
        );
      },
    );
  }
}

class PrayerItemDetailsScreen extends StatelessWidget {
  final List<String> breadcrumbs;

  PrayerItemDetailsScreen({
    required this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('here is the details page'),
    );
  }
}
