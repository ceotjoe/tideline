import 'package:meta/meta.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Cabrillo 3.0 mode column values.
enum CabrilloMode {
  /// `CW`.
  cw('CW'),

  /// `PH` (SSB, AM and other voice except FM).
  phone('PH'),

  /// `FM`.
  fm('FM'),

  /// `RY` (RTTY).
  rtty('RY'),

  /// `DG` (other digital modes).
  digi('DG');

  new(this.code);

  /// The token written to the log.
  final String code;
}

/// A period of declared off time (`OFFTIME:`).
@immutable
class CabrilloOffTime {
  /// Creates an off-time span from [from] to [to].
  const new(this.from, this.to);

  /// Start of the off time.
  final UtcDateTime from;

  /// End of the off time.
  final UtcDateTime to;
}

/// Cabrillo header fields. Contains no contest rules.
///
/// All strings are untrusted; the writer sanitises them.
@immutable
class CabrilloHeader {
  /// Creates a header. [createdBy] should read like `Tideline 1.2.3`.
  const new({
    required this.contest,
    required this.callsign,
    required this.createdBy,
    this.location,
    this.categoryOperator,
    this.categoryAssisted,
    this.categoryBand,
    this.categoryMode,
    this.categoryPower,
    this.categoryStation,
    this.categoryTransmitter,
    this.categoryOverlay,
    this.categoryTime,
    this.claimedScore,
    this.club,
    this.email,
    this.gridLocator,
    this.name,
    this.addressLines = const [],
    this.addressCity,
    this.addressStateProvince,
    this.addressPostalCode,
    this.addressCountry,
    this.operators,
    this.offTimes = const [],
    this.soapbox = const [],
  });

  /// Cabrillo contest name, for example `CQ-WW-SSB`.
  final String contest;

  /// Station callsign used in the contest.
  final String callsign;

  /// `CREATED-BY` value.
  final String createdBy;

  /// `LOCATION` (ARRL/RAC section or similar).
  final String? location;

  /// `CATEGORY-OPERATOR`.
  final String? categoryOperator;

  /// `CATEGORY-ASSISTED`.
  final String? categoryAssisted;

  /// `CATEGORY-BAND`.
  final String? categoryBand;

  /// `CATEGORY-MODE`.
  final String? categoryMode;

  /// `CATEGORY-POWER`.
  final String? categoryPower;

  /// `CATEGORY-STATION`.
  final String? categoryStation;

  /// `CATEGORY-TRANSMITTER`.
  final String? categoryTransmitter;

  /// `CATEGORY-OVERLAY`.
  final String? categoryOverlay;

  /// `CATEGORY-TIME`.
  final String? categoryTime;

  /// `CLAIMED-SCORE`.
  final int? claimedScore;

  /// `CLUB`.
  final String? club;

  /// `EMAIL`.
  final String? email;

  /// `GRID-LOCATOR`.
  final String? gridLocator;

  /// `NAME`.
  final String? name;

  /// `ADDRESS` lines (at most 6, each at most 45 characters).
  final List<String> addressLines;

  /// `ADDRESS-CITY`.
  final String? addressCity;

  /// `ADDRESS-STATE-PROVINCE`.
  final String? addressStateProvince;

  /// `ADDRESS-POSTALCODE`.
  final String? addressPostalCode;

  /// `ADDRESS-COUNTRY`.
  final String? addressCountry;

  /// `OPERATORS`.
  final String? operators;

  /// `OFFTIME` entries.
  final List<CabrilloOffTime> offTimes;

  /// `SOAPBOX` lines.
  final List<String> soapbox;
}

/// One contact line. The writer does not interpret exchange contents.
@immutable
class CabrilloQso {
  /// Creates a QSO line.
  const new({
    required this.frequencyHz,
    required this.mode,
    required this.time,
    required this.myCall,
    required this.sentExchange,
    required this.theirCall,
    required this.receivedExchange,
    this.band,
    this.transmitterId,
  });

  /// Frequency in Hz; 0 or negative if unknown (then [band] is used).
  final int frequencyHz;

  /// Cabrillo mode.
  final CabrilloMode mode;

  /// QSO time (UTC).
  final UtcDateTime time;

  /// Own callsign.
  final String myCall;

  /// Ordered sent exchange tokens.
  final List<String> sentExchange;

  /// Worked station's callsign.
  final String theirCall;

  /// Ordered received exchange tokens.
  final List<String> receivedExchange;

  /// ADIF band (for example `2m`), a fallback for VHF+ designators when
  /// [frequencyHz] is unknown or outside a known band.
  final String? band;

  /// Transmitter id (0 or 1) for multi-two categories.
  final int? transmitterId;
}

/// Kinds of [CabrilloIssue].
enum CabrilloIssueKind {
  /// No `CONTEST` name.
  missingContest,

  /// No `CALLSIGN`.
  missingCallsign,

  /// The log has no QSOs.
  emptyLog,

  /// Sent or received token count differs from the first QSO's.
  exchangeCountMismatch,

  /// The frequency/band column cannot be determined for a QSO.
  missingFrequency,

  /// A QSO has an empty callsign.
  missingQsoCall,

  /// An exchange token contained whitespace; it is replaced with `-`.
  tokenContainsWhitespace,

  /// More than 6 address lines; the extras are dropped.
  tooManyAddressLines,

  /// An address line exceeds 45 characters; it is truncated.
  addressLineTooLong,

  /// Transmitter id other than 0 or 1.
  invalidTransmitterId,
}

/// A problem found by [CabrilloWriter.validate].
@immutable
class CabrilloIssue {
  /// Creates an issue, optionally for QSO [qsoIndex] (zero based).
  const new(this.kind, {this.qsoIndex});

  /// What is wrong.
  final CabrilloIssueKind kind;

  /// Index of the affected QSO, if any.
  final int? qsoIndex;

  @override
  String toString() =>
      'CabrilloIssue(${kind.name}'
      '${qsoIndex != null ? ', qso $qsoIndex' : ''})';
}

/// Writes Cabrillo 3.0 logs.
///
/// Decoupled from contest rules: the caller supplies header values and
/// ready-made exchange tokens.
///
/// Choices:
///  * Lines end with CRLF (`\r\n`), which every checker accepts.
///  * Output is pure ASCII. Free text is transliterated (`ä` becomes `ae`,
///    `é` becomes `e`, ...); anything else becomes `?`.
///  * Header values are single-line: control characters (including CR and
///    LF) become spaces, so untrusted input cannot inject extra lines.
///  * QSO columns are padded to the widest entry in the whole log (the
///    spec only requires single spaces; padding is easier to read).
///  * Tokens are upper-cased.
///  * Frequencies below 50 MHz are written as integer kHz; from 50 MHz up
///    as a band designator (`50`, `144`, `1.2G`, ...).
class CabrilloWriter {
  /// Creates a writer.
  const new();

  /// Line terminator used for every line.
  static const lineEnd = '\r\n';

  /// Validates without throwing. [write] still produces output when there
  /// are issues, repairing what it can.
  List<CabrilloIssue> validate(CabrilloHeader header, List<CabrilloQso> qsos) {
    final issues = <CabrilloIssue>[];
    if (_clean(header.contest).isEmpty) {
      issues.add(const CabrilloIssue(CabrilloIssueKind.missingContest));
    }
    if (_clean(header.callsign).isEmpty) {
      issues.add(const CabrilloIssue(CabrilloIssueKind.missingCallsign));
    }
    if (header.addressLines.length > 6) {
      issues.add(const CabrilloIssue(CabrilloIssueKind.tooManyAddressLines));
    }
    if (header.addressLines.any((l) => _clean(l).length > 45)) {
      issues.add(const CabrilloIssue(CabrilloIssueKind.addressLineTooLong));
    }
    if (qsos.isEmpty) {
      issues.add(const CabrilloIssue(CabrilloIssueKind.emptyLog));
    }
    for (var i = 0; i < qsos.length; i++) {
      final q = qsos[i];
      if (_clean(q.myCall).isEmpty || _clean(q.theirCall).isEmpty) {
        issues.add(
          CabrilloIssue(CabrilloIssueKind.missingQsoCall, qsoIndex: i),
        );
      }
      if (_freqField(q) == null) {
        issues.add(
          CabrilloIssue(CabrilloIssueKind.missingFrequency, qsoIndex: i),
        );
      }
      final t = q.transmitterId;
      if (t != null && t != 0 && t != 1) {
        issues.add(
          CabrilloIssue(CabrilloIssueKind.invalidTransmitterId, qsoIndex: i),
        );
      }
      if ([...q.sentExchange, ...q.receivedExchange].any(_hasSpace)) {
        issues.add(
          CabrilloIssue(CabrilloIssueKind.tokenContainsWhitespace, qsoIndex: i),
        );
      }
      if (i > 0 &&
          (q.sentExchange.length != qsos.first.sentExchange.length ||
              q.receivedExchange.length !=
                  qsos.first.receivedExchange.length)) {
        issues.add(
          CabrilloIssue(CabrilloIssueKind.exchangeCountMismatch, qsoIndex: i),
        );
      }
    }
    return issues;
  }

  /// Renders the log. Never throws on bad data; call [validate] first to
  /// learn what was repaired. QSOs without a determinable frequency are
  /// written with `0`.
  String write(CabrilloHeader header, List<CabrilloQso> qsos) {
    final out = StringBuffer()..write('START-OF-LOG: 3.0$lineEnd');
    void put(String key, String? value, {bool upper = false}) {
      var v = _text(value);
      if (upper) v = v.toUpperCase();
      if (v.isEmpty) return;
      out.write('$key: $v$lineEnd');
    }

    put('CREATED-BY', header.createdBy);
    put('CONTEST', header.contest, upper: true);
    put('CALLSIGN', header.callsign, upper: true);
    put('LOCATION', header.location, upper: true);
    put('CATEGORY-OPERATOR', header.categoryOperator, upper: true);
    put('CATEGORY-ASSISTED', header.categoryAssisted, upper: true);
    put('CATEGORY-BAND', header.categoryBand, upper: true);
    put('CATEGORY-MODE', header.categoryMode, upper: true);
    put('CATEGORY-POWER', header.categoryPower, upper: true);
    put('CATEGORY-STATION', header.categoryStation, upper: true);
    put('CATEGORY-TRANSMITTER', header.categoryTransmitter, upper: true);
    put('CATEGORY-OVERLAY', header.categoryOverlay, upper: true);
    put('CATEGORY-TIME', header.categoryTime, upper: true);
    if (header.claimedScore != null) {
      put('CLAIMED-SCORE', header.claimedScore.toString());
    }
    put('CLUB', header.club);
    put('EMAIL', header.email);
    put('GRID-LOCATOR', header.gridLocator, upper: true);
    put('NAME', header.name);
    for (final line in header.addressLines.take(6)) {
      final t = _text(line);
      put('ADDRESS', t.length > 45 ? t.substring(0, 45) : t);
    }
    put('ADDRESS-CITY', header.addressCity);
    put('ADDRESS-STATE-PROVINCE', header.addressStateProvince);
    put('ADDRESS-POSTALCODE', header.addressPostalCode);
    put('ADDRESS-COUNTRY', header.addressCountry);
    put('OPERATORS', header.operators, upper: true);
    for (final o in header.offTimes) {
      put(
        'OFFTIME',
        '${_date(o.from)} ${_time(o.from)} '
            '${_date(o.to)} ${_time(o.to)}',
      );
    }
    for (final s in header.soapbox) {
      put('SOAPBOX', s);
    }

    final rows = <List<String>>[
      for (final q in qsos)
        [
          'QSO:',
          _freqField(q) ?? '0',
          q.mode.code,
          _date(q.time),
          _time(q.time),
          _token(q.myCall),
          ...q.sentExchange.map(_token),
          _token(q.theirCall),
          ...q.receivedExchange.map(_token),
          if (q.transmitterId != null) q.transmitterId.toString(),
        ],
    ];
    // Column widths over the whole log. The frequency column is right
    // aligned; everything else left aligned; the last cell is not padded.
    final widths = <int>[];
    for (final r in rows) {
      for (var c = 0; c < r.length; c++) {
        if (c >= widths.length) {
          widths.add(r[c].length);
        } else if (r[c].length > widths[c]) {
          widths[c] = r[c].length;
        }
      }
    }
    for (final r in rows) {
      final buf = StringBuffer();
      for (var c = 0; c < r.length; c++) {
        if (c > 0) buf.write(' ');
        if (c == 1) {
          buf.write(r[c].padLeft(widths[c]));
        } else if (c == r.length - 1) {
          buf.write(r[c]);
        } else {
          buf.write(r[c].padRight(widths[c]));
        }
      }
      out.write('$buf$lineEnd');
    }
    out.write('END-OF-LOG:$lineEnd');
    return out.toString();
  }

  static String _date(UtcDateTime t) {
    final v = t.value;
    return '${v.year.toString().padLeft(4, '0')}-${_two(v.month)}-'
        '${_two(v.day)}';
  }

  static String _time(UtcDateTime t) =>
      '${_two(t.value.hour)}${_two(t.value.minute)}';

  static String _two(int v) => v.toString().padLeft(2, '0');

  static bool _hasSpace(String s) => RegExp(r'\s').hasMatch(s.trim());

  /// Frequency/band column, or null if undeterminable.
  static String? _freqField(CabrilloQso q) {
    final hz = q.frequencyHz;
    if (hz > 0 && hz < 50000000) {
      return ((hz + 500) ~/ 1000).toString();
    }
    if (hz >= 50000000) {
      final mhz = hz / 1e6;
      for (final (lo, hi, name) in _vhfRanges) {
        if (mhz >= lo && mhz <= hi) return name;
      }
    }
    final b = q.band?.trim().toLowerCase();
    return b == null ? null : _bandDesignators[b];
  }

  static const _vhfRanges = <(double, double, String)>[
    (50, 54, '50'),
    (70, 71, '70'),
    (144, 148, '144'),
    (222, 225, '222'),
    (420, 450, '432'),
    (902, 928, '902'),
    (1240, 1300, '1.2G'),
    (2300, 2450, '2.3G'),
    (3300, 3500, '3.4G'),
    (5650, 5925, '5.7G'),
    (10000, 10500, '10G'),
    (24000, 24250, '24G'),
    (47000, 47200, '47G'),
    (75500, 81000, '76G'),
    (119980, 123000, '122G'),
    (134000, 141000, '134G'),
    (241000, 250000, '241G'),
  ];

  static const _bandDesignators = <String, String>{
    '6m': '50',
    '4m': '70',
    '2m': '144',
    '1.25m': '222',
    '70cm': '432',
    '33cm': '902',
    '23cm': '1.2G',
    '13cm': '2.3G',
    '9cm': '3.4G',
    '6cm': '5.7G',
    '3cm': '10G',
    '1.25cm': '24G',
    '6mm': '47G',
    '4mm': '76G',
    '2.5mm': '122G',
    '2mm': '134G',
    '1mm': '241G',
    'light': 'LIGHT',
  };

  /// A single exchange token or callsign: upper case, ASCII, no spaces.
  static String _token(String s) =>
      _clean(s).toUpperCase().replaceAll(RegExp(r'\s+'), '-');

  /// ASCII-only, control characters turned into spaces, trimmed, with
  /// whitespace runs collapsed.
  static String _clean(String? s) => _text(s);

  /// Single-line ASCII text.
  static String _text(String? s) {
    if (s == null) return '';
    final b = StringBuffer();
    for (final r in s.runes) {
      if (r < 0x20 || r == 0x7f || r == 0x85 || r == 0x2028 || r == 0x2029) {
        b.write(' ');
      } else if (r < 0x7f) {
        b.writeCharCode(r);
      } else {
        b.write(_translit[String.fromCharCode(r)] ?? '?');
      }
    }
    return b.toString().replaceAll(RegExp(' +'), ' ').trim();
  }

  static const _translit = <String, String>{
    'ä': 'ae',
    'ö': 'oe',
    'ü': 'ue',
    'Ä': 'Ae',
    'Ö': 'Oe',
    'Ü': 'Ue',
    'ß': 'ss',
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'å': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ø': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'À': 'A',
    'Á': 'A',
    'Â': 'A',
    'Ã': 'A',
    'Å': 'A',
    'Ç': 'C',
    'È': 'E',
    'É': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'Ì': 'I',
    'Í': 'I',
    'Î': 'I',
    'Ï': 'I',
    'Ñ': 'N',
    'Ò': 'O',
    'Ó': 'O',
    'Ô': 'O',
    'Õ': 'O',
    'Ø': 'O',
    'Ù': 'U',
    'Ú': 'U',
    'Û': 'U',
    'Ý': 'Y',
    'æ': 'ae',
    'Æ': 'AE',
    'œ': 'oe',
    'Œ': 'OE',
    'š': 's',
    'Š': 'S',
    'ž': 'z',
    'Ž': 'Z',
    'ł': 'l',
    'Ł': 'L',
    'ć': 'c',
    'č': 'c',
    'ř': 'r',
  };
}
