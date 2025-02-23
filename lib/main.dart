import 'package:flutter/material.dart';
import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/hive/init.dart';
import 'package:provider/provider.dart';
import 'data/prayer_data_access.dart';
import 'navigation/navigation_controller.dart';
import 'navigation/page_route_information_parser.dart';
import 'navigation/page_router_delegate.dart';

Future<void> main() async {
  await initHive();
  runApp(PrayerApp());
}

class PrayerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrayerAppState();
}

class _PrayerAppState extends State<PrayerApp> {
  final PageRouterDelegate _routerDelegate = PageRouterDelegate();
  final PageRouteInformationParser _routeInformationParser =
      PageRouteInformationParser();
  late Future<PrayerDataAccess> _prayerDataAccessFuture;
  Boxes? _hiveBoxes;

  @override
  void initState() {
    super.initState();
    _prayerDataAccessFuture = (() async {
      final boxes = await openBoxes();
      _hiveBoxes = boxes;
      return PrayerDataAccess(boxes);
    })();
  }

  @override
  void dispose() {
    if (_hiveBoxes != null) {
      _hiveBoxes!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _prayerDataAccessFuture,
      builder: (context, AsyncSnapshot<PrayerDataAccess> snapshot) {
        if (snapshot.hasError) {
          return const Text('Error opening database');
        } else if (snapshot.hasData) {
          return MultiProvider(
            providers: [
              Provider<Boxes>.value(value: _hiveBoxes!),
              Provider<PrayerDataAccess>.value(
                value: snapshot.data!,
              ),
              ChangeNotifierProvider<NavigationController>.value(
                value: _routerDelegate,
              ),
            ],
            child: MaterialApp.router(
              title: 'Prayer App',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              routerDelegate: _routerDelegate,
              routeInformationParser: _routeInformationParser,
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
