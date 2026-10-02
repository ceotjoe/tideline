import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/contest/contest_seed.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

class _RecordingRepository implements ContestDefinitionRepository {
  List<String> seeded = const [];

  @override
  Future<ContestSeedReport> seedBuiltins(List<String> jsons) async {
    seeded = jsons;
    return ContestSeedReport(
      inserted: [for (final j in jsons) ContestDefinition.parse(j).id],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future.error(StateError('secret path /Users/someone/file'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every definition file of the folder is seeded', () async {
    final repository = _RecordingRepository();
    final messages = <String>[];
    final report = await seedBundledContests(
      bundle: rootBundle,
      repository: repository,
      report: messages.add,
    );
    final files = Directory('assets/contests')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    expect(files.length, greaterThanOrEqualTo(10));
    expect(repository.seeded, hasLength(files.length));
    expect(report!.inserted, hasLength(files.length));
    expect(messages, isEmpty);
    // Only JSON files are read: the README in the folder is not a definition.
    for (final json in repository.seeded) {
      expect(() => ContestDefinition.parse(json), returnsNormally);
    }
  });

  test('a failure is reported without details and never thrown', () async {
    final messages = <String>[];
    final report = await seedBundledContests(
      bundle: _FailingBundle(),
      repository: _RecordingRepository(),
      report: messages.add,
    );
    expect(report, isNull);
    expect(messages, hasLength(1));
    // The type is enough for the developer; no paths, no exception text.
    expect(messages.single, isNot(contains('/Users')));
    expect(messages.single, isNot(contains('secret')));
  });

  test('rejected files are logged by reason and path only', () async {
    final messages = <String>[];
    final report = await seedBundledContests(
      bundle: rootBundle,
      repository: _InvalidRepository(),
      report: messages.add,
    );
    expect(report!.invalid, hasLength(1));
    expect(messages.single, contains('unsupportedSchema'));
  });
}

class _InvalidRepository implements ContestDefinitionRepository {
  @override
  Future<ContestSeedReport> seedBuiltins(List<String> jsons) async =>
      const ContestSeedReport(
        invalid: [
          ContestDefinitionException(
            ContestDefinitionError.unsupportedSchema,
            r'$.schema',
          ),
        ],
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
