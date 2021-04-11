import 'package:flutter/material.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
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
    return FutureBuilder(
        future: _getControllerFuture(context),
        builder: (context, AsyncSnapshot<PrayerContextController> snapshot) {
          if (snapshot.hasData) {
            return ChangeNotifierProvider<PrayerContextController>(
              create: (context) => snapshot.data!,
              child: widget.child,
            );
          } else {
            Widget child;
            if (snapshot.hasError) {
              child = Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ],
              );
            } else {
              child = Column(
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ],
              );
            }
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: child),
            );
          }
        });
  }
}
