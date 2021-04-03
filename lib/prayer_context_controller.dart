import 'package:flutter/foundation.dart';
import 'package:prayer_app/build_prayer_context.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:prayer_app/prayer_context.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:uuid/uuid.dart';

import 'model/prayer_item.dart';

class PrayerContextController extends ChangeNotifier {
  final PrayerDataAccess _dataAccess;
  final NavigationController navigation;
  final List<String> _breadcrumbs;
  PrayerContext context;

  PrayerContextController({
    required PrayerDataAccess dataAccess,
    required this.navigation,
    required List<String> breadcrumbs,
  })   : _dataAccess = dataAccess,
        _breadcrumbs = breadcrumbs,
        context = buildPrayerContext(breadcrumbs, dataAccess);

  void addPrayer(String description) {
    final prayerItem = PrayerItem(id: Uuid().v4(), description: description);
    _dataAccess.createPrayerItem(prayerItem);
    _dataAccess.linkChild(parent: context.current, child: prayerItem);
    _rebuildContext();
  }

  void addUpdate(String text) {
    if (text.isEmpty) {
      return;
    }
    print('addStatus()');
    _dataAccess.addUpdate(context.current, DateTime.now(), text);
    _rebuildContext();
  }

  void markPrayed(PrayerItem prayerItem) {
    print('markPrayed()');
    _dataAccess.markPrayed(prayerItem, DateTime.now());
    _rebuildContext();
  }

  bool isAtRoot() {
    return _breadcrumbs.length == 1;
  }

  void _rebuildContext() {
    context = buildPrayerContext(_breadcrumbs, _dataAccess);
    notifyListeners();
  }
}
