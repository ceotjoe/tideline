import 'package:meta/meta.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/callsign.dart';
import 'package:tideline_domain/src/values/mode.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

/// Where a QSO came from.
enum QsoSource {
  /// Typed in the logging screen.
  manual,

  /// Fast Log Entry.
  fle,

  /// Imported from an ADIF file.
  import,

  /// Received from a paired Tideline device.
  peer,

  /// Logged by WSJT-X.
  wsjtx,
}

/// A logged contact.
///
/// The fields that every QSO needs are typed. Every other ADIF field lives
/// in [fields], keyed by its upper-case ADIF name (`NAME`, `GRIDSQUARE`,
/// `SOTA_REF`, `APP_X_Y`, …), so that import and export are lossless.
@immutable
class Qso {
  /// Creates a QSO.
  new({
    required this.id,
    required this.accountId,
    required this.call,
    required this.timeOn,
    required this.band,
    required this.mode,
    this.stationProfileId,
    this.timeOff,
    this.bandRx,
    this.freqHz,
    this.freqRxHz,
    this.rstSent,
    this.rstRcvd,
    Map<String, String> fields = const {},
    this.source = QsoSource.manual,
    this.contestSessionId,
    this.activationId,
  }) : fields = Map.unmodifiable({
         for (final MapEntry(:key, :value) in fields.entries)
           if (value.isNotEmpty && !coreFieldNames.contains(key.toUpperCase()))
             key.toUpperCase(): value,
       });

  /// ADIF fields represented by typed properties instead of [fields].
  static const Set<String> coreFieldNames = {
    'CALL',
    'QSO_DATE',
    'TIME_ON',
    'QSO_DATE_OFF',
    'TIME_OFF',
    'BAND',
    'BAND_RX',
    'MODE',
    'SUBMODE',
    'FREQ',
    'FREQ_RX',
    'RST_SENT',
    'RST_RCVD',
  };

  /// Local UUID.
  final String id;

  /// Owning Wavelog account.
  final String accountId;

  /// Local id of the station profile; null while it is still a draft.
  final String? stationProfileId;

  /// The contacted station.
  final Callsign call;

  /// Start of the contact (ADIF QSO_DATE + TIME_ON).
  final UtcDateTime timeOn;

  /// End of the contact, if recorded.
  final UtcDateTime? timeOff;

  /// Transmit band.
  final Band band;

  /// Receive band for split/cross-band contacts.
  final Band? bandRx;

  /// Mode and submode.
  final Mode mode;

  /// Transmit frequency in hertz.
  final int? freqHz;

  /// Receive frequency in hertz.
  final int? freqRxHz;

  /// Report sent.
  final String? rstSent;

  /// Report received.
  final String? rstRcvd;

  /// All other ADIF fields by upper-case name. Never contains core fields.
  final Map<String, String> fields;

  /// Origin of the QSO.
  final QsoSource source;

  /// Contest session the QSO belongs to, if any.
  final String? contestSessionId;

  /// Activation the QSO belongs to, if any.
  final String? activationId;

  /// The ADIF field [name] (upper case), or null.
  String? field(String name) => fields[name.toUpperCase()];

  /// The fields Wavelog cannot change on an uploaded QSO (PATCH treats them
  /// as read-only). Changing them requires "replace on server" (ADR 0016).
  static bool changesServerReadOnlyFields(Qso a, Qso b) =>
      a.timeOn.toMinute != b.timeOn.toMinute ||
      a.mode != b.mode ||
      a.freqHz != b.freqHz ||
      a.freqRxHz != b.freqRxHz ||
      a.stationProfileId != b.stationProfileId;

  /// Wavelog's duplicate key: call, start minute, band, mode (station is
  /// compared separately). See ADR 0008.
  ({String call, int minuteMillis, String band, String mode}) get dupeKey => (
    call: call.value,
    minuteMillis: timeOn.toMinute.millis,
    band: band.name,
    mode: mode.mode,
  );

  /// A copy with the given fields replaced.
  Qso copyWith({
    String? stationProfileId,
    Callsign? call,
    UtcDateTime? timeOn,
    UtcDateTime? timeOff,
    Band? band,
    Band? bandRx,
    Mode? mode,
    int? freqHz,
    int? freqRxHz,
    String? rstSent,
    String? rstRcvd,
    Map<String, String>? fields,
    String? contestSessionId,
    String? activationId,
  }) => Qso(
    id: id,
    accountId: accountId,
    stationProfileId: stationProfileId ?? this.stationProfileId,
    call: call ?? this.call,
    timeOn: timeOn ?? this.timeOn,
    timeOff: timeOff ?? this.timeOff,
    band: band ?? this.band,
    bandRx: bandRx ?? this.bandRx,
    mode: mode ?? this.mode,
    freqHz: freqHz ?? this.freqHz,
    freqRxHz: freqRxHz ?? this.freqRxHz,
    rstSent: rstSent ?? this.rstSent,
    rstRcvd: rstRcvd ?? this.rstRcvd,
    fields: fields ?? this.fields,
    source: source,
    contestSessionId: contestSessionId ?? this.contestSessionId,
    activationId: activationId ?? this.activationId,
  );
}
