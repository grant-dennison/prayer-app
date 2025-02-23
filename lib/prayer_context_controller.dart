import 'package:flutter/foundation.dart';
import 'package:prayer_app/build_prayer_context.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/model/prayer_update.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:prayer_app/page/prayer_item_details_page.dart';
import 'package:prayer_app/prayer_context.dart';
import 'package:prayer_app/utils/uuid.dart';

import 'model/prayer_item.dart';

Future<PrayerContextController> buildPrayerContextController({
  required PrayerDataAccess dataAccess,
  required NavigationController navigation,
  required List<String> breadcrumbs,
}) async {
  final context = await buildPrayerContext(breadcrumbs, dataAccess);
  final controller = PrayerContextController(
    dataAccess: dataAccess,
    navigation: navigation,
    breadcrumbs: breadcrumbs,
    context: context,
  );
  await controller.cleanUpChildren();
  return controller;
}

class PrayerContextController extends ChangeNotifier {
  final PrayerDataAccess dataAccess;
  final NavigationController navigation;
  final List<String> _breadcrumbs;
  PrayerContext context;

  PrayerContextController({
    required this.dataAccess,
    required this.navigation,
    required List<String> breadcrumbs,
    required this.context,
  }) : _breadcrumbs = breadcrumbs;

  Future<void> addPrayer(String description) async {
    final prayerItem = PrayerItem(
      id: genUuid(),
      description: description,
      created: DateTime.now(),
    );
    await dataAccess.createPrayerItem(prayerItem);
    await dataAccess.linkChild(parent: context.current, child: prayerItem);
    await _rebuildContext();
  }

  Future<void> addUpdate(String text) async {
    if (text.isEmpty) {
      return;
    }
    await dataAccess.addUpdate(context.current, DateTime.now(), text);
    await _rebuildContext();
  }

  Future<void> markPrayed(PrayerItem prayerItem) async {
    await dataAccess.markPrayed(prayerItem, DateTime.now());
    await _rebuildContext();
  }

  Future<void> markAnswered(PrayerItem prayerItem) async {
    await dataAccess.markAnswered(
        prayerItem, DateTime.now(), context.breadcrumbs);
    await _rebuildContext();
    await cleanUpChildren();
  }

  bool isAtRoot() {
    return _breadcrumbs.length == 1;
  }

  Future<void> movePrayer(
      PrayerItem movingPrayer, PrayerItem targetParent) async {
    await Future.wait([
      dataAccess.unlinkChild(parent: context.current, child: movingPrayer),
      dataAccess.linkChild(parent: targetParent, child: movingPrayer),
    ]);
    await _rebuildContext();
  }

  Future<void> forkPrayer(
      PrayerItem movingPrayer, PrayerItem targetParent) async {
    await Future.wait([
      dataAccess.linkChild(parent: targetParent, child: movingPrayer),
    ]);
    await _rebuildContext();
  }

  Future<void> editPrayer(PrayerItem prayerItem, String description) async {
    await dataAccess.editPrayerItem(prayerItem, description);
    await _rebuildContext();
  }

  Future<void> editUpdate(PrayerUpdate update, String newText) async {
    await dataAccess.editPrayerUpdate(update, newText);
    await _rebuildContext();
  }

  Future<void> removePrayer(PrayerItem prayerItem) async {
    await dataAccess.unlinkChild(parent: context.current, child: prayerItem);
    await _rebuildContext();
  }

  Future<void> cleanUpChildren() async {
    // TODO: Also clean up missing children. Right now they are silently left out.
    final answeredChildren = <PrayerItem>[];
    for (final child in context.children) {
      if (child.answered != null) {
        answeredChildren.add(child);
      }
    }
    if (answeredChildren.isNotEmpty) {
      answeredChildren.sort((a, b) => a.answered!.compareTo(b.answered!));
      for (final child in answeredChildren) {
        await dataAccess.unlinkChild(parent: context.current, child: child);
        await dataAccess.linkAnsweredChild(
            parent: context.current, child: child);
      }
      await _rebuildContext();
    }
  }

  Future<void> _rebuildContext() async {
    context = await buildPrayerContext(_breadcrumbs, dataAccess);
    notifyListeners();
  }
}
