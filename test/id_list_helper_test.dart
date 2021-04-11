import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_app/data/hive/hive_id_list.dart';
import 'package:prayer_app/data/hive/hive_id_list_chunk.dart';
import 'package:prayer_app/data/id_list_helper.dart';

import 'data/hive/mock_lazy_box.dart';

const idealChunkSize = 4;
const listId = 'list';
const firstChunkId = 'firstChunk';

void main() {
  group('IdListHelper', () {
    test('Add items within single chunk', () async {
      final f = Fixture();
      for (var i = 0; i < 8; i++) {
        await f.idListHelper.insertId(0, 'id');
      }
      expect(f.idListHelper.length, equals(8));
      expect(f.listBox.backing[listId]!.length, equals(8));
      expect(f.chunkBox.backing.length, 1);
      final idList = f.chunkBox.backing[firstChunkId]!.ids;
      expect(idList, equals(List.filled(8, 'id')));
    });

    test('Add items until split', () async {
      final f = Fixture();
      for (var i = 0; i < 9; i++) {
        await f.idListHelper.insertId(0, 'id');
      }
      expect(f.idListHelper.length, equals(9));
      expect(f.listBox.backing[listId]!.length, equals(9));
      expect(f.chunkBox.backing.length, 2);
      final idList = f.chunkBox.backing[firstChunkId]!.ids;
      expect(idList.length, greaterThan(3));
      expect(idList.length, lessThan(6));
    });

    test('Add items to front and read them back', () async {
      final f = Fixture();
      const n = 32;
      for (var i = 0; i < n; i++) {
        await f.idListHelper.insertId(0, '$i');
        final immediateRead = await f.idListHelper.getId(0);
        expect(immediateRead, equals('$i'));
        for (var j = 0; j <= i; j++) {
          final valueBack = await f.idListHelper.getId(j);
          expect(valueBack, equals('${i - j}'));
        }
      }
      expect(f.idListHelper.length, equals(n));
      expect(f.listBox.backing[listId]!.length, equals(n));
    });

    test('Add items to back and read them back', () async {
      final f = Fixture();
      const n = 32;
      for (var i = 0; i < n; i++) {
        await f.idListHelper.insertId(i, '$i');
        for (var j = 0; j <= i; j++) {
          final valueBack = await f.idListHelper.getId(j);
          expect(valueBack, equals('$j'));
        }
      }
      expect(f.idListHelper.length, equals(n));
      expect(f.listBox.backing[listId]!.length, equals(n));
    });

    test('Add items in parallel', () async {
      final f = Fixture();
      const n = 32;
      final futures = <Future<void>>[];
      for (var i = 0; i < n; i++) {
        futures.add(f.idListHelper.insertId(0, '$i'));
        futures.add(f.idListHelper.insertId(i, '$i'));
      }
      await Future.wait(futures);
      expect(f.idListHelper.length, equals(2 * n));
      expect(f.listBox.backing[listId]!.length, equals(2 * n));
      final counts = List.filled(n, 0);
      await f.idListHelper.forEachId(0, 2 * n, (i, id) async {
        counts[int.parse(id)]++;
      });
      for (var i = 0; i < n; i++) {
        final count = counts[i];
        expect(count, equals(2), reason: 'Expect to see 2 of $i');
      }
    });

    test('Add and remove a bunch of data randomly', () async {
      final f = Fixture();
      const n = 1000;
      final r = Random(1);
      final compareList = <String>[];
      var inserts = 0;
      var removes = 0;
      for (var i = 0; i < n; i++) {
        // Bias removal toward end.
        final shouldRemove = compareList.isNotEmpty && r.nextInt(n) > n - i;
        if (shouldRemove) {
          final index = r.nextInt(compareList.length);
          compareList.removeAt(index);
          await f.idListHelper.removeId(index);
          removes++;
        } else {
          final index = r.nextInt(compareList.length + 1);
          final id = r.nextDouble().toString();
          compareList.insert(index, id);
          await f.idListHelper.insertId(index, id);
          inserts++;
        }
        expect(f.idListHelper.length, equals(compareList.length),
            reason: 'Lengths should be equal '
                'after $inserts inserts and $removes removes'
                ' (last was ${shouldRemove ? 'remove' : 'insert'})');
        // This check slows things down significantly, but can be useful debugging.
        // await f.idListHelper.forEachId(0, f.idListHelper.length, (i, id) async {
        //   expect(id, equals(compareList[i]));
        // });
      }
      // These checks are just making sure our randomness turned out like we hoped.
      expect(removes, greaterThan(0.4 * n));
      expect(inserts, greaterThan(0.4 * n));
      expect(compareList.length, greaterThan(3 * idealChunkSize));

      // Verify the data from our structure against a standard list.
      var counted = 0;
      await f.idListHelper.forEachId(0, f.idListHelper.length, (i, id) async {
        expect(id, equals(compareList[i]));
        counted++;
      });
      expect(counted, equals(compareList.length));
    });
  });
}

class Fixture {
  late MockLazyBox<HiveIdList> listBox;
  late MockLazyBox<HiveIdListChunk> chunkBox;
  late HiveIdList list;
  late HiveIdListChunk firstChunk;
  late IdListHelper idListHelper;

  Fixture() {
    listBox = MockLazyBox<HiveIdList>();
    chunkBox = MockLazyBox<HiveIdListChunk>();
    list = HiveIdList();
    list.firstChunkId = firstChunkId;
    firstChunk = HiveIdListChunk();
    firstChunk.parentListId = listId;
    listBox.put(listId, list);
    chunkBox.put(firstChunkId, firstChunk);
    idListHelper = IdListHelper(
      listBox: listBox,
      chunkBox: chunkBox,
      listId: listId,
      length: 0,
      chunkId: firstChunkId,
      chunk: firstChunk,
      idealChunkSize: 4,
    );
  }
}
