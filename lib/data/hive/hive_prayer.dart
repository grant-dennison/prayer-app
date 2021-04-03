import 'package:hive/hive.dart';

part 'hive_prayer.g.dart';

@HiveType(typeId: 1)
class HivePrayer extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  DateTime created = DateTime.now();

  HivePrayer({this.description = ''});
}

const boxIdPrayer = 'prayer';
