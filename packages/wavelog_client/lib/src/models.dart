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
