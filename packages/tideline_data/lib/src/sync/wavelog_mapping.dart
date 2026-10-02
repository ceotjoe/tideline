import 'package:tideline_domain/tideline_domain.dart';

/// Fields Wavelog's `PATCH /qso/{id}` accepts (verified in
/// Qso_resource::editable_fields; docs/architecture/wavelog-api.md).
const _patchableStrings = [
  'call', 'band', 'band_rx', 'rst_sent', 'rst_rcvd', 'gridsquare', 'name', //
  'comment', 'notes', 'qth', 'prop_mode', 'sat_name', 'sat_mode',
  'sota_ref', 'pota_ref', 'wwff_ref', 'iota', 'sig', 'sig_info', 'darc_dok',
  'state', 'cnty', 'qsl_via', 'srx_string', 'stx_string',
];
const _patchableInts = ['cqz', 'ituz', 'srx', 'stx'];

String _two(int v) => v.toString().padLeft(2, '0');

/// The JSON body for `POST /qso` (without `station_profile_id`): lower-case
/// ADIF names, `qso_date` as YYYY-MM-DD, `time_on` as HH:MM:SS, frequencies
/// in Hz. `APP_*` fields are not sent (Wavelog drops them).
Map<String, Object> wavelogCreateFields(Qso qso) {
  final t = qso.timeOn.value;
  final out = <String, Object>{
    for (final MapEntry(:key, :value) in qso.fields.entries)
      if (!key.startsWith('APP_') && !key.startsWith('USERDEF'))
        key.toLowerCase(): value,
    'call': qso.call.value,
    'qso_date': '${t.year}-${_two(t.month)}-${_two(t.day)}',
    'time_on': '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}',
    'band': qso.band.name,
    'mode': qso.mode.mode,
    'submode': ?qso.mode.submode,
    'band_rx': ?qso.bandRx?.name,
    'freq': ?qso.freqHz,
    'freq_rx': ?qso.freqRxHz,
    'rst_sent': ?qso.rstSent,
    'rst_rcvd': ?qso.rstRcvd,
  };
  if (qso.timeOff case final off?) {
    out['qso_date_off'] = off.adifDate;
    out['time_off'] = off.adifTime;
  }
  return out;
}

/// The JSON body for `PATCH /qso/{id}`: every patchable field, with empty
/// strings for cleared text fields so the server matches the local copy.
Map<String, Object> wavelogPatchFields(Qso qso) {
  final all = <String, String?>{
    'call': qso.call.value,
    'band': qso.band.name,
    'band_rx': qso.bandRx?.name,
    'rst_sent': qso.rstSent,
    'rst_rcvd': qso.rstRcvd,
    for (final MapEntry(:key, :value) in qso.fields.entries)
      key.toLowerCase(): value,
  };
  return {
    for (final f in _patchableStrings) f: all[f] ?? '',
    for (final f in _patchableInts) f: ?int.tryParse(all[f] ?? ''),
  };
}
