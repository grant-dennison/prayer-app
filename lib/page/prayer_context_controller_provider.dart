import 'package:flutter/material.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:prayer_app/page/full_page_future_builder.dart';
import 'package:provider/provider.dart';

import '../prayer_context_controller.dart';

class PrayerContextControllerProvider extends StatefulWidget {
  final List<String> breadcrumbs;
  final Widget child;

  const PrayerContextControllerProvider({
    required this.breadcrumbs,
    required this.child,
  });

  @override
  _PrayerContextControllerProviderState createState() =>
      _PrayerContextControllerProviderState();
}

class _PrayerContextControllerProviderState
    extends State<PrayerContextControllerProvider> {
  Future<PrayerContextController>? prayerContextControllerFuture;
  PrayerDataAccess? lastDataAccess;
  NavigationController? lastNavigationController;

  Future<PrayerContextController> _getControllerFuture(BuildContext context) {
    final dataAccess = Provider.of<PrayerDataAccess>(context);
    final navigationController = Provider.of<NavigationController>(context);
    var controllerFuture = prayerContextControllerFuture;
    if (dataAccess != lastDataAccess ||
        navigationController != lastNavigationController ||
        controllerFuture == null) {
      // TODO: This isn't properly rebuilt on pop context.
      controllerFuture = buildPrayerContextController(
        dataAccess: dataAccess,
        navigation: navigationController,
        breadcrumbs: widget.breadcrumbs,
      );
    }
    lastDataAccess = dataAccess;
    lastNavigationController = navigationController;
    prayerContextControllerFuture = controllerFuture;
    return controllerFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FullPageFutureBuilder<PrayerContextController>(
      future: _getControllerFuture(context),
      readyBuilder: (context, data) =>
          ChangeNotifierProvider<PrayerContextController>(
        create: (context) => data,
        child: widget.child,
      ),
    );
  }
}
