import 'package:flutter/foundation.dart';
import 'package:prayer_app/build_prayer_context.dart';
import 'package:prayer_app/prayer_context.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:uuid/uuid.dart';

import 'model/prayer_item.dart';

class PrayerContextController extends ChangeNotifier {
  final PrayerDataAccess dataAccess;
  PrayerContext context;

  PrayerContextController(this.dataAccess)
      : context = buildPrayerContext([], dataAccess, dataAccess.getRoot());

  void addPrayer(String description) {
    final prayerItem = PrayerItem(id: Uuid().v4(), description: description);
    dataAccess.createPrayerItem(prayerItem);
    dataAccess.linkChild(parent: context.current, child: prayerItem);
    _rebuildContext();
  }

  void addUpdate(PrayerItem prayerItem, String text) {
    print('addStatus()');
    dataAccess.addUpdate(prayerItem, DateTime.now(), text);
    _rebuildContext();
  }

  void markPrayed(PrayerItem prayerItem) {
    print('markPrayed()');
    dataAccess.markPrayed(prayerItem, DateTime.now());
    _rebuildContext();
  }

  bool isAtRoot() {
    return context.breadcrumbs.length == 0;
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
    notifyListeners();
  }
}
