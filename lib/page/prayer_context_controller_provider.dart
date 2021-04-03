import 'package:flutter/material.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:provider/provider.dart';

import '../prayer_context_controller.dart';

class PrayerContextControllerProvider extends StatelessWidget {
  final List<String> breadcrumbs;
  final Widget child;

  PrayerContextControllerProvider({
    required this.breadcrumbs,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final dataAccess = Provider.of<PrayerDataAccess>(context);
    return Consumer<NavigationController>(
        builder: (context, navigationController, child) =>
            ChangeNotifierProvider<PrayerContextController>(
              create: (context) => PrayerContextController(
                dataAccess: dataAccess,
                navigation: navigationController,
                breadcrumbs: breadcrumbs,
              ),
              child: child,
            ),
        child: child);
  }
}
