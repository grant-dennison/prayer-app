import 'package:hive/hive.dart';
import 'package:mutex/mutex.dart';
import 'package:prayer_app/data/hive/hive_id_list_chunk.dart';
import 'package:prayer_app/utils/uuid.dart';

import 'hive/hive_id_list.dart';

const _idealChunkSize = 100;

enum LoopBehavior {
  keepGoing,
  stop,
}

class IdListHelper {
  final LazyBox<HiveIdList> listBox;
  final LazyBox<HiveIdListChunk> chunkBox;
  final String listId;
  int _length;
  _Chunk _currentChunk;

  final int idealChunkSize;
  final _minChunkSize;
  final _maxChunkSize;

  final _m = Mutex();

  IdListHelper({
    required this.listBox,
    required this.chunkBox,
    required this.listId,
    required int length,
    required String chunkId,
    int startIndex = 0,
    required HiveIdListChunk chunk,
    this.idealChunkSize = _idealChunkSize,
  })  : _length = length,
        _currentChunk =
            _Chunk(id: chunkId, startIndex: startIndex, data: chunk),
        _minChunkSize = idealChunkSize ~/ 2,
        _maxChunkSize = 2 * idealChunkSize;

  int get length => _length;

  Future<String> getId(int index) async {
    return await _m.protect<String>(() async {
      if (index < 0 || index >= _length) {
        throw 'Index out of bounds';
      }
      if (!_isIndexInCurrentChunk(index)) {
        await _moveToChunkWith(index);
      }
      return _currentChunk.getId(index);
    });
  }

  Future<void> forEachId(int startIndex, int length,
      LoopBehavior? Function(int i, String id) callback) async {
    await _m.protect(() async {
      for (var i = startIndex; i < startIndex + length; i++) {
        if (!_isIndexInCurrentChunk(i)) {
          await _moveToChunkWith(i);
        }
        final result = callback(i, _currentChunk.getId(i));
        if (result == LoopBehavior.stop) {
          return;
        }
      }
    });
  }

  Future<void> insertId(int index, String id) async {
    // print('insert $id at $index');
    await _m.protect(() async {
      await _modifyListAt(index, (list, i) => list.insert(i, id));
      await _setLength(_length + 1);
    });
  }

  Future<void> removeId(int index) async {
    // print('remove at $index');
    await _m.protect(() async {
      await _modifyListAt(index, (list, i) => list.removeAt(i));
      await _setLength(_length - 1);
    });
  }

  Future<void> _modifyListAt(
      int index, void Function(List<String>, int) modifyList) async {
    await _moveToChunkWith(index);
    final idsCopy = List<String>.from(_currentChunk.data.ids);
    modifyList(idsCopy, index - _currentChunk.startIndex);
    _currentChunk.data.ids = idsCopy;
    await chunkBox.put(_currentChunk.id, _currentChunk.data);
    if (_currentChunk.data.ids.length > _maxChunkSize) {
      await _splitCurrent();
    } else if (_currentChunk.data.ids.length < _minChunkSize) {
      await _handleCurrentTooSmall();
    }
  }

  Future<void> _setLength(int length) async {
    final list = await listBox.get(listId);
    list!.length = length;
    await listBox.put(listId, list);
    _length = length;
  }

  Future<void> _splitCurrent() async {
    // print('splitting');
    final c = _currentChunk.data;
    final divider = c.ids.length ~/ 2;

    final rightChunkId = c.nextChunkId;

    final newChunkId = genUuid();
    final newChunk = HiveIdListChunk();
    newChunk.parentListId = c.parentListId;
    newChunk.nextChunkId = rightChunkId;
    newChunk.previousChunkId = _currentChunk.id;
    newChunk.ids = c.ids.sublist(divider);

    c.ids = c.ids.sublist(0, divider);
    c.nextChunkId = newChunkId;

    await Future.wait([
      chunkBox.put(newChunkId, newChunk),
      chunkBox.put(_currentChunk.id, c),
      () async {
        final rightChunk =
            rightChunkId == null ? null : await chunkBox.get(rightChunkId);
        if (rightChunk != null) {
          rightChunk.previousChunkId = newChunkId;
          await chunkBox.put(rightChunkId, rightChunk);
        }
      }(),
    ]);
  }

  Future<void> _handleCurrentTooSmall() async {
    final c = _currentChunk.data;
    final leftId = c.previousChunkId;
    final rightId = c.nextChunkId;
    final leftChunk = leftId == null ? null : await chunkBox.get(leftId);
    final rightChunk = rightId == null ? null : await chunkBox.get(rightId);
    if (leftChunk != null) {
      final leftStartIndex = _currentChunk.startIndex - leftChunk.ids.length;
      await _evenOutAdjacentChunks(leftId!, _currentChunk.id, leftChunk, c);
      // _currentChunk may have been merged left or the boundary shifted weird relative to startIndex.
      _currentChunk =
          _Chunk(id: leftId, startIndex: leftStartIndex, data: leftChunk);
    } else if (rightChunk != null) {
      await _evenOutAdjacentChunks(_currentChunk.id, rightId!, c, rightChunk);
    } else {
      // There is only one chunk.
    }
  }

  Future<void> _evenOutAdjacentChunks(String leftChunkId, String rightChunkId,
      HiveIdListChunk leftChunk, HiveIdListChunk rightChunk) async {
    final allChildIds = [...leftChunk.ids, ...rightChunk.ids];
    if (leftChunk.ids.length > _idealChunkSize ||
        rightChunk.ids.length > _idealChunkSize) {
      // print('redistributing');
      // Prefer keep split.
      final divider = allChildIds.length ~/ 2;
      leftChunk.ids = allChildIds.sublist(0, divider);
      rightChunk.ids = allChildIds.sublist(divider);
      await Future.wait([
        chunkBox.put(leftChunkId, leftChunk),
        chunkBox.put(rightChunkId, rightChunk),
      ]);
    } else {
      // print('merging');
      // But merge if both are small.
      // It's important that we merge left here because then we don't have to modify parent list.
      leftChunk.ids = allChildIds;
      final nextChunkId = rightChunk.nextChunkId;
      leftChunk.nextChunkId = nextChunkId;
      await chunkBox.put(leftChunkId, leftChunk);
      final moreRightChunk =
          nextChunkId == null ? null : await chunkBox.get(nextChunkId);
      if (moreRightChunk != null) {
        moreRightChunk.previousChunkId = leftChunkId;
        await chunkBox.put(nextChunkId, moreRightChunk);
      }
    }
  }

  bool _isIndexInCurrentChunk(int index) {
    if (index >= _currentChunk.startIndex &&
        index < _currentChunk.startIndex + _currentChunk.data.ids.length) {
      return true;
    }
    if (index == _length &&
        index == _currentChunk.startIndex + _currentChunk.data.ids.length) {
      return true;
    }
    return false;
  }

  Future<void> _moveToChunkWith(int index) async {
    final moveForward = index > _currentChunk.startIndex;
    while (!_isIndexInCurrentChunk(index)) {
      final adjacentChunkId = moveForward
          ? _currentChunk.data.nextChunkId
          : _currentChunk.data.previousChunkId;
      final maybeChunk =
          adjacentChunkId == null ? null : await chunkBox.get(adjacentChunkId);
      if (adjacentChunkId == null || maybeChunk == null) {
        throw 'Adjacent chunk not found';
      }
      final newStartIndex = _currentChunk.startIndex +
          (moveForward
              ? _currentChunk.data.ids.length
              : -maybeChunk.ids.length);
      _currentChunk = _Chunk(
          id: adjacentChunkId, startIndex: newStartIndex, data: maybeChunk);
    }
    await _healLength();
  }

  Future<void> _healLength() async {
    if (length < _currentChunk.startIndex + _currentChunk.data.ids.length) {
      var betterLength =
          _currentChunk.startIndex + _currentChunk.data.ids.length;
      if (_currentChunk.data.nextChunkId != null) {
        betterLength++;
      }
      print('Healing bad length $length to $betterLength');
      await _setLength(betterLength);
    }
  }
}

class _Chunk {
  final String id;
  final int startIndex;
  final HiveIdListChunk data;

  _Chunk({
    required this.id,
    required this.startIndex,
    required this.data,
  });

  String getId(int index) {
    return data.ids[index - startIndex];
  }
}
