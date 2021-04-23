import 'dart:convert';

import 'package:date_time_format/date_time_format.dart';
import 'package:file_saver/file_saver.dart';

import 'hive/boxes.dart';

typedef PartialOutputProcessor = Future<void> Function(int index, String json);

Future<void> exportDataToFiles(Boxes boxes) async {
  final timeString = DateTimeFormat.format(DateTime.now(),
      format: DateTimeFormats.xmlrpcCompact);
  final baseFileName = 'prayer-export-$timeString';
  await exportData(boxes, (index, jsonStr) async {
    await FileSaver.instance.saveFile(
        '$baseFileName-$index', Utf8Encoder().convert(jsonStr), 'json');
  });
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
    builder.addListItem(_exportPrayerKey, hivePrayer.toJson());
  }

  final updateBox = boxes.prayerUpdate;
  for (final key in updateBox.keys) {
    final hiveUpdate = await updateBox.get(key);
    if (hiveUpdate == null) continue;
    builder.addListItem(_exportUpdateKey, hiveUpdate.toJson());
  }

  final answerBox = boxes.answeredPrayer;
  for (final key in answerBox.keys) {
    final hiveAnswer = await answerBox.get(key);
    if (hiveAnswer == null) continue;
    builder.addListItem(_exportAnswerKey, hiveAnswer.toJson());
  }

  final idListBox = boxes.idList;
  for (final key in idListBox.keys) {
    final hiveIdList = await idListBox.get(key);
    if (hiveIdList == null) continue;
    builder.addListItem(_exportIdList, hiveIdList.toJson());
  }

  final idListChunkBox = boxes.idListChunk;
  for (final key in idListChunkBox.keys) {
    final hiveIdListChunk = await idListChunkBox.get(key);
    if (hiveIdListChunk == null) continue;
    builder.addListItem(_exportIdListChunk, hiveIdListChunk.toJson());
  }

  builder.flush();
  await builder.wait();
}

const _maxItemsSingleFile = 1000;

class _Builder {
  PartialOutputProcessor processPartialOutput;
  int _part = 0;
  final List<Future<void>> _futures = [];
  int _itemsAccumulated = 0;
  Map<String, Object> _simpleItemMap = {};
  Map<String, List<Object>> _listItemMap = {};
  final JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  _Builder(this.processPartialOutput);

  void addSimpleItem(String key, Object item) {
    _simpleItemMap[key] = item;
    _itemsAccumulated++;
    _flushIfFull();
  }

  void addListItem(String key, Object item) {
    if (!_listItemMap.containsKey(key)) {
      _listItemMap[key] = [];
    }
    _listItemMap[key]!.add(item);
    _itemsAccumulated++;
    _flushIfFull();
  }

  void flush() {
    _futures.add(processPartialOutput(_part, _build()));
    _itemsAccumulated = 0;
    _simpleItemMap = {};
    _listItemMap = {};
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
    return _encoder.convert(allMap);
    // return jsonEncode(allMap);
  }
}
