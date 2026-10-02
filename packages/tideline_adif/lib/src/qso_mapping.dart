import 'package:tideline_domain/tideline_domain.dart';

/// Why an ADIF record could not become a QSO.
enum AdifRejection {
  /// CALL missing or not a callsign.
  invalidCall,

  /// QSO_DATE / TIME_ON missing or invalid.
  invalidTime,

  /// Neither a valid BAND nor a FREQ inside an amateur band.
  invalidBand,

  /// MODE missing or not in the ADIF Mode enumeration.
  invalidMode,
}

/// Outcome of converting one ADIF record.
sealed class AdifImportResult {
  const new();
}

/// The record became [qso].
final class AdifImported extends AdifImportResult {
  /// Creates the result.
  const new(this.qso);

  /// The imported QSO.
  final Qso qso;
}

/// The record was rejected for [reasons].
final class AdifRejected extends AdifImportResult {
  /// Creates the result.
  const new(this.reasons);

  /// Every problem found (so the user can fix them all at once).
  final List<AdifRejection> reasons;
}

/// Converts between ADIF records and [Qso]s, losslessly for every field.
abstract final class AdifQsoMapping {
  /// Builds a QSO from an ADIF [record] (upper-case field names).
  static AdifImportResult fromRecord(
    Map<String, String> record, {
    required String id,
    required String accountId,
    String? stationProfileId,
  }) {
    final reasons = <AdifRejection>[];
    final call = Callsign.tryParse(record['CALL'] ?? '');
    if (call == null) reasons.add(AdifRejection.invalidCall);

    final timeOn = UtcDateTime.tryParseAdif(
      record['QSO_DATE'] ?? '',
      record['TIME_ON'] ?? '',
    );
    if (timeOn == null) reasons.add(AdifRejection.invalidTime);

    final freq = record['FREQ'] == null
        ? null
        : Frequency.fromAdifMhz(record['FREQ']!);
    final band =
        Band.tryParse(record['BAND'] ?? '') ??
        (freq == null ? null : Band.forFrequency(freq));
    if (band == null) reasons.add(AdifRejection.invalidBand);

    final mode = Mode.tryParse(
      record['MODE'] ?? '',
      submode: record['SUBMODE'],
    );
    if (mode == null) reasons.add(AdifRejection.invalidMode);

    if (reasons.isNotEmpty) return AdifRejected(reasons);

    final freqRx = record['FREQ_RX'] == null
        ? null
        : Frequency.fromAdifMhz(record['FREQ_RX']!);
    UtcDateTime? timeOff;
    if (record['TIME_OFF'] != null) {
      timeOff = UtcDateTime.tryParseAdif(
        record['QSO_DATE_OFF'] ?? record['QSO_DATE']!,
        record['TIME_OFF']!,
      );
      // An off time before the on time without QSO_DATE_OFF crossed midnight.
      if (timeOff != null &&
          record['QSO_DATE_OFF'] == null &&
          timeOff.millis < timeOn!.millis) {
        timeOff = UtcDateTime(timeOff.value.add(const Duration(days: 1)));
      }
    }

    return AdifImported(
      Qso(
        id: id,
        accountId: accountId,
        stationProfileId: stationProfileId,
        call: call!,
        timeOn: timeOn!,
        timeOff: timeOff,
        band: band!,
        bandRx: Band.tryParse(record['BAND_RX'] ?? ''),
        mode: mode!,
        freqHz: freq,
        freqRxHz: freqRx,
        rstSent: _nonEmpty(record['RST_SENT']),
        rstRcvd: _nonEmpty(record['RST_RCVD']),
        fields: record,
        source: QsoSource.import,
      ),
    );
  }

  /// The ADIF record for [qso]: core fields first, then everything else in
  /// name order.
  static Map<String, String> toRecord(Qso qso) => {
    'CALL': qso.call.value,
    'QSO_DATE': qso.timeOn.adifDate,
    'TIME_ON': qso.timeOn.adifTime,
    if (qso.timeOff case final off?) ...{
      'QSO_DATE_OFF': off.adifDate,
      'TIME_OFF': off.adifTime,
    },
    'BAND': qso.band.name,
    'BAND_RX': ?qso.bandRx?.name,
    'MODE': qso.mode.mode,
    'SUBMODE': ?qso.mode.submode,
    if (qso.freqHz case final f?) 'FREQ': Frequency.toAdifMhz(f),
    if (qso.freqRxHz case final f?) 'FREQ_RX': Frequency.toAdifMhz(f),
    'RST_SENT': ?qso.rstSent,
    'RST_RCVD': ?qso.rstRcvd,
    for (final name in qso.fields.keys.toList()..sort())
      name: qso.fields[name]!,
  };

  static String? _nonEmpty(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();
}
