import 'package:flutter/foundation.dart';
import 'package:prayer_app/build_prayer_context.dart';
import 'package:prayer_app/prayer_context.dart';
import 'package:prayer_app/data/prayer_data_access.dart';

import 'model/prayer_item.dart';

class PrayerContextController extends ChangeNotifier {
  final PrayerDataAccess dataAccess;
  PrayerContext context;

  PrayerContextController(this.dataAccess)
      : context = buildPrayerContext([], dataAccess, dataAccess.getRoot());

  void addUpdate(PrayerItem prayerItem, String text) {
    print('addStatus()');
    dataAccess.addUpdate(prayerItem, DateTime.now(), text);
    _rebuildContext();
    notifyListeners();
  }

  void markPrayed(PrayerItem prayerItem) {
    print('markPrayed()');
    dataAccess.markPrayed(prayerItem, DateTime.now());
    _rebuildContext();
    notifyListeners();
  }

  void popContext() {
    print('popContext()');
    final newBreadcrumbs = context.breadcrumbs;
    final parent = newBreadcrumbs.removeLast();
    context = buildPrayerContext(newBreadcrumbs, dataAccess, parent);
    notifyListeners();
  }

  void pushContext(PrayerItem targetPrayerItem) {
    print('pushContext()');
    final newBreadcrumbs = context.breadcrumbs;
    newBreadcrumbs.add(context.current);
    context = buildPrayerContext(newBreadcrumbs, dataAccess, targetPrayerItem);
    notifyListeners();
  }

  void _rebuildContext() {
    context =
        buildPrayerContext(context.breadcrumbs, dataAccess, context.current);
  }
}
