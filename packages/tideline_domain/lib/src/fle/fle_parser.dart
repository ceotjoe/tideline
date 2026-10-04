import 'package:meta/meta.dart';
import 'package:tideline_domain/src/qso/qso.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/callsign.dart';
import 'package:tideline_domain/src/values/maidenhead.dart';
import 'package:tideline_domain/src/values/mode.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

/// Why a line of Fast Log Entry text cannot be used. The line is left out;
/// nothing about it is guessed. See docs/architecture/fle.md.
enum FleProblem {
  /// A word that is not part of the shorthand.
  unknownToken,

  /// A bracket that is never closed.
  unclosedBracket,

  /// A time like `2575`, or a time fragment without a time before it.
  invalidTime,

  /// A QSO needs a time and the line has none and none came before.
  missingTime,

  /// The line has a time, report, locator or other QSO part but no callsign.
  missingCall,

  /// No band (or frequency) was given before this QSO.
  missingBand,

  /// No mode was given before this QSO.
  missingMode,

  /// A band that Tideline does not know (for example `sat`).
  unsupportedBand,

  /// A frequency outside every amateur band.
  frequencyOutsideBands,

  /// `date` is not a real date.
  invalidDate,

  /// `day +` with too many plus signs.
  invalidDayShift,

  /// `timezone` or `tzofs` with a value outside −12 … +14.
  invalidTimezone,

  /// A second callsign on one line (one QSO per line).
  secondCallsign,

  /// A second locator or reference of the same kind on one line.
  duplicateSegment,

  /// A signal report before the callsign (reports come after it).
  reportBeforeCall,

  /// More than two signal reports on a line.
  tooManyReports,

  /// A report that does not fit the mode (for example 4 digits).
  invalidReport,

  /// `<name:value>` with an invalid ADIF field name.
  invalidFieldName,

  /// `<name:value>` for a field that has its own segment, or that Tideline
  /// sets (own station, activation).
  reservedField,

  /// A field value that is too long.
  valueTooLong,

  /// A line longer than the limit.
  lineTooLong,

  /// More lines than the limit; the rest is not read.
  tooManyLines,
}

/// Something worth a second look that does not stop a QSO from being logged.
enum FleWarning {
  /// The QSO is earlier than the one before it (a missing `day +`?).
  timeWentBackwards,

  /// The QSO is in the future.
  futureTime,
}

/// One QSO read from the shorthand.
@immutable
class FleQso {
  /// Creates a QSO.
  const new({
    required this.call,
    required this.timeOn,
    required this.band,
    required this.mode,
    required this.rstSent,
    required this.rstRcvd,
    this.freqHz,
    this.fields = const {},
  });

  /// The contacted callsign, upper case.
  final String call;

  /// Start of the contact, UTC.
  final UtcDateTime timeOn;

  /// Band.
  final Band band;

  /// Mode and submode.
  final Mode mode;

  /// Frequency in hertz, only if the text gave one.
  final int? freqHz;

  /// Report sent (the mode's default if the text had none).
  final String rstSent;

  /// Report received (the mode's default if the text had none).
  final String rstRcvd;

  /// Further ADIF fields (`NAME`, `GRIDSQUARE`, `SOTA_REF`, …).
  final Map<String, String> fields;

  /// The QSO for the log, with [id] for [accountId] on [stationProfileId].
  Qso toQso({
    required String id,
    required String accountId,
    String? stationProfileId,
    Map<String, String> extraFields = const {},
  }) => Qso(
    id: id,
    accountId: accountId,
    stationProfileId: stationProfileId,
    call: Callsign.tryParse(call)!,
    timeOn: timeOn,
    band: band,
    mode: mode,
    freqHz: freqHz,
    rstSent: rstSent,
    rstRcvd: rstRcvd,
    fields: {...fields, ...extraFields},
    source: QsoSource.fle,
  );
}

/// One non-empty line of the input and what was made of it.
@immutable
sealed class FleLine {
  const new(this.number, this.text);

  /// 1-based line number in the input.
  final int number;

  /// The line as typed.
  final String text;
}

/// A line that sets band, mode, frequency, date, day or time zone for the
/// QSOs after it.
final class FleHeaderLine extends FleLine {
  /// Creates the line.
  const new(super.number, super.text);
}

/// A line that is one QSO.
final class FleQsoLine extends FleLine {
  /// Creates the line.
  const new(super.number, super.text, this.qso, this.warnings);

  /// The QSO.
  final FleQso qso;

  /// Things to look at; the QSO can still be logged.
  final List<FleWarning> warnings;
}

/// A line that cannot be used.
final class FleErrorLine extends FleLine {
  /// Creates the line.
  const new(super.number, super.text, this.problem, [this.token]);

  /// What is wrong.
  final FleProblem problem;

  /// The word it is about, if there is one.
  final String? token;
}

/// The result of reading a text.
@immutable
class FleResult {
  /// Creates a result.
  const new(this.lines);

  /// Every non-empty line, in order.
  final List<FleLine> lines;

  /// The QSOs, in order.
  List<FleQso> get qsos => [
    for (final l in lines)
      if (l is FleQsoLine) l.qso,
  ];

  /// The lines that cannot be used.
  List<FleErrorLine> get errors => [
    for (final l in lines)
      if (l is FleErrorLine) l,
  ];

  /// Whether any line cannot be used.
  bool get hasErrors => lines.any((l) => l is FleErrorLine);
}

/// Reads Fast Log Entry shorthand, in the dialect of Wavelog's SimpleFLE.
///
/// Pure and total: any text gives a [FleResult] and never throws. One QSO per
/// line; band, mode, frequency, date and time zone lines (or words) apply to
/// the QSOs after them. A line with a problem is reported and left out whole,
/// and does not change what the following lines inherit.
class FleParser {
  /// Creates a parser with limits for untrusted text.
  const new({
    this.maxLines = 5000,
    this.maxLineLength = 500,
    this.maxFieldValue = 256,
  });

  /// More lines than this are not read (one [FleProblem.tooManyLines]).
  final int maxLines;

  /// Longer lines are refused.
  final int maxLineLength;

  /// Longest value of a `<name:value>` field.
  final int maxFieldValue;

  static final RegExp _day = RegExp(r'^day\s+(\++)$', caseSensitive: false);
  static final RegExp _date = RegExp(
    r'^(?:date\s+)?(\d{4})-(\d{2})-(\d{2})$',
    caseSensitive: false,
  );
  static final RegExp _zone = RegExp(
    r'^(?:timezone|tzofs)\s+([+-]?\d{1,2})$',
    caseSensitive: false,
  );
  static final RegExp _time = RegExp(r'^([0-2][0-9])([0-5][0-9])$');
  static final RegExp _band = RegExp(r'^\d{1,4}(?:m|cm|mm)$|^sat$');
  static final RegExp _freq = RegExp(r'^\d{1,6}\.\d{1,6}$');
  static final RegExp _fragment1 = RegExp(r'^[1-9]$');
  static final RegExp _fragment2 = RegExp(r'^[0-5][0-9]$');
  static final RegExp _locator = RegExp(
    r'^#?([A-R]{2}[0-9]{2}(?:[A-X]{2}(?:[0-9]{2})?)?)$',
  );
  static final RegExp _report = RegExp(
    r'^[-+]\d{1,2}$|^\d{1,3}$|^\d{1,3}[-+]\d{1,2}$',
  );
  static final RegExp _name = RegExp(r'^@(\p{L}+)$', unicode: true);
  static final RegExp _exchangeToken = RegExp(
    r'^(?:[.,](?:\+[+0]|-|[A-Za-z0-9/]+))+$',
  );
  static final RegExp _exchangePart = RegExp(r'([.,])(\+[+0]|-|[A-Za-z0-9/]+)');
  static final RegExp _sota = RegExp(r'^[A-Z0-9]{1,3}/[A-Z]{2}-\d{3}$');
  static final RegExp _iota = RegExp(r'^[AENOS]*[FNSUACA]-\d{3}$');
  static final RegExp _pota = RegExp(
    r'^(?!.*FF)[A-Z0-9]{1,3}-\d{4,5}(?:,(?!.*FF)[A-Z0-9]{1,3}-\d{4,5})*$',
  );
  static final RegExp _wwff = RegExp(r'^[A-Z0-9]{1,3}FF-\d{4}$');
  static final RegExp _fieldName = RegExp(r'^[A-Za-z][A-Za-z0-9_]{0,31}$');
  static final RegExp _control = RegExp(r'[\u0000-\u001F\u007F]');

  /// Fields that have their own segment or that Tideline sets itself.
  static const Set<String> _reserved = {
    ...Qso.coreFieldNames,
    'NAME',
    'GRIDSQUARE',
    'SOTA_REF',
    'POTA_REF',
    'WWFF_REF',
    'IOTA',
    'COMMENT',
    'QSLMSG',
    'STX',
    'SRX',
    'STX_STRING',
    'SRX_STRING',
    'CONTEST_ID',
    'STATION_CALLSIGN',
    'OPERATOR',
    'APP_TIDELINE_FLE',
  };

  /// Reads [text]. [todayUtc] is the date QSOs get until a `date` or `day`
  /// line says otherwise (only its UTC date is used); with [nowUtc], QSOs in
  /// the future get a warning.
  FleResult parse(String text, {required DateTime todayUtc, DateTime? nowUtc}) {
    final lines = <FleLine>[];
    var state = _State(
      date: DateTime.utc(todayUtc.year, todayUtc.month, todayUtc.day),
    );
    var number = 0;
    for (final raw in text.split(RegExp(r'\r\n|\n|\r'))) {
      number++;
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (lines.length >= maxLines) {
        lines.add(FleErrorLine(number, '', FleProblem.tooManyLines));
        break;
      }
      if (line.length > maxLineLength) {
        lines.add(
          FleErrorLine(number, line.substring(0, 60), FleProblem.lineTooLong),
        );
        continue;
      }
      final outcome = _line(line, state, nowUtc);
      switch (outcome) {
        case _Fail(:final problem, :final token):
          lines.add(FleErrorLine(number, line, problem, token));
        case _Header(:final next):
          state = next;
          lines.add(FleHeaderLine(number, line));
        case _Done(:final next, :final qso, :final warnings):
          state = next;
          lines.add(FleQsoLine(number, line, qso, warnings));
      }
    }
    return FleResult(List.unmodifiable(lines));
  }

  _Outcome _line(String line, _State s, DateTime? nowUtc) {
    final day = _day.firstMatch(line);
    if (day != null) {
      final plus = day.group(1)!.length;
      if (plus > 31) return const _Fail(FleProblem.invalidDayShift);
      return _Header(s.copyWith(date: s.date.add(Duration(days: plus))));
    }
    final date = _date.firstMatch(line);
    if (date != null) {
      final y = int.parse(date.group(1)!);
      final m = int.parse(date.group(2)!);
      final d = int.parse(date.group(3)!);
      final parsed = DateTime.utc(y, m, d);
      if (y < 1930 || parsed.month != m || parsed.day != d) {
        return _Fail(FleProblem.invalidDate, line);
      }
      return _Header(s.copyWith(date: parsed));
    }
    final zone = _zone.firstMatch(line);
    if (zone != null) {
      final hours = int.parse(zone.group(1)!);
      if (hours < -12 || hours > 14) {
        return _Fail(FleProblem.invalidTimezone, zone.group(1));
      }
      return _Header(s.copyWith(zone: hours));
    }
    return _qsoOrHeader(line, s, nowUtc);
  }

  _Outcome _qsoOrHeader(String line, _State state, DateTime? nowUtc) {
    // Brackets first, as Wavelog does: [message] and <comment> or <field:v>.
    var rest = line;
    final messages = <String>[];
    rest = rest.replaceAllMapped(RegExp(r'\[([^\]]*)\]'), (m) {
      messages.add(m.group(1)!.trim());
      return ' ';
    });
    final angled = <String>[];
    rest = rest.replaceAllMapped(RegExp('<([^>]*)>'), (m) {
      angled.add(m.group(1)!);
      return ' ';
    });
    if (rest.contains('[') ||
        rest.contains(']') ||
        rest.contains('<') ||
        rest.contains('>')) {
      return const _Fail(FleProblem.unclosedBracket);
    }

    final tokens = rest.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    var s = state;
    var time = s.time;
    String? call;
    final reports = <String>[];
    final fields = <String, String>{};
    String? sentExchange;
    String? sentString;
    String? rcvdExchange;
    String? rcvdString;
    var clearSent = false;
    var autoIncrement = s.autoIncrement;
    var qsoPart = false;
    var stateChange = false;

    var i = -1;
    for (final token in tokens) {
      i++;
      final u = token.toUpperCase();

      final t = _time.firstMatch(u);
      if (t == null && RegExp(r'^\d{4}$').hasMatch(u)) {
        // Four digits are a time or nothing: 2575 is a mistake, not a report.
        return _Fail(FleProblem.invalidTime, token);
      }
      if (t != null) {
        if (int.parse(t.group(1)!) > 23) {
          return _Fail(FleProblem.invalidTime, token);
        }
        time = u;
        qsoPart = true;
        continue;
      }
      final mode = Mode.tryParse(u);
      if (mode != null) {
        s = s.copyWith(mode: mode);
        stateChange = true;
        continue;
      }
      if (_band.hasMatch(token.toLowerCase())) {
        final band = Band.tryParse(token);
        if (band == null) return _Fail(FleProblem.unsupportedBand, token);
        s = s.copyWith(band: band, clearFreq: true);
        stateChange = true;
        continue;
      }
      if (_freq.hasMatch(token)) {
        final hz = (double.parse(token) * 1e6).round();
        final band = Band.forFrequency(hz);
        if (band == null) return _Fail(FleProblem.frequencyOutsideBands, token);
        s = s.copyWith(band: band, freqHz: hz);
        stateChange = true;
        continue;
      }
      if (i == 0 &&
          (_fragment1.hasMatch(token) || _fragment2.hasMatch(token))) {
        if (time == null) return _Fail(FleProblem.missingTime, token);
        time = _fragment1.hasMatch(token)
            ? time.substring(0, 3) + token
            : time.substring(0, 2) + token;
        qsoPart = true;
        continue;
      }
      final ref = _reference(u);
      if (ref != null) {
        if (fields.containsKey(ref.$1)) {
          return _Fail(FleProblem.duplicateSegment, token);
        }
        fields[ref.$1] = ref.$2;
        qsoPart = true;
        continue;
      }
      if (call == null && _looksLikeCall(u)) {
        call = u;
        qsoPart = true;
        continue;
      }
      final loc = _locator.firstMatch(u);
      if (loc != null) {
        if (fields.containsKey('GRIDSQUARE')) {
          return _Fail(FleProblem.duplicateSegment, token);
        }
        fields['GRIDSQUARE'] = Maidenhead.normalize(loc.group(1)!)!;
        qsoPart = true;
        continue;
      }
      if (call != null && _looksLikeCall(u)) {
        return _Fail(FleProblem.secondCallsign, token);
      }
      if (i > 0 && _report.hasMatch(token)) {
        if (call == null) return _Fail(FleProblem.reportBeforeCall, token);
        if (reports.length == 2) return _Fail(FleProblem.tooManyReports, token);
        reports.add(token);
        qsoPart = true;
        continue;
      }
      if (i > 0 && _exchangeToken.hasMatch(token)) {
        for (final m in _exchangePart.allMatches(token)) {
          final sep = m.group(1)!;
          final value = m.group(2)!;
          if (sep == ',') {
            if (value == '-') {
              clearSent = true;
            } else if (value == '++') {
              autoIncrement = true;
            } else if (value == '+0') {
              autoIncrement = false;
            } else if (RegExp(r'^\d+$').hasMatch(value)) {
              sentExchange = value;
            } else if (value.isNotEmpty) {
              sentString = value.toUpperCase();
            }
          } else if (RegExp(r'^\d+$').hasMatch(value)) {
            rcvdExchange = value;
          } else if (value.isNotEmpty) {
            rcvdString = value.toUpperCase();
          }
        }
        qsoPart = true;
        continue;
      }
      final name = _name.firstMatch(token);
      if (i > 0 && name != null) {
        fields['NAME'] = name.group(1)!;
        qsoPart = true;
        continue;
      }
      return _Fail(FleProblem.unknownToken, token);
    }

    // Brackets: [message], <comment>, <field:value>.
    final comments = <String>[];
    var txPwr = s.txPwr;
    for (final a in angled) {
      final kv = RegExp(
        r'^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$',
        dotAll: true,
      ).firstMatch(a);
      if (kv == null) {
        final c = _clean(a);
        if (c.isNotEmpty) comments.add(c);
        qsoPart = true;
        continue;
      }
      final key = kv.group(1)!.toUpperCase();
      if (!_fieldName.hasMatch(key)) {
        return _Fail(FleProblem.invalidFieldName, kv.group(1));
      }
      if (key.startsWith('MY_') || _reserved.contains(key)) {
        if (key != 'TX_PWR') return _Fail(FleProblem.reservedField, key);
      }
      final value = _clean(kv.group(2)!);
      if (value.length > maxFieldValue) {
        return _Fail(FleProblem.valueTooLong, key);
      }
      if (key == 'TX_PWR') {
        txPwr = value.isEmpty ? null : value;
      } else if (value.isNotEmpty) {
        fields[key] = value;
      }
      qsoPart = true;
    }
    final message = messages.map(_clean).where((m) => m.isNotEmpty).join(' ');
    if (message.length > maxFieldValue) {
      return const _Fail(FleProblem.valueTooLong, 'QSLMSG');
    }
    if (message.isNotEmpty) fields['QSLMSG'] = message;
    if (messages.isNotEmpty) qsoPart = true;
    final comment = comments.join(' ');
    if (comment.length > maxFieldValue) {
      return const _Fail(FleProblem.valueTooLong, 'COMMENT');
    }
    if (comment.isNotEmpty) fields['COMMENT'] = comment;

    if (call == null) {
      if (qsoPart) return const _Fail(FleProblem.missingCall);
      if (!stateChange) return const _Fail(FleProblem.unknownToken);
      return _Header(s);
    }

    final band = s.band;
    final modeNow = s.mode;
    if (time == null) return const _Fail(FleProblem.missingTime);
    if (band == null) return const _Fail(FleProblem.missingBand);
    if (modeNow == null) return const _Fail(FleProblem.missingMode);

    final rstSent = _report1(reports.isNotEmpty ? reports[0] : null, modeNow);
    final rstRcvd = _report1(reports.length > 1 ? reports[1] : null, modeNow);
    if (rstSent == null || rstRcvd == null) {
      return _Fail(
        FleProblem.invalidReport,
        reports.firstWhere(
          (r) => _report1(r, modeNow) == null,
          orElse: () => '',
        ),
      );
    }

    // Contest exchange: the sent part stays for the QSOs after it and counts
    // up with `,++`; it is written to a QSO only when a received part is.
    var sentNumber = clearSent ? null : s.sentNumber;
    var sentText = clearSent ? null : s.sentString;
    if (sentExchange != null) sentNumber = int.tryParse(sentExchange);
    if (sentString != null) sentText = sentString;
    final hasReceived = rcvdExchange != null || rcvdString != null;
    if (hasReceived) {
      if (sentNumber != null) fields['STX'] = '$sentNumber';
      if (sentText != null) fields['STX_STRING'] = sentText;
      if (rcvdExchange != null) fields['SRX'] = rcvdExchange;
      if (rcvdString != null) fields['SRX_STRING'] = rcvdString;
    }
    final nextSent = hasReceived && autoIncrement && sentNumber != null
        ? sentNumber + 1
        : sentNumber;
    if (txPwr != null) fields['TX_PWR'] = txPwr;

    final hh = int.parse(time.substring(0, 2));
    final mm = int.parse(time.substring(2));
    final local = DateTime.utc(s.date.year, s.date.month, s.date.day, hh, mm);
    final utc = local.subtract(Duration(hours: s.zone));
    final timeOn = UtcDateTime(utc);

    final warnings = <FleWarning>[
      if (s.lastQso != null && utc.isBefore(s.lastQso!))
        FleWarning.timeWentBackwards,
      if (nowUtc != null && utc.isAfter(nowUtc.add(const Duration(minutes: 5))))
        FleWarning.futureTime,
    ];

    final qso = FleQso(
      call: call,
      timeOn: timeOn,
      band: band,
      mode: modeNow,
      freqHz: s.freqHz,
      rstSent: rstSent,
      rstRcvd: rstRcvd,
      fields: Map.unmodifiable(fields),
    );
    return _Done(
      s.copyWith(
        time: time,
        lastQso: utc,
        txPwr: txPwr,
        clearTxPwr: txPwr == null,
        sentNumber: nextSent,
        clearSentNumber: nextSent == null,
        sentString: sentText,
        clearSentString: sentText == null,
        autoIncrement: autoIncrement,
      ),
      qso,
      warnings,
    );
  }

  static String _clean(String v) =>
      v.replaceAll(_control, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  /// A reference as (ADIF field, value), or null.
  static (String, String)? _reference(String u) {
    if (_sota.hasMatch(u)) return ('SOTA_REF', u);
    if (_iota.hasMatch(u)) return ('IOTA', u);
    if (_pota.hasMatch(u)) return ('POTA_REF', u);
    if (_wwff.hasMatch(u)) return ('WWFF_REF', u);
    return null;
  }

  /// A callsign as Wavelog reads one: it ends in a letter, so a four-digit
  /// locator such as `JO62` is not taken for one.
  static bool _looksLikeCall(String u) {
    final base = Callsign.tryParse(u)?.baseCall;
    if (base == null) return false;
    return RegExp(r'[A-Z]$').hasMatch(base);
  }

  /// The report for [mode] from what was typed, or null if it does not fit.
  /// No report typed: the mode's default.
  static String? _report1(String? raw, Mode mode) {
    if (raw == null) return mode.defaultReport;
    final signedInside = RegExp(r'^\d{1,3}[-+]\d{1,2}$').hasMatch(raw);
    if (mode.usesDbReports) {
      final m = RegExp(r'^([-+])?(\d{1,2})$').firstMatch(raw);
      if (m == null) return null;
      return '${m.group(1) ?? '+'}${m.group(2)}';
    }
    if (signedInside) return raw;
    if (!RegExp(r'^\d{1,3}$').hasMatch(raw)) return null;
    if (mode.isPhone) {
      return switch (raw.length) {
        1 => '5$raw',
        2 => raw,
        _ => raw.substring(0, 2),
      };
    }
    return switch (raw.length) {
      1 => '5${raw}9',
      2 => '${raw}9',
      _ => raw,
    };
  }
}

@immutable
class _State {
  const new({
    required this.date,
    this.zone = 0,
    this.band,
    this.mode,
    this.freqHz,
    this.time,
    this.lastQso,
    this.txPwr,
    this.sentNumber,
    this.sentString,
    this.autoIncrement = false,
  });

  final DateTime date;
  final int zone;
  final Band? band;
  final Mode? mode;
  final int? freqHz;
  final String? time;
  final DateTime? lastQso;
  final String? txPwr;
  final int? sentNumber;
  final String? sentString;
  final bool autoIncrement;

  _State copyWith({
    DateTime? date,
    int? zone,
    Band? band,
    Mode? mode,
    int? freqHz,
    bool clearFreq = false,
    String? time,
    DateTime? lastQso,
    String? txPwr,
    bool clearTxPwr = false,
    int? sentNumber,
    bool clearSentNumber = false,
    String? sentString,
    bool clearSentString = false,
    bool? autoIncrement,
  }) => _State(
    date: date ?? this.date,
    zone: zone ?? this.zone,
    band: band ?? this.band,
    mode: mode ?? this.mode,
    freqHz: clearFreq ? null : (freqHz ?? this.freqHz),
    time: time ?? this.time,
    lastQso: lastQso ?? this.lastQso,
    txPwr: clearTxPwr ? null : (txPwr ?? this.txPwr),
    sentNumber: clearSentNumber ? null : (sentNumber ?? this.sentNumber),
    sentString: clearSentString ? null : (sentString ?? this.sentString),
    autoIncrement: autoIncrement ?? this.autoIncrement,
  );
}

sealed class _Outcome {
  const new();
}

final class _Fail extends _Outcome {
  const new(this.problem, [this.token]);

  final FleProblem problem;
  final String? token;
}

final class _Header extends _Outcome {
  const new(this.next);

  final _State next;
}

final class _Done extends _Outcome {
  const new(this.next, this.qso, this.warnings);

  final _State next;
  final FleQso qso;
  final List<FleWarning> warnings;
}
