import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

class _Qsos extends Fake implements QsoRepository {
  final List<String> imported = [];

  @override
  Future<int> importAll(List<Qso> qsos) async {
    imported.addAll(qsos.map((q) => q.call.value));
    return qsos.length;
  }
}

class _Evicted extends Fake implements QsoEvictionRepository {
  new(this.hashes);

  final Set<String> hashes;

  @override
  Future<Set<String>> evictedDupeHashes(String accountId) async => hashes;
}

String _record(String call, String time) =>
    '<CALL:${call.length}>$call <QSO_DATE:8>20200101 <TIME_ON:6>$time '
    '<BAND:3>20m <MODE:2>CW <EOR>';

void main() {
  test(
    'importing a file skips QSOs removed from this device to free space',
    () async {
      final adif =
          '<ADIF_VER:5>3.1.4 <EOH>\n'
          '${_record('DL1ABC', '120000')}\n${_record('G4XYZ', '120100')}';

      // The fingerprint the removal would have stored for the first QSO.
      final first = const AdiParser().parse(utf8.encode(adif)).records.first;
      final result = AdifQsoMapping.fromRecord(
        first,
        id: 'x',
        accountId: 'acc-1',
        stationProfileId: 'st-1',
      );
      final hash = QsoEvictionRepository.dupeHash((result as AdifImported).qso);

      final qsos = _Qsos();
      final container = ProviderContainer(
        overrides: [
          qsoRepositoryProvider.overrideWithValue(qsos),
          logProvider.overrideWith((ref) => Stream.value(const [])),
          qsoEvictionRepositoryProvider.overrideWithValue(_Evicted({hash})),
        ],
      );
      addTearDown(container.dispose);
      // A listener keeps the stream provider alive while it is awaited.
      container.listen(logProvider, (_, _) {});

      final summary = await container
          .read(dataTransferProvider)
          .importAdif(
            Uint8List.fromList(utf8.encode(adif)),
            account: testAccount,
            stationProfileId: 'st-1',
          );
      expect(qsos.imported, ['G4XYZ']);
      expect((summary.imported, summary.duplicates), (1, 1));
    },
  );
}
