import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/app.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Records settings saves without a database.
class FakeSettingsController implements SettingsController {
  final List<AppSettings> saved = [];

  @override
  Future<void> save(AppSettings settings) async => saved.add(settings);
}

/// Records logged QSOs without a database.
class FakeQsoRepository implements QsoRepository {
  final List<Qso> logged = [];

  @override
  Future<void> log(Qso qso) async => logged.add(qso);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A sync controller that never touches the network or plugins.
class FakeSyncController extends SyncController {
  int runs = 0;

  @override
  SyncActivity build() => const SyncIdle();

  @override
  Future<SyncRunResult?> syncNow() async {
    runs++;
    return null;
  }
}

/// Window sizes used across tests and goldens.
abstract final class TestSizes {
  static const phone = Size(390, 844);
  static const tabletPortrait = Size(820, 1180);
  static const tabletLandscape = Size(1180, 820);
  static const desktop = Size(1440, 900);
}

/// A connected test account.
const testAccount = Account(
  id: 'acc-1',
  label: 'Home',
  baseUrl: 'https://log.example.org',
  usesIndexPhp: true,
  allowHttpLan: false,
  scopes: {'qso:read', 'qso:write', 'station:read', 'qso:delete'},
  hasContestSessions: true,
);

/// The test account's station.
const testStation = StationProfile(
  id: 'st-1',
  accountId: 'acc-1',
  remoteId: 3,
  name: 'Home QTH',
  callsign: 'DO1HOZ',
  active: true,
  gridsquare: 'JO40',
);

/// Builds [count] logged QSOs with varied sync states.
List<LoggedQso> sampleLog(int count) => [
  for (var i = 0; i < count; i++)
    LoggedQso(
      Qso(
        id: 'q$i',
        accountId: 'acc-1',
        stationProfileId: 'st-1',
        call: Callsign.tryParse(['DL1ABC', 'G4XYZ', 'EA8/OE3XYZ/P'][i % 3])!,
        timeOn: UtcDateTime(DateTime.utc(2026, 10, 2, 14, i)),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('USB')!,
        freqHz: 14205000,
        rstSent: '59',
        rstRcvd: '57',
        fields: const {'NAME': 'Anna'},
      ),
      SyncStatus(state: SyncState.values[i % SyncState.values.length]),
    ),
];

/// The real bundled DXCC data, loaded once (asset loading is asynchronous
/// I/O, which widget tests' fake clock would never complete).
final DxccDatabase testDxcc = DxccDatabase.parseCsv(
  File('assets/reference/cty.csv').readAsStringSync(),
);

/// Everything the harness exposes to tests.
typedef Pumped = ({
  FakeSettingsController settings,
  FakeQsoRepository qsos,
  FakeSyncController sync,
});

/// Pumps the full app with providers that need no database or network.
Future<Pumped> pumpTideline(
  WidgetTester tester, {
  Size size = TestSizes.phone,
  AppSettings settings = const AppSettings(),
  int pending = 0,
  double textScale = 1,
  bool disableAnimations = true,
  List<Account> accounts = const [testAccount],
  List<LoggedQso> log = const [],
}) async {
  tester.view
    ..physicalSize = size * tester.view.devicePixelRatio
    ..platformDispatcher.textScaleFactorTestValue = textScale
    ..platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: disableAnimations);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final controller = FakeSettingsController();
  final qsos = FakeQsoRepository();
  final sync = FakeSyncController();
  Never noDb(Ref ref) => throw StateError('no database in widget tests');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
        settingsValuesProvider.overrideWith(
          (ref) => Stream.value({'account.acc-1.defaultStation': '3'}),
        ),
        pendingSyncCountProvider.overrideWith((ref) => Stream.value(pending)),
        bindingOverridesProvider.overrideWith((ref) => Stream.value(const [])),
        settingsControllerProvider.overrideWithValue(controller),
        accountsProvider.overrideWith((ref) => Stream.value(accounts)),
        stationsProvider.overrideWith(
          (ref) => Stream.value(const [testStation]),
        ),
        logProvider.overrideWith((ref) => Stream.value(log)),
        qsoRepositoryProvider.overrideWithValue(qsos),
        dxccProvider.overrideWith((ref) async => testDxcc),
        syncControllerProvider.overrideWith(() => sync),
        databaseProvider.overrideWith(noDb),
        shortcutBindingStoreProvider.overrideWith(noDb),
        settingsStoreProvider.overrideWith(noDb),
      ],
      child: const TidelineApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (settings: controller, qsos: qsos, sync: sync);
}
