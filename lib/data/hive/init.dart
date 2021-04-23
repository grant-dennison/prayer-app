import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_app/data/default_data.dart';
import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/hive/hive_answered_prayer.dart';
import 'package:prayer_app/data/hive/hive_id_list.dart';
import 'package:prayer_app/data/id_list_manager.dart';
import 'package:prayer_app/data/root_prayer_item.dart';

import 'hive_id_list_chunk.dart';
import 'hive_prayer.dart';
import 'hive_prayer_update.dart';

const _v1 = 'v1';

Future<void> initHive() async {
  await Hive.initFlutter(_v1);
  Hive.registerAdapter(HiveAnsweredPrayerAdapter());
  Hive.registerAdapter(HiveIdListAdapter());
  Hive.registerAdapter(HiveIdListChunkAdapter());
  Hive.registerAdapter(HivePrayerAdapter());
  Hive.registerAdapter(HivePrayerUpdateAdapter());

  await ensureDefaultData();
}
