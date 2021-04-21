import 'package:flutter/foundation.dart';
import 'package:prayer_app/build_prayer_context.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:prayer_app/prayer_context.dart';
import 'package:prayer_app/utils/uuid.dart';

import 'model/prayer_item.dart';

Future<PrayerContextController> buildPrayerContextController({
  required PrayerDataAccess dataAccess,
  required NavigationController navigation,
  required List<String> breadcrumbs,
}) async {
  final context = await buildPrayerContext(breadcrumbs, dataAccess);
  return PrayerContextController(
    dataAccess: dataAccess,
    navigation: navigation,
    breadcrumbs: breadcrumbs,
    context: context,
  );
}

class PrayerContextController extends ChangeNotifier {
  final PrayerDataAccess _dataAccess;
  final NavigationController navigation;
  final List<String> _breadcrumbs;
  PrayerContext context;

  PrayerContextController({
    required PrayerDataAccess dataAccess,
    required this.navigation,
    required List<String> breadcrumbs,
    required this.context,
  })   : _dataAccess = dataAccess,
        _breadcrumbs = breadcrumbs;

  Future<void> addPrayer(String description) async {
    final prayerItem = PrayerItem(id: genUuid(), description: description);
    await _dataAccess.createPrayerItem(prayerItem);
    await _dataAccess.linkChild(parent: context.current, child: prayerItem);
    await _rebuildContext();
  }

  Future<void> addUpdate(String text) async {
    if (text.isEmpty) {
      return;
    }
    print('addStatus()');
    await _dataAccess.addUpdate(context.current, DateTime.now(), text);
    await _rebuildContext();
  }

  Future<void> markPrayed(PrayerItem prayerItem) async {
    print('markPrayed()');
    await _dataAccess.markPrayed(prayerItem, DateTime.now());
    await _rebuildContext();
  }

  bool isAtRoot() {
    return _breadcrumbs.length == 1;
  }

  Future<void> movePrayer(
      PrayerItem movingPrayer, PrayerItem targetParent) async {
    await Future.wait([
      _dataAccess.unlinkChild(parent: context.current, child: movingPrayer),
      _dataAccess.linkChild(parent: targetParent, child: movingPrayer),
    ]);
    await _rebuildContext();
  }

  Future<void> editPrayer(PrayerItem prayerItem, String description) async {
    await _dataAccess.editPrayerItem(prayerItem, description);
    await _rebuildContext();
  }

  Future<void> removePrayer(PrayerItem prayerItem) async {
    await _dataAccess.unlinkChild(parent: context.current, child: prayerItem);
    await _rebuildContext();
  }

  Future<void> _rebuildContext() async {
    context = await buildPrayerContext(_breadcrumbs, _dataAccess);
    notifyListeners();
  }
}
