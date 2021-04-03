import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/prayer_data_access.dart';
import 'navigation/navigation_controller.dart';
import 'navigation/prayer_item_route_information_parser.dart';
import 'navigation/prayer_item_router_delegate.dart';

void main() {
  runApp(PrayerApp());
}

class PrayerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrayerAppState();
}

class _PrayerAppState extends State<PrayerApp> {
  final PrayerItemRouterDelegate _routerDelegate = PrayerItemRouterDelegate();
  final PrayerItemRouteInformationParser _routeInformationParser =
      PrayerItemRouteInformationParser();
  late PrayerDataAccess _prayerDataAccess;

  @override
  void initState() {
    super.initState();
    _prayerDataAccess = PrayerDataAccess();
  }

  @override
  void dispose() {
    // TODO: _prayerDataAccess.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<PrayerDataAccess>.value(
      value: _prayerDataAccess,
      child: ChangeNotifierProvider<NavigationController>.value(
        value: _routerDelegate,
        child: MaterialApp.router(
          title: 'Prayer App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeInformationParser,
        ),
      ),
    );
  }
}
