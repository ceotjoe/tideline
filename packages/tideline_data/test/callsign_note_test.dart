import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/test_database.dart';

void main() {
  late TidelineDatabase db;
  late CallsignNoteRepository notes;
  var now = 1000;

  setUp(() async {
    db = await openTestDatabase();
    notes = CallsignNoteRepository(db, HlcClock('dev'), nowMillis: () => now++);
  });

  Future<List<CallsignNoteRow>> rows() => db.select(db.callsignNotes).get();

  test('a note is saved, read and replaced', () async {
    expect(await notes.find('DL1ABC'), isNull);
    await notes.save('DL1ABC', '  Calls on 40 m at 6 UTC \n');
    expect(await notes.find('DL1ABC'), 'Calls on 40 m at 6 UTC');
    await notes.save('DL1ABC', 'Moved to JO62');
    expect(await notes.find('DL1ABC'), 'Moved to JO62');
    final row = (await rows()).single;
    expect(row.rev, 2);
    expect(row.originDeviceId, 'dev');
    expect(row.hlcModified.compareTo(row.hlcCreated), greaterThan(0));
  });

  test('portable and prefixed calls share one note', () async {
    await notes.save('EA8/DL1ABC/P', 'Holiday call');
    expect(await notes.find('DL1ABC'), 'Holiday call');
    expect(await notes.find('dl1abc/m'), 'Holiday call');
    await notes.save('DL1ABC', 'Home');
    expect(await rows(), hasLength(1));
  });

  test(
    'an empty note removes it, leaving a tombstone without the text',
    () async {
      await notes.save('DL1ABC', 'secret');
      await notes.save('DL1ABC', '   ');
      expect(await notes.find('DL1ABC'), isNull);
      final row = (await rows()).single;
      expect(row.deletedAt, isNotNull);
      expect(row.body, isEmpty);
    },
  );

  test('a note added again after a delete reuses the row', () async {
    await notes.save('DL1ABC', 'one');
    await notes.delete('DL1ABC');
    await notes.save('DL1ABC', 'two');
    expect(await notes.find('DL1ABC'), 'two');
    final row = (await rows()).single;
    expect(row.deletedAt, isNull);
    expect(row.rev, 3);
  });

  test('deleting what is not there does nothing', () async {
    await notes.delete('DL1ABC');
    await notes.delete('not a call');
    expect(await rows(), isEmpty);
  });

  test(
    'a call that is not a callsign and a too long note are refused',
    () async {
      expect(() => notes.save('hello', 'x'), throwsArgumentError);
      expect(
        () =>
            notes.save('DL1ABC', 'x' * (CallsignNoteRepository.maxLength + 1)),
        throwsArgumentError,
      );
      expect(await rows(), isEmpty);
    },
  );

  test('watch follows saves and deletes', () async {
    final seen = <String?>[];
    final sub = notes.watch('DL1ABC').distinct().listen(seen.add);
    addTearDown(sub.cancel);

    // Wait for each emission instead of sleeping: a slow machine (the Windows
    // runner) may deliver them late, but never out of order.
    Future<void> expectSeen(List<String?> expected) async {
      for (var i = 0; i < 500 && seen.length < expected.length; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(seen, expected);
    }

    await expectSeen([null]);
    await notes.save('DL1ABC', 'a');
    await expectSeen([null, 'a']);
    await notes.save('DL1ABC', 'b');
    await expectSeen([null, 'a', 'b']);
    await notes.delete('DL1ABC');
    await expectSeen([null, 'a', 'b', null]);
  });

  test('watchCalls lists the stations that have a note', () async {
    await notes.save('DL1ABC', 'a');
    await notes.save('G4XYZ', 'b');
    await notes.delete('G4XYZ');
    expect(await notes.watchCalls().first, {'DL1ABC'});
  });
}
