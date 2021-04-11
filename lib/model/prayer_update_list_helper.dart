import 'package:prayer_app/data/id_list_helper.dart';
import 'package:prayer_app/data/prayer_data_access.dart';

import 'prayer_update.dart';

class PrayerUpdateListHelper {
  final IdListHelper? listHelper;
  final PrayerDataAccess dataAccess;

  PrayerUpdateListHelper({
    required this.listHelper,
    required this.dataAccess,
  });

  int get length => listHelper == null ? 0 : listHelper!.length;

  Future<PrayerUpdate> getUpdate(int index) async {
    final id = await listHelper!.getId(index);
    final item = await dataAccess.getPrayerUpdate(id);
    return item ??
        PrayerUpdate(id: id, time: DateTime.now(), text: '[NOT FOUND]');
  }
}
