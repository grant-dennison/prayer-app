import 'package:hive/hive.dart';
import 'package:prayer_app/data/hive/hive_id_list_chunk.dart';
import 'package:prayer_app/utils/uuid.dart';

const _idealChunkSize = 100;
const _minChunkSize = _idealChunkSize ~/ 2;
const _maxChunkSize = 2 * _idealChunkSize;

class IdListWriteHelper {
  final LazyBox<HiveIdListChunk> chunkBox;
  int _length;
  _Chunk _currentChunk;

  IdListWriteHelper({
    required this.chunkBox,
    required int length,
    required String chunkId,
    int startIndex = 0,
    required HiveIdListChunk chunk,
  })   : _length = length,
        _currentChunk =
            _Chunk(id: chunkId, startIndex: startIndex, data: chunk);

  Future<String> getId(int index) async {
    if (index < 0 || index >= _length) {
      throw ('Index out of bounds');
    }
    if (!_isIndexInCurrentChunk(index)) {
      _moveToChunkWith(index);
    }
    return _currentChunk.getId(index);
  }

  Future<void> forEachId(
      int index, int length, void Function(String) callback) async {
    for (int i = index; i < index + length; i++) {
      if (!_isIndexInCurrentChunk(i)) {
        _moveToChunkWith(i);
      }
      callback(_currentChunk.getId(i));
    }
  }

  Future<void> insertId(int index, String id) async {
    await _modifyListAt(index, (list, i) => list.insert(i, id));
    _length++;
  }

  Future<void> removeId(int index) async {
    await _modifyListAt(index, (list, i) => list.removeAt(i));
    _length--;
  }

  Future<void> _modifyListAt(
      int index, void Function(List<String>, int) modifyList) async {
    await _moveToChunkWith(index);
    final idsCopy = List<String>.from(_currentChunk.data.ids);
    modifyList(idsCopy, index - _currentChunk.startIndex);
    _currentChunk.data.ids = idsCopy;
    await chunkBox.put(_currentChunk.id, _currentChunk.data);
    if (_currentChunk.data.ids.length > _maxChunkSize) {
      _splitCurrent();
    } else if (_currentChunk.data.ids.length < _minChunkSize) {
      _handleCurrentTooSmall();
    }
  }

  Future<void> _splitCurrent() async {
    final c = _currentChunk.data;

    final newChunkId = genUuid();
    final newChunk = HiveIdListChunk();
    newChunk.parentListId = c.parentListId;
    newChunk.nextChunkId = c.nextChunkId;
    newChunk.previousChunkId = _currentChunk.id;

    final divider = c.ids.length ~/ 2;
    newChunk.ids = c.ids.sublist(divider);
    c.ids = c.ids.sublist(0, divider);

    c.nextChunkId = newChunkId;

    await Future.wait([
      chunkBox.put(newChunkId, newChunk),
      chunkBox.put(_currentChunk.id, c),
    ]);
  }

  Future<void> _handleCurrentTooSmall() async {
    final c = _currentChunk.data;
    final leftId = c.previousChunkId;
    final rightId = c.nextChunkId;
    final leftChunk = leftId == null ? null : await chunkBox.get(leftId);
    final rightChunk = rightId == null ? null : await chunkBox.get(rightId);
    if (leftChunk != null) {
      _evenOutAdjacentChunks(leftId!, _currentChunk.id, leftChunk, c);
    } else if (rightChunk != null) {
      _evenOutAdjacentChunks(_currentChunk.id, rightId!, c, rightChunk);
    } else {
      // There is only one chunk.
    }
  }

  Future<void> _evenOutAdjacentChunks(String leftChunkId, String rightChunkId,
      HiveIdListChunk leftChunk, HiveIdListChunk rightChunk) async {
    final allChildIds = [...leftChunk.ids, ...rightChunk.ids];
    if (leftChunk.ids.length > _idealChunkSize ||
        rightChunk.ids.length > _idealChunkSize) {
      // Prefer keep split.
      final divider = allChildIds.length ~/ 2;
      leftChunk.ids = allChildIds.sublist(0, divider);
      rightChunk.ids = allChildIds.sublist(divider);
      await Future.wait([
        chunkBox.put(leftChunkId, leftChunk),
        chunkBox.put(rightChunkId, rightChunk),
      ]);
    } else {
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
    bool moveForward = index > _currentChunk.startIndex;
    while (!_isIndexInCurrentChunk(index)) {
      final adjacentChunkId = moveForward
          ? _currentChunk.data.nextChunkId
          : _currentChunk.data.previousChunkId;
      final maybeChunk =
          adjacentChunkId == null ? null : await chunkBox.get(adjacentChunkId);
      if (adjacentChunkId == null || maybeChunk == null) {
        throw ('Adjacent chunk not found');
      }
      final newStartIndex = _currentChunk.startIndex +
          (moveForward
              ? _currentChunk.data.ids.length
              : -maybeChunk.ids.length);
      _currentChunk = _Chunk(
          id: adjacentChunkId, startIndex: newStartIndex, data: maybeChunk);
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
