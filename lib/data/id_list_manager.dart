import 'package:hive/hive.dart';
import 'package:prayer_app/data/id_list_helper.dart';
import 'package:prayer_app/utils/uuid.dart';

import 'hive/hive_id_list.dart';
import 'hive/hive_id_list_chunk.dart';

const _cacheSize = 5;

class IdListManager {
  final LazyBox<HiveIdList> listBox;
  final LazyBox<HiveIdListChunk> chunkBox;

  final List<_CacheEntry> _cache = [];

  IdListManager({
    required this.listBox,
    required this.chunkBox,
  });

  Future<String> createList() async {
    final listId = genUuid();
    final chunkId = genUuid();

    final list = HiveIdList();
    list.firstChunkId = chunkId;

    final chunk = HiveIdListChunk();
    chunk.parentListId = listId;

    await chunkBox.put(chunkId, chunk);
    await listBox.put(listId, list);

    return listId;
  }

  Future<IdListHelper> getList(String id) async {
    for (final entry in _cache) {
      if (entry.id == id) {
        return entry.helper;
      }
    }
    if (_cache.length == _cacheSize) {
      _cache.removeLast();
    }
    final helper = await _openList(id);
    _cache.insert(0, _CacheEntry(id: id, helper: helper));
    return helper;
  }

  Future<IdListHelper> _openList(String id) async {
    final list = await listBox.get(id);
    if (list == null) {
      throw 'List not found';
    }

    final firstChunk = await chunkBox.get(list.firstChunkId);
    if (firstChunk == null) {
      throw 'First chunk not found';
    }

    return IdListHelper(
      listBox: listBox,
      chunkBox: chunkBox,
      listId: id,
      length: list.length,
      chunkId: list.firstChunkId,
      chunk: firstChunk,
    );
  }
}

class _CacheEntry {
  final String id;
  final IdListHelper helper;

  _CacheEntry({
    required this.id,
    required this.helper,
  });
}
