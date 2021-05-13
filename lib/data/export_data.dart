import 'dart:convert';

import 'package:date_time_format/date_time_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prayer_app/data/default_data.dart';
import 'package:prayer_app/data/hive/hive_answered_prayer.dart';
import 'package:prayer_app/data/hive/hive_id_list.dart';
import 'package:prayer_app/data/hive/hive_id_list_chunk.dart';
import 'package:prayer_app/data/hive/hive_prayer.dart';
import 'package:prayer_app/data/hive/hive_prayer_update.dart';

import 'hive/boxes.dart';

typedef PartialOutputProcessor = Future<void> Function(int index, String json);

Future<void> exportDataToFiles(Boxes boxes) async {
  final hasPermissions = await Permission.storage.request().isGranted;
  if (!hasPermissions) {
    return;
  }

  final timeString = DateTimeFormat.format(DateTime.now(),
      format: DateTimeFormats.xmlrpcCompact);
  final baseFileName = 'prayer-export-$timeString';
  await exportData(boxes, (index, jsonStr) async {
    await FileSaver.instance.saveFile(
        '$baseFileName-$index.v1', Utf8Encoder().convert(jsonStr), 'json');
  });
}

Future<void> importDataFromFiles(Boxes boxes) async {
  final hasPermissions = await Permission.storage.request().isGranted;
  if (!hasPermissions) {
    return;
  }

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowMultiple: true,
    allowedExtensions: ['json'],
    withData: true,
  );
  if (result != null) {
    await Future.wait([
      boxes.prayer.deleteAll(boxes.prayer.keys),
      boxes.prayerUpdate.deleteAll(boxes.prayerUpdate.keys),
      boxes.answeredPrayer.deleteAll(boxes.answeredPrayer.keys),
      boxes.idList.deleteAll(boxes.idList.keys),
      boxes.idListChunk.deleteAll(boxes.idListChunk.keys),
    ]);

    final futures = <Future>[];
    final byteDecoder = Utf8Decoder();
    final jsonDecoder = JsonDecoder();
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) {
        print('File ${file.name} unexpected empty bytes');
        continue;
      }
      final contents = byteDecoder.convert(bytes);
      // print('Contents are:');
      // print(contents);
      final json = jsonDecoder.convert(contents);
      futures.add(importData(boxes, json));
    }
    await Future.wait(futures);
    await ensureDefaultData(boxes);
  }
}

const _exportPrayerKey = 'prayer';
const _exportUpdateKey = 'update';
const _exportAnswerKey = 'answer';
const _exportIdList = 'idList';
const _exportIdListChunk = 'idListChunk';

Future<void> exportData(
    Boxes boxes, PartialOutputProcessor processPartialOutput) async {
  final builder = _Builder(processPartialOutput);

  final prayerBox = boxes.prayer;
  for (final key in prayerBox.keys) {
    final hivePrayer = await prayerBox.get(key);
    if (hivePrayer == null) continue;
    builder.addIdItem(_exportPrayerKey, key, hivePrayer.toJson());
  }

  final updateBox = boxes.prayerUpdate;
  for (final key in updateBox.keys) {
    final hiveUpdate = await updateBox.get(key);
    if (hiveUpdate == null) continue;
    builder.addIdItem(_exportUpdateKey, key, hiveUpdate.toJson());
  }

  final answerBox = boxes.answeredPrayer;
  for (final key in answerBox.keys) {
    final hiveAnswer = await answerBox.get(key);
    if (hiveAnswer == null) continue;
    builder.addIdItem(_exportAnswerKey, key, hiveAnswer.toJson());
  }

  final idListBox = boxes.idList;
  for (final key in idListBox.keys) {
    final hiveIdList = await idListBox.get(key);
    if (hiveIdList == null) continue;
    builder.addIdItem(_exportIdList, key, hiveIdList.toJson());
  }

  final idListChunkBox = boxes.idListChunk;
  for (final key in idListChunkBox.keys) {
    final hiveIdListChunk = await idListChunkBox.get(key);
    if (hiveIdListChunk == null) continue;
    builder.addIdItem(_exportIdListChunk, key, hiveIdListChunk.toJson());
  }

  builder.flush();
  await builder.wait();
}

Map<String, Map<String, dynamic>> getImportDataMap(
    Map<String, dynamic> data, String key) {
  final item = data[key];
  if (!(item is Map<String, dynamic>)) {
    print('Unexpected type of "$key" in import data');
    return {};
  }
  final saferCopy = <String, Map<String, dynamic>>{};
  for (final entry in item.entries) {
    if (entry.value is Map<String, dynamic>) {
      saferCopy[entry.key] = entry.value;
    } else {
      print('Unexpected type of "$key"/"${entry.key}"');
    }
  }
  return saferCopy;
}

Future<void> importData(Boxes boxes, Map<String, dynamic> data) async {
  final futures = <Future>[];

  final prayerData = getImportDataMap(data, _exportPrayerKey);
  futures.addAll(prayerData.entries.map((entry) =>
      boxes.prayer.put(entry.key, HivePrayer.fromJson(entry.value))));

  final updateData = getImportDataMap(data, _exportUpdateKey);
  futures.addAll(updateData.entries.map((entry) => boxes.prayerUpdate
      .put(entry.key, HivePrayerUpdate.fromJson(entry.value))));

  final answerData = getImportDataMap(data, _exportAnswerKey);
  futures.addAll(answerData.entries.map((entry) => boxes.answeredPrayer
      .put(entry.key, HiveAnsweredPrayer.fromJson(entry.value))));

  final idListData = getImportDataMap(data, _exportIdList);
  futures.addAll(idListData.entries.map((entry) =>
      boxes.idList.put(entry.key, HiveIdList.fromJson(entry.value))));

  final idListChunkData = getImportDataMap(data, _exportIdListChunk);
  futures.addAll(idListChunkData.entries.map((entry) =>
      boxes.idListChunk.put(entry.key, HiveIdListChunk.fromJson(entry.value))));

  await Future.wait(futures);
}

const _maxItemsSingleFile = 1000;

class _Builder {
  PartialOutputProcessor processPartialOutput;
  int _part = 0;
  final List<Future<void>> _futures = [];
  int _itemsAccumulated = 0;
  Map<String, dynamic> _simpleItemMap = {};
  Map<String, List<dynamic>> _listItemMap = {};
  Map<String, Map<String, dynamic>> _objectItemMap = {};
  final JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  _Builder(this.processPartialOutput);

  void addSimpleItem(String key, dynamic item) {
    _simpleItemMap[key] = item;
    _itemsAccumulated++;
    _flushIfFull();
  }

  void addListItem(String key, dynamic item) {
    if (!_listItemMap.containsKey(key)) {
      _listItemMap[key] = [];
    }
    _listItemMap[key]!.add(item);
    _itemsAccumulated++;
    _flushIfFull();
  }

  void addIdItem(String typeKey, String id, dynamic item) {
    if (!_objectItemMap.containsKey(typeKey)) {
      _objectItemMap[typeKey] = {};
    }
    _objectItemMap[typeKey]![id] = item;
    _itemsAccumulated++;
    _flushIfFull();
  }

  void flush() {
    _futures.add(processPartialOutput(_part, _build()));
    _itemsAccumulated = 0;
    _simpleItemMap = {};
    _listItemMap = {};
    _objectItemMap = {};
    _part++;
  }

  Future<void> wait() {
    return Future.wait(_futures);
  }

  void _flushIfFull() {
    if (_itemsAccumulated >= _maxItemsSingleFile) {
      flush();
    }
  }

  String _build() {
    final allMap = {};
    allMap.addAll(_simpleItemMap);
    allMap.addAll(_listItemMap);
    allMap.addAll(_objectItemMap);
    return _encoder.convert(allMap);
    // return jsonEncode(allMap);
  }
}
