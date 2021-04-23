import 'package:prayer_app/data/id_list_helper.dart';
import 'package:prayer_app/data/prayer_data_access.dart';

import 'answered_prayer.dart';

class AnsweredPrayerListHelper {
  final IdListHelper? listHelper;
  final PrayerDataAccess dataAccess;

  AnsweredPrayerListHelper({
    required this.listHelper,
    required this.dataAccess,
  });

  int get length => listHelper == null ? 0 : listHelper!.length;

  Future<AnsweredPrayer?> getAnsweredPrayer(int index) async {
    final id = await listHelper!.getId(index);
    final item = await dataAccess.getAnsweredPrayer(id);
    return item ??
        AnsweredPrayer(
          prayerItem: null,
          time: DateTime.now(),
          description: '[NOT FOUND]',
          breadcrumbDescriptions: [],
        );
  }
}
