import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

/// Repositories only keep the database; nothing here touches it.
class _NoDatabase extends Fake implements TidelineDatabase;

class _NoSecrets extends Fake implements SecretStore;

class _RecordingWorkedBefore extends Fake implements WorkedBeforeRepository {
  final List<String> built = [];

  @override
  Future<bool> ensureBuilt(String accountId) async {
    built.add(accountId);
    return true;
  }
}

ProviderContainer _container({List<Override> extra = const []}) {
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(_NoDatabase()),
      secretStoreProvider.overrideWithValue(_NoSecrets()),
      deviceIdProvider.overrideWithValue('dev'),
      ...extra,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test("the app's sync engine mirrors contest sessions and pulls the "
      'worked-before index', () {
    final engine = _container().read(syncEngineProvider);
    expect(engine.contestSessions, isNotNull);
    expect(engine.workedBefore, isNotNull);
  });

  test("the engine uses the app's worked-before repository", () {
    final container = _container();
    expect(
      container.read(syncEngineProvider).workedBefore,
      same(container.read(workedBeforeRepositoryProvider)),
    );
  });

  test(
    'the worked-before index is built once for the active account',
    () async {
      final repo = _RecordingWorkedBefore();
      _container(
        extra: [
          workedBeforeRepositoryProvider.overrideWithValue(repo),
          accountsProvider.overrideWith((ref) => Stream.value([testAccount])),
          settingsValuesProvider.overrideWith((ref) => Stream.value(const {})),
        ],
      )
      // Keep the provider alive while its dependencies load.
      .listen(workedBeforeIndexProvider, (_, _) {});
      await pumpEventQueue();
      expect(repo.built, [testAccount.id]);
    },
  );

  test('without an account nothing is built', () async {
    final repo = _RecordingWorkedBefore();
    _container(
      extra: [
        workedBeforeRepositoryProvider.overrideWithValue(repo),
        accountsProvider.overrideWith((ref) => Stream.value(const [])),
        settingsValuesProvider.overrideWith((ref) => Stream.value(const {})),
      ],
    )
    // Keep the provider alive while its dependencies load.
    .listen(workedBeforeIndexProvider, (_, _) {});
    await pumpEventQueue();
    expect(repo.built, isEmpty);
  });
}
