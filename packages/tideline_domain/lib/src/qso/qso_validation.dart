import 'package:tideline_domain/src/qso/qso.dart';
import 'package:tideline_domain/src/values/maidenhead.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

/// Something wrong or worth checking about a QSO. The UI maps each value to
/// a localised, plain-language message.
enum QsoIssue {
  /// The frequency is outside the selected band.
  frequencyOutsideBand(blocking: true),

  /// The contacted station's locator is not a valid Maidenhead locator.
  invalidGridsquare(blocking: true),

  /// The QSO starts more than 10 minutes in the future (clock problem?).
  timeInFuture(blocking: false),

  /// TIME_OFF is before TIME_ON.
  timeOffBeforeTimeOn(blocking: true),

  /// No station location: the QSO is saved but cannot sync yet.
  noStationProfile(blocking: false);

  new({required this.blocking});

  /// Whether the QSO cannot be saved until this is fixed.
  final bool blocking;
}

/// Checks a QSO. Nothing here touches the network: validation is offline.
List<QsoIssue> validateQso(Qso qso, {UtcDateTime? now}) {
  final issues = <QsoIssue>[];
  final freq = qso.freqHz;
  if (freq != null && !qso.band.contains(freq)) {
    issues.add(QsoIssue.frequencyOutsideBand);
  }
  final grid = qso.field('GRIDSQUARE');
  if (grid != null && Maidenhead.normalize(grid) == null) {
    issues.add(QsoIssue.invalidGridsquare);
  }
  final reference = (now ?? UtcDateTime.now()).millis;
  if (qso.timeOn.millis >
      reference + const Duration(minutes: 10).inMilliseconds) {
    issues.add(QsoIssue.timeInFuture);
  }
  final off = qso.timeOff;
  if (off != null && off.millis < qso.timeOn.millis) {
    issues.add(QsoIssue.timeOffBeforeTimeOn);
  }
  if (qso.stationProfileId == null) issues.add(QsoIssue.noStationProfile);
  return issues;
}
