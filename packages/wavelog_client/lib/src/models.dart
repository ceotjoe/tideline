import 'package:meta/meta.dart';

/// Result of `GET /api/v2/token`: the token's identity and scopes.
@immutable
class TokenInfo {
  /// Creates token info.
  const new({required this.name, required this.scopes, this.expiresAt});

  /// Parses the `data` object of `GET /token`.
  factory fromJson(Map<String, Object?> json) {
    final scopes = json['scopes'];
    final name = json['name'];
    if (scopes is! List || name is! String) {
      throw const FormatException('token: missing name or scopes');
    }
    final expires = json['expires_at'];
    return TokenInfo(
      name: name,
      scopes: {for (final s in scopes) s.toString()},
      expiresAt: expires is String ? _parseServerTime(expires) : null,
    );
  }

  /// The token's display name.
  final String name;

  /// Granted scopes, e.g. `qso:write`.
  final Set<String> scopes;

  /// Expiry in UTC, or null if the token never expires.
  final DateTime? expiresAt;
}

/// What the connected Wavelog supports, from the capability probe.
@immutable
class ServerCapabilities {
  /// Creates capabilities.
  const new({
    required this.usesIndexPhp,
    required this.token,
    required this.hasContestSessions,
  });

  /// Whether API URLs need the `index.php/` prefix on this server.
  final bool usesIndexPhp;

  /// The token's scopes and expiry.
  final TokenInfo token;

  /// Wavelog 3.2+: contest sessions and the catalog are available.
  final bool hasContestSessions;

  /// Scopes Tideline cannot work without.
  static const requiredScopes = {'qso:read', 'qso:write', 'station:read'};

  /// Required scopes the token lacks.
  Set<String> get missingRequiredScopes =>
      requiredScopes.difference(token.scopes);
}

/// A Wavelog station location (`GET /station`).
@immutable
class WavelogStation {
  /// Creates a station.
  const new({
    required this.id,
    required this.name,
    required this.callsign,
    required this.active,
    this.gridsquare,
    this.dxcc,
    this.cqz,
    this.ituz,
    this.sotaRef,
    this.potaRef,
    this.wwffRef,
    this.iota,
    this.sig,
    this.sigInfo,
  });

  /// Parses one element of the `data` array of `GET /station`.
  factory fromJson(Map<String, Object?> json) {
    final id = _asInt(json['id']);
    final callsign = json['callsign'];
    if (id == null || callsign is! String) {
      throw const FormatException('station: missing id or callsign');
    }
    return WavelogStation(
      id: id,
      name: json['name']?.toString() ?? callsign,
      callsign: callsign,
      gridsquare: _nonEmpty(json['gridsquare']),
      dxcc: _asInt(json['dxcc']),
      cqz: _asInt(json['cq']),
      ituz: _asInt(json['itu']),
      sotaRef: _nonEmpty(json['sota']),
      potaRef: _nonEmpty(json['pota']),
      wwffRef: _nonEmpty(json['wwff']),
      iota: _nonEmpty(json['iota']),
      sig: _nonEmpty(json['sig']),
      sigInfo: _nonEmpty(json['sig_info']),
      active:
          json['active'] == true ||
          json['active'] == 1 ||
          json['active'] == '1',
    );
  }

  /// The `station_profile_id` to send with QSOs.
  final int id;

  /// Display name of the location.
  final String name;

  /// Station callsign.
  final String callsign;

  /// Maidenhead locator.
  final String? gridsquare;

  /// DXCC entity number.
  final int? dxcc;

  /// CQ zone.
  final int? cqz;

  /// ITU zone.
  final int? ituz;

  /// The location's SOTA reference. Wavelog copies it into the `MY_SOTA_REF`
  /// of every QSO uploaded to the location.
  final String? sotaRef;

  /// The location's POTA reference (copied into `MY_POTA_REF`).
  final String? potaRef;

  /// The location's WWFF reference (copied into `MY_WWFF_REF`).
  final String? wwffRef;

  /// The location's IOTA reference.
  final String? iota;

  /// The location's special interest group (`MY_SIG`).
  final String? sig;

  /// The location's special interest group info (`MY_SIG_INFO`).
  final String? sigInfo;

  /// Whether this is the user's active location in Wavelog.
  final bool active;
}

int? _asInt(Object? value) => switch (value) {
  final int v => v,
  final String v => int.tryParse(v),
  _ => null,
};

String? _nonEmpty(Object? value) {
  final s = value?.toString().trim();
  return s == null || s.isEmpty ? null : s;
}

/// Wavelog returns `YYYY-MM-DD HH:MM:SS` (UTC) or ISO 8601.
DateTime? _parseServerTime(String value) {
  final iso = value.contains('T') ? value : value.replaceFirst(' ', 'T');
  final parsed = DateTime.tryParse(
    iso.endsWith('Z') || iso.contains('+') ? iso : '${iso}Z',
  );
  return parsed?.toUtc();
}

/// A QSO as returned by `GET /qso` (only the fields Tideline needs to
/// reconcile; see docs/architecture/wavelog-api.md).
@immutable
class WavelogQso {
  /// Creates a QSO summary.
  const new({
    required this.id,
    required this.stationId,
    required this.call,
    required this.time,
    required this.band,
    required this.mode,
    this.submode,
  });

  /// Parses one element of the `data` array.
  factory fromJson(Map<String, Object?> json) {
    final id = _asInt(json['id']);
    final station = _asInt(json['station_id']);
    final call = json['call'];
    final date = json['qso_date'];
    final time = date is String ? _parseServerTime(date) : null;
    if (id == null || station == null || call is! String || time == null) {
      throw const FormatException('qso: missing id, station, call or date');
    }
    return WavelogQso(
      id: id,
      stationId: station,
      call: call.toUpperCase(),
      time: time,
      band: json['band']?.toString().toLowerCase() ?? '',
      mode: json['mode']?.toString().toUpperCase() ?? '',
      submode: _nonEmpty(json['submode'])?.toUpperCase(),
    );
  }

  /// Wavelog QSO id.
  final int id;

  /// `station_profile_id`.
  final int stationId;

  /// Contacted callsign, upper case.
  final String call;

  /// Start time (UTC).
  final DateTime time;

  /// Band, lower case (`20m`).
  final String band;

  /// Mode, upper case.
  final String mode;

  /// Submode, upper case, if any.
  final String? submode;
}

/// Result of a bulk dry run (`POST /qso` with `dryrun: true`).
@immutable
class WavelogDryRun {
  /// Creates the result.
  const new({required this.parsed});

  /// How many QSOs the server parsed successfully.
  final int parsed;
}

/// One active contest of the instance (`GET /catalog?topic=contest`).
///
/// The numeric [id] is instance-local; always address a contest by its
/// [adifName].
@immutable
class WavelogContest {
  /// Creates a catalog entry.
  const new({required this.id, required this.adifName, required this.name});

  /// Parses one element of the `data` array of the contest catalog.
  factory fromJson(Map<String, Object?> json) {
    final id = _asInt(json['id']);
    final adifName = _nonEmpty(json['contest']);
    if (id == null || adifName == null) {
      throw const FormatException('contest: missing id or contest');
    }
    return WavelogContest(
      id: id,
      adifName: adifName,
      name: _nonEmpty(json['name']) ?? adifName,
    );
  }

  /// Instance-local catalog id.
  final int id;

  /// The ADIF contest name (`CQ-WW-SSB`), as stored in `COL_CONTEST_ID`.
  final String adifName;

  /// Human-readable name.
  final String name;
}

/// A contest session (`/contest`).
@immutable
class WavelogContestSession {
  /// Creates a session.
  const new({
    required this.id,
    required this.contestAdifName,
    required this.contestName,
    required this.start,
    required this.end,
    required this.stationId,
    required this.comment,
    required this.settings,
    required this.qsoCount,
    this.qsoIds,
    this.createdAt,
    this.updatedAt,
    this.linkedCount,
    this.skippedQsoIds,
    this.unlinkedCount,
  });

  /// Parses a session object. `qso_ids` is only present on `GET /contest/{id}`;
  /// `linked`, `skipped` and `unlinked` only on create and update responses.
  factory fromJson(Map<String, Object?> json) {
    final id = _asInt(json['id']);
    final contest = _nonEmpty(json['contest']);
    final start = json['time_start'];
    final end = json['time_end'];
    final station = _asInt(json['station_id']);
    final startTime = start is String ? _parseServerTime(start) : null;
    final endTime = end is String ? _parseServerTime(end) : null;
    if (id == null ||
        contest == null ||
        station == null ||
        startTime == null ||
        endTime == null) {
      throw const FormatException('contest session: missing required field');
    }
    final settings = json['settings'];
    final createdAt = json['created_at'];
    final updatedAt = json['updated_at'];
    return WavelogContestSession(
      id: id,
      contestAdifName: contest,
      contestName: _nonEmpty(json['contest_name']) ?? contest,
      start: startTime,
      end: endTime,
      stationId: station,
      comment: json['comment']?.toString() ?? '',
      settings: settings is Map<String, Object?>
          ? Map.unmodifiable(settings)
          : const {},
      qsoCount: _asInt(json['qso_count']) ?? 0,
      qsoIds: json.containsKey('qso_ids') ? _intList(json['qso_ids']) : null,
      createdAt: createdAt is String ? _parseServerTime(createdAt) : null,
      updatedAt: updatedAt is String ? _parseServerTime(updatedAt) : null,
      linkedCount: _asInt(json['linked']),
      skippedQsoIds: json.containsKey('skipped')
          ? _intList(json['skipped'])
          : null,
      unlinkedCount: _asInt(json['unlinked']),
    );
  }

  /// Server session id.
  final int id;

  /// ADIF name of the contest (`contest`).
  final String contestAdifName;

  /// Human-readable contest name (`contest_name`).
  final String contestName;

  /// Start (UTC, `time_start`).
  final DateTime start;

  /// End (UTC, `time_end`).
  final DateTime end;

  /// `station_profile_id` of the session.
  final int stationId;

  /// Free-text comment (empty if none).
  final String comment;

  /// Settings merged over the server defaults (unvalidated server data).
  final Map<String, Object?> settings;

  /// Number of linked QSOs.
  final int qsoCount;

  /// Ids of linked QSOs, ascending. Only set by `GET /contest/{id}`.
  final List<int>? qsoIds;

  /// Server creation time (UTC), if reported.
  final DateTime? createdAt;

  /// Server modification time (UTC), if reported.
  final DateTime? updatedAt;

  /// Create/patch only: how many QSOs were newly linked.
  final int? linkedCount;

  /// Create/patch only: QSO ids not linked because they already belong to
  /// another session.
  final List<int>? skippedQsoIds;

  /// Patch only: how many links were removed.
  final int? unlinkedCount;
}

/// One page of `GET /qso?format=adif`.
@immutable
class WavelogAdifPage {
  /// Creates a page.
  const new({
    required this.exported,
    required this.lastFetchedId,
    required this.adif,
    required this.hasMore,
  });

  /// Number of QSOs in [adif].
  final int exported;

  /// Highest QSO id in the page, or the requested `since_id` if the page is
  /// empty. Pass it back as `sinceId` to continue.
  final int lastFetchedId;

  /// ADIF text (header plus records); empty if nothing was exported.
  final String adif;

  /// Whether `meta.has_more` says further pages exist for this filter.
  final bool hasMore;
}

List<int> _intList(Object? value) {
  if (value is! List) throw const FormatException('expected a list of ids');
  return List.unmodifiable([
    for (final v in value)
      _asInt(v) ?? (throw const FormatException('id is not an integer')),
  ]);
}
