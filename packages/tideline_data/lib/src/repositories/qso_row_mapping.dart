import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_domain/tideline_domain.dart';

// Maps between domain [Qso]s and database rows. Fields with a dedicated
// column are stored there (for queries); every other ADIF field goes to
// `adif_extra`. Numeric columns only take values that parse cleanly;
// anything else stays verbatim in `adif_extra`, so nothing is lost.

const _textColumns = <String>[
  'NAME', 'QTH', 'GRIDSQUARE', 'STATE', 'CNTY', 'COUNTRY', 'CONT', //
  'DARC_DOK', 'IOTA', 'SOTA_REF', 'POTA_REF', 'WWFF_REF', 'SIG', 'SIG_INFO',
  'MY_SOTA_REF', 'MY_POTA_REF', 'MY_WWFF_REF', 'MY_SIG', 'MY_SIG_INFO',
  'STATION_CALLSIGN', 'OPERATOR', 'MY_GRIDSQUARE', 'CONTEST_ID',
  'SRX_STRING', 'STX_STRING', 'CHECK', 'CLASS', 'PRECEDENCE', 'ARRL_SECT',
  'PROP_MODE', 'SAT_NAME', 'SAT_MODE', 'COMMENT', 'NOTES', 'QSL_VIA',
];
const _intColumns = <String>['DXCC', 'CQZ', 'ITUZ', 'SRX', 'STX'];

String? _text(QsoRow r, String f) => switch (f) {
  'NAME' => r.name,
  'QTH' => r.qth,
  'GRIDSQUARE' => r.gridsquare,
  'STATE' => r.state,
  'CNTY' => r.cnty,
  'COUNTRY' => r.country,
  'CONT' => r.cont,
  'DARC_DOK' => r.darcDok,
  'IOTA' => r.iota,
  'SOTA_REF' => r.sotaRef,
  'POTA_REF' => r.potaRef,
  'WWFF_REF' => r.wwffRef,
  'SIG' => r.sig,
  'SIG_INFO' => r.sigInfo,
  'MY_SOTA_REF' => r.mySotaRef,
  'MY_POTA_REF' => r.myPotaRef,
  'MY_WWFF_REF' => r.myWwffRef,
  'MY_SIG' => r.mySig,
  'MY_SIG_INFO' => r.mySigInfo,
  'STATION_CALLSIGN' => r.stationCallsign,
  'OPERATOR' => r.operator,
  'MY_GRIDSQUARE' => r.myGridsquare,
  'CONTEST_ID' => r.contestId,
  'SRX_STRING' => r.srxString,
  'STX_STRING' => r.stxString,
  'CHECK' => r.check,
  'CLASS' => r.qsoClass,
  'PRECEDENCE' => r.precedence,
  'ARRL_SECT' => r.arrlSect,
  'PROP_MODE' => r.propMode,
  'SAT_NAME' => r.satName,
  'SAT_MODE' => r.satMode,
  'COMMENT' => r.comment,
  'NOTES' => r.notes,
  'QSL_VIA' => r.qslVia,
  _ => null,
};

int? _int(QsoRow r, String f) => switch (f) {
  'DXCC' => r.dxcc,
  'CQZ' => r.cqz,
  'ITUZ' => r.ituz,
  'SRX' => r.srx,
  'STX' => r.stx,
  _ => null,
};

/// The domain QSO stored in [row].
Qso qsoFromRow(QsoRow row) {
  final fields = <String, String>{
    ...(jsonDecode(row.adifExtra) as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, '$v'),
    ),
  };
  for (final f in _textColumns) {
    final v = _text(row, f);
    if (v != null) fields[f] = v;
  }
  for (final f in _intColumns) {
    final v = _int(row, f);
    if (v != null) fields[f] = '$v';
  }
  if (row.txPwr case final p?) {
    fields['TX_PWR'] = p == p.roundToDouble() ? '${p.toInt()}' : '$p';
  }
  return Qso(
    id: row.id,
    accountId: row.accountId,
    stationProfileId: row.stationProfileId,
    call: Callsign.tryParse(row.call) ?? _corrupt('call', row.id),
    timeOn: UtcDateTime.fromMillis(row.timeOn),
    timeOff: row.timeOff == null ? null : UtcDateTime.fromMillis(row.timeOff!),
    band: Band.tryParse(row.band) ?? _corrupt('band', row.id),
    bandRx: row.bandRx == null ? null : Band.tryParse(row.bandRx!),
    mode:
        Mode.tryParse(row.mode, submode: row.submode) ??
        _corrupt('mode', row.id),
    freqHz: row.freqHz,
    freqRxHz: row.freqRxHz,
    rstSent: row.rstSent,
    rstRcvd: row.rstRcvd,
    fields: fields,
    source: QsoSource.values.asNameMap()[row.source] ?? QsoSource.manual,
    contestSessionId: row.contestSessionId,
    activationId: row.activationId,
  );
}

Never _corrupt(String what, String id) =>
    throw StateError('Stored QSO $id has an invalid $what');

/// Column values for [qso]. Sync metadata (HLC, device, rev) is added by
/// the repository.
QsosCompanion qsoToCompanion(Qso qso) {
  final extra = <String, String>{};
  final text = <String, String?>{};
  final ints = <String, int?>{};
  double? txPwr;
  for (final MapEntry(key: f, value: v) in qso.fields.entries) {
    if (_textColumns.contains(f)) {
      text[f] = v;
    } else if (_intColumns.contains(f) && int.tryParse(v) != null) {
      ints[f] = int.parse(v);
    } else if (f == 'TX_PWR' && double.tryParse(v) != null) {
      txPwr = double.parse(v);
    } else {
      extra[f] = v;
    }
  }
  Value<String?> t(String f) => Value(text[f]);
  Value<int?> i(String f) => Value(ints[f]);
  return QsosCompanion(
    id: Value(qso.id),
    accountId: Value(qso.accountId),
    stationProfileId: Value(qso.stationProfileId),
    call: Value(qso.call.value),
    timeOn: Value(qso.timeOn.millis),
    timeOff: Value(qso.timeOff?.millis),
    band: Value(qso.band.name),
    bandRx: Value(qso.bandRx?.name),
    mode: Value(qso.mode.mode),
    submode: Value(qso.mode.submode),
    freqHz: Value(qso.freqHz),
    freqRxHz: Value(qso.freqRxHz),
    rstSent: Value(qso.rstSent),
    rstRcvd: Value(qso.rstRcvd),
    name: t('NAME'),
    qth: t('QTH'),
    gridsquare: t('GRIDSQUARE'),
    dxcc: i('DXCC'),
    cqz: i('CQZ'),
    ituz: i('ITUZ'),
    state: t('STATE'),
    cnty: t('CNTY'),
    country: t('COUNTRY'),
    cont: t('CONT'),
    darcDok: t('DARC_DOK'),
    iota: t('IOTA'),
    sotaRef: t('SOTA_REF'),
    potaRef: t('POTA_REF'),
    wwffRef: t('WWFF_REF'),
    sig: t('SIG'),
    sigInfo: t('SIG_INFO'),
    mySotaRef: t('MY_SOTA_REF'),
    myPotaRef: t('MY_POTA_REF'),
    myWwffRef: t('MY_WWFF_REF'),
    mySig: t('MY_SIG'),
    mySigInfo: t('MY_SIG_INFO'),
    stationCallsign: t('STATION_CALLSIGN'),
    operator: t('OPERATOR'),
    myGridsquare: t('MY_GRIDSQUARE'),
    txPwr: Value(txPwr),
    contestId: t('CONTEST_ID'),
    srx: i('SRX'),
    stx: i('STX'),
    srxString: t('SRX_STRING'),
    stxString: t('STX_STRING'),
    check: t('CHECK'),
    qsoClass: t('CLASS'),
    precedence: t('PRECEDENCE'),
    arrlSect: t('ARRL_SECT'),
    propMode: t('PROP_MODE'),
    satName: t('SAT_NAME'),
    satMode: t('SAT_MODE'),
    comment: t('COMMENT'),
    notes: t('NOTES'),
    qslVia: t('QSL_VIA'),
    adifExtra: Value(jsonEncode(extra)),
    contestSessionId: Value(qso.contestSessionId),
    activationId: Value(qso.activationId),
    source: Value(qso.source.name),
  );
}
