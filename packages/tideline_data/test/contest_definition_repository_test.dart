import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';

import 'support/contest_fixtures.dart';
import 'support/test_database.dart';

void main() {
  late ContestHarness h;
  late ContestDefinitionRepository repo;

  setUp(() async {
    h = await ContestHarness.create(await openTestDatabase());
    repo = h.definitions;
  });

  test(
    'seeds builtins, finds them, and only upgrades to higher versions',
    () async {
      expect((await repo.find('test-serial'))!.name, 'Test Serial');
      final again = await repo.seedBuiltins([serialContestJson]);
      expect(again.unchanged, ['test-serial']);

      final v2 = serialContestJson.replaceAll('"version": 1', '"version": 2');
      final up = await repo.seedBuiltins([v2]);
      expect(up.updated, ['test-serial']);
      expect((await repo.find('test-serial'))!.version, 2);

      final down = await repo.seedBuiltins([serialContestJson]);
      expect(down.unchanged, ['test-serial']);
      expect((await repo.find('test-serial'))!.version, 2);
    },
  );

  test(
    'reports unparseable builtins and returns null for unknown ids',
    () async {
      final report = await repo.seedBuiltins(['{"schema": 1}', 'nope']);
      expect(report.invalid, hasLength(2));
      expect(await repo.find('missing'), isNull);
    },
  );

  test('user definitions: import, replace, builtin clash, invalid', () async {
    final json = zoneContestWithAdif(id: 'my-contest');
    final first = await repo.importUserDefinition(json);
    expect(
      first,
      isA<ContestImported>().having((r) => r.replaced, 'replaced', false),
    );
    final second = await repo.importUserDefinition(json);
    expect(
      second,
      isA<ContestImported>().having((r) => r.replaced, 'replaced', true),
    );

    final clash = await repo.importUserDefinition(zoneContestWithAdif());
    expect(
      clash,
      isA<ContestImportRejected>().having(
        (r) => r.error,
        'error',
        ContestImportError.idClashesWithBuiltin,
      ),
    );

    final bad = await repo.importUserDefinition('{"unknown": 1}');
    expect(
      bad,
      isA<ContestImportRejected>()
          .having((r) => r.error, 'error', ContestImportError.invalid)
          .having((r) => r.exception, 'exception', isNotNull),
    );

    final all = await repo.watchAll().first;
    expect(
      all.map((e) => e.definition.id),
      unorderedEquals(['my-contest', 'test-serial', 'test-zone']),
    );
    expect(all.where((e) => !e.builtin).single.definition.id, 'my-contest');
  });

  test('a builtin never overwrites a user definition with its id', () async {
    await repo.importUserDefinition(zoneContestWithAdif(id: 'shared-id'));
    final report = await repo.seedBuiltins([
      zoneContestWithAdif(id: 'shared-id', version: 9),
    ]);
    expect(report.conflicts, ['shared-id']);
    expect((await repo.find('shared-id'))!.version, 1);
  });

  test('delete: only user definitions no session uses', () async {
    await repo.importUserDefinition(zoneContestWithAdif(id: 'mine'));
    await repo.importUserDefinition(zoneContestWithAdif(id: 'used'));
    await h.sessions.start(
      accountId: 'acc',
      definitionId: 'used',
      me: me,
      accountSupportsSessions: false,
    );
    expect(await repo.delete('nothing'), ContestDeleteResult.notFound);
    expect(await repo.delete('test-serial'), ContestDeleteResult.builtin);
    expect(await repo.delete('used'), ContestDeleteResult.inUse);
    expect(await repo.delete('mine'), ContestDeleteResult.deleted);
    expect(await repo.find('mine'), isNull);
  });
}
