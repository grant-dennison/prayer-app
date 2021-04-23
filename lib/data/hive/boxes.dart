import 'package:hive/hive.dart';
import 'package:prayer_app/data/hive/hive_answered_prayer.dart';
import 'package:prayer_app/data/hive/hive_id_list.dart';
import 'package:prayer_app/data/hive/hive_id_list_chunk.dart';

import 'hive_prayer.dart';
import 'hive_prayer_update.dart';

Future<Boxes> openBoxes() async {
  final idList = await Hive.openLazyBox<HiveIdList>(boxIdIdList);
  final idListChunk = await Hive.openLazyBox<HiveIdListChunk>(boxIdIdListChunk);
  final prayer = await Hive.openLazyBox<HivePrayer>(boxIdPrayer);
  final prayerUpdate =
      await Hive.openLazyBox<HivePrayerUpdate>(boxIdPrayerUpdate);
  final answeredPrayer =
      await Hive.openLazyBox<HiveAnsweredPrayer>(boxIdAnsweredPrayer);
  return Boxes(
    idList: idList,
    idListChunk: idListChunk,
    prayer: prayer,
    prayerUpdate: prayerUpdate,
    answeredPrayer: answeredPrayer,
  );
}

class Boxes {
  final LazyBox<HiveIdList> idList;
  final LazyBox<HiveIdListChunk> idListChunk;
  final LazyBox<HivePrayer> prayer;
  final LazyBox<HivePrayerUpdate> prayerUpdate;
  final LazyBox<HiveAnsweredPrayer> answeredPrayer;

  Boxes({
    required this.idList,
    required this.prayer,
    required this.idListChunk,
    required this.prayerUpdate,
    required this.answeredPrayer,
  });

  Future<void> dispose() async {
    await Future.wait([
      idList.close(),
      idListChunk.close(),
      prayer.close(),
      prayerUpdate.close(),
    ]);
  }
}
