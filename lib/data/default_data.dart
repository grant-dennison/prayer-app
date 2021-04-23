import 'package:prayer_app/data/answered_prayer_list.dart';
import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/id_list_manager.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/model/prayer_item.dart';

import 'hive/hive_prayer.dart';

Future<void> ensureDefaultData() async {
  final b = await openBoxes();
  final listManager = IdListManager(listBox: b.idList, chunkBox: b.idListChunk);
  if (!b.prayer.containsKey(rootPrayerItemId)) {
    final rootPrayerItem = PrayerItem(
      id: rootPrayerItemId,
      description: 'Everything',
      created: DateTime.now(),
    );
    await b.prayer.put(
        rootPrayerItem.id,
        HivePrayer(
          description: rootPrayerItem.description,
          updateIdListId: await listManager.createList(),
          answeredChildIdListId: await listManager.createList(),
        ));
  }
  if (!listManager.listExists(answeredPrayerListId)) {
    await listManager.createList(answeredPrayerListId);
  }
  await b.dispose();
}
