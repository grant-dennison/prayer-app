import 'dart:convert';

import 'hive/boxes.dart';

typedef PartialOutputProcessor = Future<void> Function(int index, String json);

const exportPrayerKey = 'prayer';

Future<void> exportData(
    Boxes boxes, PartialOutputProcessor processPartialOutput) async {
  final builder = _Builder(processPartialOutput);

  final prayerBox = boxes.prayer;
  for (final key in prayerBox.keys) {
    final hivePrayer = await prayerBox.get(key);
    if (hivePrayer == null) {
      print('Prayer $key not found');
      continue;
    }
    builder.addListItem(exportPrayerKey, hivePrayer.toJson());
  }
}

// TODO: Make this a larger number. Low now for testing.
const _maxItemsSingleFile = 5;

class _Builder {
  PartialOutputProcessor processPartialOutput;
  int _part = 0;
  int _itemsAccumulated = 0;
  Map<String, Object> _simpleItemMap = {};
  Map<String, List<Object>> _listItemMap = {};

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
    processPartialOutput(_part, _build());
    _itemsAccumulated = 0;
    _simpleItemMap = {};
    _listItemMap = {};
    _part++;
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
    return jsonEncode(allMap);
  }
}
