// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tideline_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usesIndexPhpMeta = const VerificationMeta(
    'usesIndexPhp',
  );
  @override
  late final GeneratedColumn<bool> usesIndexPhp = GeneratedColumn<bool>(
    'uses_index_php',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uses_index_php" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _certPinSha256Meta = const VerificationMeta(
    'certPinSha256',
  );
  @override
  late final GeneratedColumn<String> certPinSha256 = GeneratedColumn<String>(
    'cert_pin_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allowHttpLanMeta = const VerificationMeta(
    'allowHttpLan',
  );
  @override
  late final GeneratedColumn<bool> allowHttpLan = GeneratedColumn<bool>(
    'allow_http_lan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_http_lan" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverCapsMeta = const VerificationMeta(
    'serverCaps',
  );
  @override
  late final GeneratedColumn<String> serverCaps = GeneratedColumn<String>(
    'server_caps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _scopesMeta = const VerificationMeta('scopes');
  @override
  late final GeneratedColumn<String> scopes = GeneratedColumn<String>(
    'scopes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _tokenExpiresAtMeta = const VerificationMeta(
    'tokenExpiresAt',
  );
  @override
  late final GeneratedColumn<int> tokenExpiresAt = GeneratedColumn<int>(
    'token_expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    baseUrl,
    usesIndexPhp,
    certPinSha256,
    allowHttpLan,
    serverCaps,
    scopes,
    tokenExpiresAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('uses_index_php')) {
      context.handle(
        _usesIndexPhpMeta,
        usesIndexPhp.isAcceptableOrUnknown(
          data['uses_index_php']!,
          _usesIndexPhpMeta,
        ),
      );
    }
    if (data.containsKey('cert_pin_sha256')) {
      context.handle(
        _certPinSha256Meta,
        certPinSha256.isAcceptableOrUnknown(
          data['cert_pin_sha256']!,
          _certPinSha256Meta,
        ),
      );
    }
    if (data.containsKey('allow_http_lan')) {
      context.handle(
        _allowHttpLanMeta,
        allowHttpLan.isAcceptableOrUnknown(
          data['allow_http_lan']!,
          _allowHttpLanMeta,
        ),
      );
    }
    if (data.containsKey('server_caps')) {
      context.handle(
        _serverCapsMeta,
        serverCaps.isAcceptableOrUnknown(data['server_caps']!, _serverCapsMeta),
      );
    }
    if (data.containsKey('scopes')) {
      context.handle(
        _scopesMeta,
        scopes.isAcceptableOrUnknown(data['scopes']!, _scopesMeta),
      );
    }
    if (data.containsKey('token_expires_at')) {
      context.handle(
        _tokenExpiresAtMeta,
        tokenExpiresAt.isAcceptableOrUnknown(
          data['token_expires_at']!,
          _tokenExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      usesIndexPhp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uses_index_php'],
      )!,
      certPinSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cert_pin_sha256'],
      ),
      allowHttpLan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_http_lan'],
      )!,
      serverCaps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_caps'],
      )!,
      scopes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scopes'],
      )!,
      tokenExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String label;
  final String baseUrl;
  final bool usesIndexPhp;
  final String? certPinSha256;
  final bool allowHttpLan;

  /// JSON object with probed server capabilities.
  final String serverCaps;

  /// JSON array of granted token scopes, as reported by the server.
  final String scopes;
  final int? tokenExpiresAt;
  final int createdAt;
  const AccountRow({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.usesIndexPhp,
    this.certPinSha256,
    required this.allowHttpLan,
    required this.serverCaps,
    required this.scopes,
    this.tokenExpiresAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['base_url'] = Variable<String>(baseUrl);
    map['uses_index_php'] = Variable<bool>(usesIndexPhp);
    if (!nullToAbsent || certPinSha256 != null) {
      map['cert_pin_sha256'] = Variable<String>(certPinSha256);
    }
    map['allow_http_lan'] = Variable<bool>(allowHttpLan);
    map['server_caps'] = Variable<String>(serverCaps);
    map['scopes'] = Variable<String>(scopes);
    if (!nullToAbsent || tokenExpiresAt != null) {
      map['token_expires_at'] = Variable<int>(tokenExpiresAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      label: Value(label),
      baseUrl: Value(baseUrl),
      usesIndexPhp: Value(usesIndexPhp),
      certPinSha256: certPinSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(certPinSha256),
      allowHttpLan: Value(allowHttpLan),
      serverCaps: Value(serverCaps),
      scopes: Value(scopes),
      tokenExpiresAt: tokenExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenExpiresAt),
      createdAt: Value(createdAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      usesIndexPhp: serializer.fromJson<bool>(json['usesIndexPhp']),
      certPinSha256: serializer.fromJson<String?>(json['certPinSha256']),
      allowHttpLan: serializer.fromJson<bool>(json['allowHttpLan']),
      serverCaps: serializer.fromJson<String>(json['serverCaps']),
      scopes: serializer.fromJson<String>(json['scopes']),
      tokenExpiresAt: serializer.fromJson<int?>(json['tokenExpiresAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'usesIndexPhp': serializer.toJson<bool>(usesIndexPhp),
      'certPinSha256': serializer.toJson<String?>(certPinSha256),
      'allowHttpLan': serializer.toJson<bool>(allowHttpLan),
      'serverCaps': serializer.toJson<String>(serverCaps),
      'scopes': serializer.toJson<String>(scopes),
      'tokenExpiresAt': serializer.toJson<int?>(tokenExpiresAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AccountRow copyWith({
    String? id,
    String? label,
    String? baseUrl,
    bool? usesIndexPhp,
    Value<String?> certPinSha256 = const Value.absent(),
    bool? allowHttpLan,
    String? serverCaps,
    String? scopes,
    Value<int?> tokenExpiresAt = const Value.absent(),
    int? createdAt,
  }) => AccountRow(
    id: id ?? this.id,
    label: label ?? this.label,
    baseUrl: baseUrl ?? this.baseUrl,
    usesIndexPhp: usesIndexPhp ?? this.usesIndexPhp,
    certPinSha256: certPinSha256.present
        ? certPinSha256.value
        : this.certPinSha256,
    allowHttpLan: allowHttpLan ?? this.allowHttpLan,
    serverCaps: serverCaps ?? this.serverCaps,
    scopes: scopes ?? this.scopes,
    tokenExpiresAt: tokenExpiresAt.present
        ? tokenExpiresAt.value
        : this.tokenExpiresAt,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      usesIndexPhp: data.usesIndexPhp.present
          ? data.usesIndexPhp.value
          : this.usesIndexPhp,
      certPinSha256: data.certPinSha256.present
          ? data.certPinSha256.value
          : this.certPinSha256,
      allowHttpLan: data.allowHttpLan.present
          ? data.allowHttpLan.value
          : this.allowHttpLan,
      serverCaps: data.serverCaps.present
          ? data.serverCaps.value
          : this.serverCaps,
      scopes: data.scopes.present ? data.scopes.value : this.scopes,
      tokenExpiresAt: data.tokenExpiresAt.present
          ? data.tokenExpiresAt.value
          : this.tokenExpiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('usesIndexPhp: $usesIndexPhp, ')
          ..write('certPinSha256: $certPinSha256, ')
          ..write('allowHttpLan: $allowHttpLan, ')
          ..write('serverCaps: $serverCaps, ')
          ..write('scopes: $scopes, ')
          ..write('tokenExpiresAt: $tokenExpiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    baseUrl,
    usesIndexPhp,
    certPinSha256,
    allowHttpLan,
    serverCaps,
    scopes,
    tokenExpiresAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.baseUrl == this.baseUrl &&
          other.usesIndexPhp == this.usesIndexPhp &&
          other.certPinSha256 == this.certPinSha256 &&
          other.allowHttpLan == this.allowHttpLan &&
          other.serverCaps == this.serverCaps &&
          other.scopes == this.scopes &&
          other.tokenExpiresAt == this.tokenExpiresAt &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> baseUrl;
  final Value<bool> usesIndexPhp;
  final Value<String?> certPinSha256;
  final Value<bool> allowHttpLan;
  final Value<String> serverCaps;
  final Value<String> scopes;
  final Value<int?> tokenExpiresAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.usesIndexPhp = const Value.absent(),
    this.certPinSha256 = const Value.absent(),
    this.allowHttpLan = const Value.absent(),
    this.serverCaps = const Value.absent(),
    this.scopes = const Value.absent(),
    this.tokenExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String label,
    required String baseUrl,
    this.usesIndexPhp = const Value.absent(),
    this.certPinSha256 = const Value.absent(),
    this.allowHttpLan = const Value.absent(),
    this.serverCaps = const Value.absent(),
    this.scopes = const Value.absent(),
    this.tokenExpiresAt = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       baseUrl = Value(baseUrl),
       createdAt = Value(createdAt);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? baseUrl,
    Expression<bool>? usesIndexPhp,
    Expression<String>? certPinSha256,
    Expression<bool>? allowHttpLan,
    Expression<String>? serverCaps,
    Expression<String>? scopes,
    Expression<int>? tokenExpiresAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (baseUrl != null) 'base_url': baseUrl,
      if (usesIndexPhp != null) 'uses_index_php': usesIndexPhp,
      if (certPinSha256 != null) 'cert_pin_sha256': certPinSha256,
      if (allowHttpLan != null) 'allow_http_lan': allowHttpLan,
      if (serverCaps != null) 'server_caps': serverCaps,
      if (scopes != null) 'scopes': scopes,
      if (tokenExpiresAt != null) 'token_expires_at': tokenExpiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? baseUrl,
    Value<bool>? usesIndexPhp,
    Value<String?>? certPinSha256,
    Value<bool>? allowHttpLan,
    Value<String>? serverCaps,
    Value<String>? scopes,
    Value<int?>? tokenExpiresAt,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      baseUrl: baseUrl ?? this.baseUrl,
      usesIndexPhp: usesIndexPhp ?? this.usesIndexPhp,
      certPinSha256: certPinSha256 ?? this.certPinSha256,
      allowHttpLan: allowHttpLan ?? this.allowHttpLan,
      serverCaps: serverCaps ?? this.serverCaps,
      scopes: scopes ?? this.scopes,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (usesIndexPhp.present) {
      map['uses_index_php'] = Variable<bool>(usesIndexPhp.value);
    }
    if (certPinSha256.present) {
      map['cert_pin_sha256'] = Variable<String>(certPinSha256.value);
    }
    if (allowHttpLan.present) {
      map['allow_http_lan'] = Variable<bool>(allowHttpLan.value);
    }
    if (serverCaps.present) {
      map['server_caps'] = Variable<String>(serverCaps.value);
    }
    if (scopes.present) {
      map['scopes'] = Variable<String>(scopes.value);
    }
    if (tokenExpiresAt.present) {
      map['token_expires_at'] = Variable<int>(tokenExpiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('usesIndexPhp: $usesIndexPhp, ')
          ..write('certPinSha256: $certPinSha256, ')
          ..write('allowHttpLan: $allowHttpLan, ')
          ..write('serverCaps: $serverCaps, ')
          ..write('scopes: $scopes, ')
          ..write('tokenExpiresAt: $tokenExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StationProfilesTable extends StationProfiles
    with TableInfo<$StationProfilesTable, StationProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StationProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callsignMeta = const VerificationMeta(
    'callsign',
  );
  @override
  late final GeneratedColumn<String> callsign = GeneratedColumn<String>(
    'callsign',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gridsquareMeta = const VerificationMeta(
    'gridsquare',
  );
  @override
  late final GeneratedColumn<String> gridsquare = GeneratedColumn<String>(
    'gridsquare',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dxccMeta = const VerificationMeta('dxcc');
  @override
  late final GeneratedColumn<int> dxcc = GeneratedColumn<int>(
    'dxcc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cqzMeta = const VerificationMeta('cqz');
  @override
  late final GeneratedColumn<int> cqz = GeneratedColumn<int>(
    'cqz',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ituzMeta = const VerificationMeta('ituz');
  @override
  late final GeneratedColumn<int> ituz = GeneratedColumn<int>(
    'ituz',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sotaRefMeta = const VerificationMeta(
    'sotaRef',
  );
  @override
  late final GeneratedColumn<String> sotaRef = GeneratedColumn<String>(
    'sota_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potaRefMeta = const VerificationMeta(
    'potaRef',
  );
  @override
  late final GeneratedColumn<String> potaRef = GeneratedColumn<String>(
    'pota_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wwffRefMeta = const VerificationMeta(
    'wwffRef',
  );
  @override
  late final GeneratedColumn<String> wwffRef = GeneratedColumn<String>(
    'wwff_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iotaMeta = const VerificationMeta('iota');
  @override
  late final GeneratedColumn<String> iota = GeneratedColumn<String>(
    'iota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sigMeta = const VerificationMeta('sig');
  @override
  late final GeneratedColumn<String> sig = GeneratedColumn<String>(
    'sig',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sigInfoMeta = const VerificationMeta(
    'sigInfo',
  );
  @override
  late final GeneratedColumn<String> sigInfo = GeneratedColumn<String>(
    'sig_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    remoteId,
    name,
    callsign,
    gridsquare,
    dxcc,
    cqz,
    ituz,
    sotaRef,
    potaRef,
    wwffRef,
    iota,
    sig,
    sigInfo,
    active,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'station_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<StationProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('callsign')) {
      context.handle(
        _callsignMeta,
        callsign.isAcceptableOrUnknown(data['callsign']!, _callsignMeta),
      );
    } else if (isInserting) {
      context.missing(_callsignMeta);
    }
    if (data.containsKey('gridsquare')) {
      context.handle(
        _gridsquareMeta,
        gridsquare.isAcceptableOrUnknown(data['gridsquare']!, _gridsquareMeta),
      );
    }
    if (data.containsKey('dxcc')) {
      context.handle(
        _dxccMeta,
        dxcc.isAcceptableOrUnknown(data['dxcc']!, _dxccMeta),
      );
    }
    if (data.containsKey('cqz')) {
      context.handle(
        _cqzMeta,
        cqz.isAcceptableOrUnknown(data['cqz']!, _cqzMeta),
      );
    }
    if (data.containsKey('ituz')) {
      context.handle(
        _ituzMeta,
        ituz.isAcceptableOrUnknown(data['ituz']!, _ituzMeta),
      );
    }
    if (data.containsKey('sota_ref')) {
      context.handle(
        _sotaRefMeta,
        sotaRef.isAcceptableOrUnknown(data['sota_ref']!, _sotaRefMeta),
      );
    }
    if (data.containsKey('pota_ref')) {
      context.handle(
        _potaRefMeta,
        potaRef.isAcceptableOrUnknown(data['pota_ref']!, _potaRefMeta),
      );
    }
    if (data.containsKey('wwff_ref')) {
      context.handle(
        _wwffRefMeta,
        wwffRef.isAcceptableOrUnknown(data['wwff_ref']!, _wwffRefMeta),
      );
    }
    if (data.containsKey('iota')) {
      context.handle(
        _iotaMeta,
        iota.isAcceptableOrUnknown(data['iota']!, _iotaMeta),
      );
    }
    if (data.containsKey('sig')) {
      context.handle(
        _sigMeta,
        sig.isAcceptableOrUnknown(data['sig']!, _sigMeta),
      );
    }
    if (data.containsKey('sig_info')) {
      context.handle(
        _sigInfoMeta,
        sigInfo.isAcceptableOrUnknown(data['sig_info']!, _sigInfoMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountId, remoteId},
  ];
  @override
  StationProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StationProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      callsign: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}callsign'],
      )!,
      gridsquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gridsquare'],
      ),
      dxcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dxcc'],
      ),
      cqz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cqz'],
      ),
      ituz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ituz'],
      ),
      sotaRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sota_ref'],
      ),
      potaRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pota_ref'],
      ),
      wwffRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wwff_ref'],
      ),
      iota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iota'],
      ),
      sig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sig'],
      ),
      sigInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sig_info'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $StationProfilesTable createAlias(String alias) {
    return $StationProfilesTable(attachedDatabase, alias);
  }
}

class StationProfileRow extends DataClass
    implements Insertable<StationProfileRow> {
  final String id;
  final String accountId;

  /// Wavelog `station_profile_id`.
  final int remoteId;
  final String name;
  final String callsign;
  final String? gridsquare;
  final int? dxcc;
  final int? cqz;
  final int? ituz;
  final String? sotaRef;
  final String? potaRef;
  final String? wwffRef;
  final String? iota;
  final String? sig;
  final String? sigInfo;
  final bool active;
  final int fetchedAt;
  const StationProfileRow({
    required this.id,
    required this.accountId,
    required this.remoteId,
    required this.name,
    required this.callsign,
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
    required this.active,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['remote_id'] = Variable<int>(remoteId);
    map['name'] = Variable<String>(name);
    map['callsign'] = Variable<String>(callsign);
    if (!nullToAbsent || gridsquare != null) {
      map['gridsquare'] = Variable<String>(gridsquare);
    }
    if (!nullToAbsent || dxcc != null) {
      map['dxcc'] = Variable<int>(dxcc);
    }
    if (!nullToAbsent || cqz != null) {
      map['cqz'] = Variable<int>(cqz);
    }
    if (!nullToAbsent || ituz != null) {
      map['ituz'] = Variable<int>(ituz);
    }
    if (!nullToAbsent || sotaRef != null) {
      map['sota_ref'] = Variable<String>(sotaRef);
    }
    if (!nullToAbsent || potaRef != null) {
      map['pota_ref'] = Variable<String>(potaRef);
    }
    if (!nullToAbsent || wwffRef != null) {
      map['wwff_ref'] = Variable<String>(wwffRef);
    }
    if (!nullToAbsent || iota != null) {
      map['iota'] = Variable<String>(iota);
    }
    if (!nullToAbsent || sig != null) {
      map['sig'] = Variable<String>(sig);
    }
    if (!nullToAbsent || sigInfo != null) {
      map['sig_info'] = Variable<String>(sigInfo);
    }
    map['active'] = Variable<bool>(active);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  StationProfilesCompanion toCompanion(bool nullToAbsent) {
    return StationProfilesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      remoteId: Value(remoteId),
      name: Value(name),
      callsign: Value(callsign),
      gridsquare: gridsquare == null && nullToAbsent
          ? const Value.absent()
          : Value(gridsquare),
      dxcc: dxcc == null && nullToAbsent ? const Value.absent() : Value(dxcc),
      cqz: cqz == null && nullToAbsent ? const Value.absent() : Value(cqz),
      ituz: ituz == null && nullToAbsent ? const Value.absent() : Value(ituz),
      sotaRef: sotaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sotaRef),
      potaRef: potaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(potaRef),
      wwffRef: wwffRef == null && nullToAbsent
          ? const Value.absent()
          : Value(wwffRef),
      iota: iota == null && nullToAbsent ? const Value.absent() : Value(iota),
      sig: sig == null && nullToAbsent ? const Value.absent() : Value(sig),
      sigInfo: sigInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(sigInfo),
      active: Value(active),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory StationProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StationProfileRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      callsign: serializer.fromJson<String>(json['callsign']),
      gridsquare: serializer.fromJson<String?>(json['gridsquare']),
      dxcc: serializer.fromJson<int?>(json['dxcc']),
      cqz: serializer.fromJson<int?>(json['cqz']),
      ituz: serializer.fromJson<int?>(json['ituz']),
      sotaRef: serializer.fromJson<String?>(json['sotaRef']),
      potaRef: serializer.fromJson<String?>(json['potaRef']),
      wwffRef: serializer.fromJson<String?>(json['wwffRef']),
      iota: serializer.fromJson<String?>(json['iota']),
      sig: serializer.fromJson<String?>(json['sig']),
      sigInfo: serializer.fromJson<String?>(json['sigInfo']),
      active: serializer.fromJson<bool>(json['active']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'remoteId': serializer.toJson<int>(remoteId),
      'name': serializer.toJson<String>(name),
      'callsign': serializer.toJson<String>(callsign),
      'gridsquare': serializer.toJson<String?>(gridsquare),
      'dxcc': serializer.toJson<int?>(dxcc),
      'cqz': serializer.toJson<int?>(cqz),
      'ituz': serializer.toJson<int?>(ituz),
      'sotaRef': serializer.toJson<String?>(sotaRef),
      'potaRef': serializer.toJson<String?>(potaRef),
      'wwffRef': serializer.toJson<String?>(wwffRef),
      'iota': serializer.toJson<String?>(iota),
      'sig': serializer.toJson<String?>(sig),
      'sigInfo': serializer.toJson<String?>(sigInfo),
      'active': serializer.toJson<bool>(active),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  StationProfileRow copyWith({
    String? id,
    String? accountId,
    int? remoteId,
    String? name,
    String? callsign,
    Value<String?> gridsquare = const Value.absent(),
    Value<int?> dxcc = const Value.absent(),
    Value<int?> cqz = const Value.absent(),
    Value<int?> ituz = const Value.absent(),
    Value<String?> sotaRef = const Value.absent(),
    Value<String?> potaRef = const Value.absent(),
    Value<String?> wwffRef = const Value.absent(),
    Value<String?> iota = const Value.absent(),
    Value<String?> sig = const Value.absent(),
    Value<String?> sigInfo = const Value.absent(),
    bool? active,
    int? fetchedAt,
  }) => StationProfileRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    remoteId: remoteId ?? this.remoteId,
    name: name ?? this.name,
    callsign: callsign ?? this.callsign,
    gridsquare: gridsquare.present ? gridsquare.value : this.gridsquare,
    dxcc: dxcc.present ? dxcc.value : this.dxcc,
    cqz: cqz.present ? cqz.value : this.cqz,
    ituz: ituz.present ? ituz.value : this.ituz,
    sotaRef: sotaRef.present ? sotaRef.value : this.sotaRef,
    potaRef: potaRef.present ? potaRef.value : this.potaRef,
    wwffRef: wwffRef.present ? wwffRef.value : this.wwffRef,
    iota: iota.present ? iota.value : this.iota,
    sig: sig.present ? sig.value : this.sig,
    sigInfo: sigInfo.present ? sigInfo.value : this.sigInfo,
    active: active ?? this.active,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  StationProfileRow copyWithCompanion(StationProfilesCompanion data) {
    return StationProfileRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      callsign: data.callsign.present ? data.callsign.value : this.callsign,
      gridsquare: data.gridsquare.present
          ? data.gridsquare.value
          : this.gridsquare,
      dxcc: data.dxcc.present ? data.dxcc.value : this.dxcc,
      cqz: data.cqz.present ? data.cqz.value : this.cqz,
      ituz: data.ituz.present ? data.ituz.value : this.ituz,
      sotaRef: data.sotaRef.present ? data.sotaRef.value : this.sotaRef,
      potaRef: data.potaRef.present ? data.potaRef.value : this.potaRef,
      wwffRef: data.wwffRef.present ? data.wwffRef.value : this.wwffRef,
      iota: data.iota.present ? data.iota.value : this.iota,
      sig: data.sig.present ? data.sig.value : this.sig,
      sigInfo: data.sigInfo.present ? data.sigInfo.value : this.sigInfo,
      active: data.active.present ? data.active.value : this.active,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StationProfileRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('callsign: $callsign, ')
          ..write('gridsquare: $gridsquare, ')
          ..write('dxcc: $dxcc, ')
          ..write('cqz: $cqz, ')
          ..write('ituz: $ituz, ')
          ..write('sotaRef: $sotaRef, ')
          ..write('potaRef: $potaRef, ')
          ..write('wwffRef: $wwffRef, ')
          ..write('iota: $iota, ')
          ..write('sig: $sig, ')
          ..write('sigInfo: $sigInfo, ')
          ..write('active: $active, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    remoteId,
    name,
    callsign,
    gridsquare,
    dxcc,
    cqz,
    ituz,
    sotaRef,
    potaRef,
    wwffRef,
    iota,
    sig,
    sigInfo,
    active,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StationProfileRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.callsign == this.callsign &&
          other.gridsquare == this.gridsquare &&
          other.dxcc == this.dxcc &&
          other.cqz == this.cqz &&
          other.ituz == this.ituz &&
          other.sotaRef == this.sotaRef &&
          other.potaRef == this.potaRef &&
          other.wwffRef == this.wwffRef &&
          other.iota == this.iota &&
          other.sig == this.sig &&
          other.sigInfo == this.sigInfo &&
          other.active == this.active &&
          other.fetchedAt == this.fetchedAt);
}

class StationProfilesCompanion extends UpdateCompanion<StationProfileRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<int> remoteId;
  final Value<String> name;
  final Value<String> callsign;
  final Value<String?> gridsquare;
  final Value<int?> dxcc;
  final Value<int?> cqz;
  final Value<int?> ituz;
  final Value<String?> sotaRef;
  final Value<String?> potaRef;
  final Value<String?> wwffRef;
  final Value<String?> iota;
  final Value<String?> sig;
  final Value<String?> sigInfo;
  final Value<bool> active;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const StationProfilesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.callsign = const Value.absent(),
    this.gridsquare = const Value.absent(),
    this.dxcc = const Value.absent(),
    this.cqz = const Value.absent(),
    this.ituz = const Value.absent(),
    this.sotaRef = const Value.absent(),
    this.potaRef = const Value.absent(),
    this.wwffRef = const Value.absent(),
    this.iota = const Value.absent(),
    this.sig = const Value.absent(),
    this.sigInfo = const Value.absent(),
    this.active = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StationProfilesCompanion.insert({
    required String id,
    required String accountId,
    required int remoteId,
    required String name,
    required String callsign,
    this.gridsquare = const Value.absent(),
    this.dxcc = const Value.absent(),
    this.cqz = const Value.absent(),
    this.ituz = const Value.absent(),
    this.sotaRef = const Value.absent(),
    this.potaRef = const Value.absent(),
    this.wwffRef = const Value.absent(),
    this.iota = const Value.absent(),
    this.sig = const Value.absent(),
    this.sigInfo = const Value.absent(),
    this.active = const Value.absent(),
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       remoteId = Value(remoteId),
       name = Value(name),
       callsign = Value(callsign),
       fetchedAt = Value(fetchedAt);
  static Insertable<StationProfileRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? remoteId,
    Expression<String>? name,
    Expression<String>? callsign,
    Expression<String>? gridsquare,
    Expression<int>? dxcc,
    Expression<int>? cqz,
    Expression<int>? ituz,
    Expression<String>? sotaRef,
    Expression<String>? potaRef,
    Expression<String>? wwffRef,
    Expression<String>? iota,
    Expression<String>? sig,
    Expression<String>? sigInfo,
    Expression<bool>? active,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (callsign != null) 'callsign': callsign,
      if (gridsquare != null) 'gridsquare': gridsquare,
      if (dxcc != null) 'dxcc': dxcc,
      if (cqz != null) 'cqz': cqz,
      if (ituz != null) 'ituz': ituz,
      if (sotaRef != null) 'sota_ref': sotaRef,
      if (potaRef != null) 'pota_ref': potaRef,
      if (wwffRef != null) 'wwff_ref': wwffRef,
      if (iota != null) 'iota': iota,
      if (sig != null) 'sig': sig,
      if (sigInfo != null) 'sig_info': sigInfo,
      if (active != null) 'active': active,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StationProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<int>? remoteId,
    Value<String>? name,
    Value<String>? callsign,
    Value<String?>? gridsquare,
    Value<int?>? dxcc,
    Value<int?>? cqz,
    Value<int?>? ituz,
    Value<String?>? sotaRef,
    Value<String?>? potaRef,
    Value<String?>? wwffRef,
    Value<String?>? iota,
    Value<String?>? sig,
    Value<String?>? sigInfo,
    Value<bool>? active,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return StationProfilesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      callsign: callsign ?? this.callsign,
      gridsquare: gridsquare ?? this.gridsquare,
      dxcc: dxcc ?? this.dxcc,
      cqz: cqz ?? this.cqz,
      ituz: ituz ?? this.ituz,
      sotaRef: sotaRef ?? this.sotaRef,
      potaRef: potaRef ?? this.potaRef,
      wwffRef: wwffRef ?? this.wwffRef,
      iota: iota ?? this.iota,
      sig: sig ?? this.sig,
      sigInfo: sigInfo ?? this.sigInfo,
      active: active ?? this.active,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (callsign.present) {
      map['callsign'] = Variable<String>(callsign.value);
    }
    if (gridsquare.present) {
      map['gridsquare'] = Variable<String>(gridsquare.value);
    }
    if (dxcc.present) {
      map['dxcc'] = Variable<int>(dxcc.value);
    }
    if (cqz.present) {
      map['cqz'] = Variable<int>(cqz.value);
    }
    if (ituz.present) {
      map['ituz'] = Variable<int>(ituz.value);
    }
    if (sotaRef.present) {
      map['sota_ref'] = Variable<String>(sotaRef.value);
    }
    if (potaRef.present) {
      map['pota_ref'] = Variable<String>(potaRef.value);
    }
    if (wwffRef.present) {
      map['wwff_ref'] = Variable<String>(wwffRef.value);
    }
    if (iota.present) {
      map['iota'] = Variable<String>(iota.value);
    }
    if (sig.present) {
      map['sig'] = Variable<String>(sig.value);
    }
    if (sigInfo.present) {
      map['sig_info'] = Variable<String>(sigInfo.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StationProfilesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('callsign: $callsign, ')
          ..write('gridsquare: $gridsquare, ')
          ..write('dxcc: $dxcc, ')
          ..write('cqz: $cqz, ')
          ..write('ituz: $ituz, ')
          ..write('sotaRef: $sotaRef, ')
          ..write('potaRef: $potaRef, ')
          ..write('wwffRef: $wwffRef, ')
          ..write('iota: $iota, ')
          ..write('sig: $sig, ')
          ..write('sigInfo: $sigInfo, ')
          ..write('active: $active, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContestDefinitionsTable extends ContestDefinitions
    with TableInfo<$ContestDefinitionsTable, ContestDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContestDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cabrilloNameMeta = const VerificationMeta(
    'cabrilloName',
  );
  @override
  late final GeneratedColumn<String> cabrilloName = GeneratedColumn<String>(
    'cabrillo_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wavelogAdifNameMeta = const VerificationMeta(
    'wavelogAdifName',
  );
  @override
  late final GeneratedColumn<String> wavelogAdifName = GeneratedColumn<String>(
    'wavelog_adif_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _builtinMeta = const VerificationMeta(
    'builtin',
  );
  @override
  late final GeneratedColumn<bool> builtin = GeneratedColumn<bool>(
    'builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cabrilloName,
    wavelogAdifName,
    version,
    definition,
    builtin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contest_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContestDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cabrillo_name')) {
      context.handle(
        _cabrilloNameMeta,
        cabrilloName.isAcceptableOrUnknown(
          data['cabrillo_name']!,
          _cabrilloNameMeta,
        ),
      );
    }
    if (data.containsKey('wavelog_adif_name')) {
      context.handle(
        _wavelogAdifNameMeta,
        wavelogAdifName.isAcceptableOrUnknown(
          data['wavelog_adif_name']!,
          _wavelogAdifNameMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('builtin')) {
      context.handle(
        _builtinMeta,
        builtin.isAcceptableOrUnknown(data['builtin']!, _builtinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContestDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContestDefinitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cabrilloName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cabrillo_name'],
      ),
      wavelogAdifName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wavelog_adif_name'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      builtin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}builtin'],
      )!,
    );
  }

  @override
  $ContestDefinitionsTable createAlias(String alias) {
    return $ContestDefinitionsTable(attachedDatabase, alias);
  }
}

class ContestDefinitionRow extends DataClass
    implements Insertable<ContestDefinitionRow> {
  final String id;
  final String name;
  final String? cabrilloName;

  /// ADIF CONTEST_ID / Wavelog contest ADIF name.
  final String? wavelogAdifName;
  final int version;

  /// JSON: exchange fields, dupe rule, multipliers, scoring.
  final String definition;
  final bool builtin;
  const ContestDefinitionRow({
    required this.id,
    required this.name,
    this.cabrilloName,
    this.wavelogAdifName,
    required this.version,
    required this.definition,
    required this.builtin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || cabrilloName != null) {
      map['cabrillo_name'] = Variable<String>(cabrilloName);
    }
    if (!nullToAbsent || wavelogAdifName != null) {
      map['wavelog_adif_name'] = Variable<String>(wavelogAdifName);
    }
    map['version'] = Variable<int>(version);
    map['definition'] = Variable<String>(definition);
    map['builtin'] = Variable<bool>(builtin);
    return map;
  }

  ContestDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return ContestDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      cabrilloName: cabrilloName == null && nullToAbsent
          ? const Value.absent()
          : Value(cabrilloName),
      wavelogAdifName: wavelogAdifName == null && nullToAbsent
          ? const Value.absent()
          : Value(wavelogAdifName),
      version: Value(version),
      definition: Value(definition),
      builtin: Value(builtin),
    );
  }

  factory ContestDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContestDefinitionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cabrilloName: serializer.fromJson<String?>(json['cabrilloName']),
      wavelogAdifName: serializer.fromJson<String?>(json['wavelogAdifName']),
      version: serializer.fromJson<int>(json['version']),
      definition: serializer.fromJson<String>(json['definition']),
      builtin: serializer.fromJson<bool>(json['builtin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'cabrilloName': serializer.toJson<String?>(cabrilloName),
      'wavelogAdifName': serializer.toJson<String?>(wavelogAdifName),
      'version': serializer.toJson<int>(version),
      'definition': serializer.toJson<String>(definition),
      'builtin': serializer.toJson<bool>(builtin),
    };
  }

  ContestDefinitionRow copyWith({
    String? id,
    String? name,
    Value<String?> cabrilloName = const Value.absent(),
    Value<String?> wavelogAdifName = const Value.absent(),
    int? version,
    String? definition,
    bool? builtin,
  }) => ContestDefinitionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    cabrilloName: cabrilloName.present ? cabrilloName.value : this.cabrilloName,
    wavelogAdifName: wavelogAdifName.present
        ? wavelogAdifName.value
        : this.wavelogAdifName,
    version: version ?? this.version,
    definition: definition ?? this.definition,
    builtin: builtin ?? this.builtin,
  );
  ContestDefinitionRow copyWithCompanion(ContestDefinitionsCompanion data) {
    return ContestDefinitionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cabrilloName: data.cabrilloName.present
          ? data.cabrilloName.value
          : this.cabrilloName,
      wavelogAdifName: data.wavelogAdifName.present
          ? data.wavelogAdifName.value
          : this.wavelogAdifName,
      version: data.version.present ? data.version.value : this.version,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      builtin: data.builtin.present ? data.builtin.value : this.builtin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContestDefinitionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cabrilloName: $cabrilloName, ')
          ..write('wavelogAdifName: $wavelogAdifName, ')
          ..write('version: $version, ')
          ..write('definition: $definition, ')
          ..write('builtin: $builtin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    cabrilloName,
    wavelogAdifName,
    version,
    definition,
    builtin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContestDefinitionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.cabrilloName == this.cabrilloName &&
          other.wavelogAdifName == this.wavelogAdifName &&
          other.version == this.version &&
          other.definition == this.definition &&
          other.builtin == this.builtin);
}

class ContestDefinitionsCompanion
    extends UpdateCompanion<ContestDefinitionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> cabrilloName;
  final Value<String?> wavelogAdifName;
  final Value<int> version;
  final Value<String> definition;
  final Value<bool> builtin;
  final Value<int> rowid;
  const ContestDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cabrilloName = const Value.absent(),
    this.wavelogAdifName = const Value.absent(),
    this.version = const Value.absent(),
    this.definition = const Value.absent(),
    this.builtin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContestDefinitionsCompanion.insert({
    required String id,
    required String name,
    this.cabrilloName = const Value.absent(),
    this.wavelogAdifName = const Value.absent(),
    required int version,
    required String definition,
    this.builtin = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       version = Value(version),
       definition = Value(definition);
  static Insertable<ContestDefinitionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? cabrilloName,
    Expression<String>? wavelogAdifName,
    Expression<int>? version,
    Expression<String>? definition,
    Expression<bool>? builtin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cabrilloName != null) 'cabrillo_name': cabrilloName,
      if (wavelogAdifName != null) 'wavelog_adif_name': wavelogAdifName,
      if (version != null) 'version': version,
      if (definition != null) 'definition': definition,
      if (builtin != null) 'builtin': builtin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContestDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? cabrilloName,
    Value<String?>? wavelogAdifName,
    Value<int>? version,
    Value<String>? definition,
    Value<bool>? builtin,
    Value<int>? rowid,
  }) {
    return ContestDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cabrilloName: cabrilloName ?? this.cabrilloName,
      wavelogAdifName: wavelogAdifName ?? this.wavelogAdifName,
      version: version ?? this.version,
      definition: definition ?? this.definition,
      builtin: builtin ?? this.builtin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cabrilloName.present) {
      map['cabrillo_name'] = Variable<String>(cabrilloName.value);
    }
    if (wavelogAdifName.present) {
      map['wavelog_adif_name'] = Variable<String>(wavelogAdifName.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (builtin.present) {
      map['builtin'] = Variable<bool>(builtin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContestDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cabrilloName: $cabrilloName, ')
          ..write('wavelogAdifName: $wavelogAdifName, ')
          ..write('version: $version, ')
          ..write('definition: $definition, ')
          ..write('builtin: $builtin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContestSessionsTable extends ContestSessions
    with TableInfo<$ContestSessionsTable, ContestSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContestSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCreatedMeta = const VerificationMeta(
    'hlcCreated',
  );
  @override
  late final GeneratedColumn<String> hlcCreated = GeneratedColumn<String>(
    'hlc_created',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcModifiedMeta = const VerificationMeta(
    'hlcModified',
  );
  @override
  late final GeneratedColumn<String> hlcModified = GeneratedColumn<String>(
    'hlc_modified',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contest_definitions (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _stationProfileIdMeta = const VerificationMeta(
    'stationProfileId',
  );
  @override
  late final GeneratedColumn<String> stationProfileId = GeneratedColumn<String>(
    'station_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES station_profiles (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settingsMeta = const VerificationMeta(
    'settings',
  );
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
    'settings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _remoteSessionIdMeta = const VerificationMeta(
    'remoteSessionId',
  );
  @override
  late final GeneratedColumn<int> remoteSessionId = GeneratedColumn<int>(
    'remote_session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialStrategyMeta = const VerificationMeta(
    'serialStrategy',
  );
  @override
  late final GeneratedColumn<String> serialStrategy = GeneratedColumn<String>(
    'serial_strategy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('single'),
  );
  static const VerificationMeta _serialRangeStartMeta = const VerificationMeta(
    'serialRangeStart',
  );
  @override
  late final GeneratedColumn<int> serialRangeStart = GeneratedColumn<int>(
    'serial_range_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialRangeEndMeta = const VerificationMeta(
    'serialRangeEnd',
  );
  @override
  late final GeneratedColumn<int> serialRangeEnd = GeneratedColumn<int>(
    'serial_range_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    originDeviceId,
    hlcCreated,
    hlcModified,
    rev,
    deletedAt,
    id,
    definitionId,
    accountId,
    stationProfileId,
    startedAt,
    endedAt,
    settings,
    remoteSessionId,
    serialStrategy,
    serialRangeStart,
    serialRangeEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contest_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContestSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('hlc_created')) {
      context.handle(
        _hlcCreatedMeta,
        hlcCreated.isAcceptableOrUnknown(data['hlc_created']!, _hlcCreatedMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCreatedMeta);
    }
    if (data.containsKey('hlc_modified')) {
      context.handle(
        _hlcModifiedMeta,
        hlcModified.isAcceptableOrUnknown(
          data['hlc_modified']!,
          _hlcModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcModifiedMeta);
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('station_profile_id')) {
      context.handle(
        _stationProfileIdMeta,
        stationProfileId.isAcceptableOrUnknown(
          data['station_profile_id']!,
          _stationProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('settings')) {
      context.handle(
        _settingsMeta,
        settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta),
      );
    }
    if (data.containsKey('remote_session_id')) {
      context.handle(
        _remoteSessionIdMeta,
        remoteSessionId.isAcceptableOrUnknown(
          data['remote_session_id']!,
          _remoteSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('serial_strategy')) {
      context.handle(
        _serialStrategyMeta,
        serialStrategy.isAcceptableOrUnknown(
          data['serial_strategy']!,
          _serialStrategyMeta,
        ),
      );
    }
    if (data.containsKey('serial_range_start')) {
      context.handle(
        _serialRangeStartMeta,
        serialRangeStart.isAcceptableOrUnknown(
          data['serial_range_start']!,
          _serialRangeStartMeta,
        ),
      );
    }
    if (data.containsKey('serial_range_end')) {
      context.handle(
        _serialRangeEndMeta,
        serialRangeEnd.isAcceptableOrUnknown(
          data['serial_range_end']!,
          _serialRangeEndMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContestSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContestSessionRow(
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      hlcCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_created'],
      )!,
      hlcModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_modified'],
      )!,
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      stationProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_profile_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      settings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings'],
      )!,
      remoteSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_session_id'],
      ),
      serialStrategy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_strategy'],
      )!,
      serialRangeStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serial_range_start'],
      ),
      serialRangeEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serial_range_end'],
      ),
    );
  }

  @override
  $ContestSessionsTable createAlias(String alias) {
    return $ContestSessionsTable(attachedDatabase, alias);
  }
}

class ContestSessionRow extends DataClass
    implements Insertable<ContestSessionRow> {
  /// Device that created the row.
  final String originDeviceId;

  /// Hybrid logical clock timestamp of creation.
  final String hlcCreated;

  /// Hybrid logical clock timestamp of the last change.
  final String hlcModified;

  /// Local revision counter, incremented on every change.
  final int rev;

  /// Tombstone: UTC millis of deletion, or null while the row is alive.
  final int? deletedAt;
  final String id;
  final String definitionId;
  final String accountId;
  final String? stationProfileId;
  final int startedAt;
  final int? endedAt;

  /// JSON session settings (own exchange, serial options, …).
  final String settings;

  /// Wavelog contest session id (Wavelog 3.2+), once created.
  final int? remoteSessionId;

  /// `single`, `prefix` or `range` (multi-operator serial strategies).
  final String serialStrategy;
  final int? serialRangeStart;
  final int? serialRangeEnd;
  const ContestSessionRow({
    required this.originDeviceId,
    required this.hlcCreated,
    required this.hlcModified,
    required this.rev,
    this.deletedAt,
    required this.id,
    required this.definitionId,
    required this.accountId,
    this.stationProfileId,
    required this.startedAt,
    this.endedAt,
    required this.settings,
    this.remoteSessionId,
    required this.serialStrategy,
    this.serialRangeStart,
    this.serialRangeEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['hlc_created'] = Variable<String>(hlcCreated);
    map['hlc_modified'] = Variable<String>(hlcModified);
    map['rev'] = Variable<int>(rev);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['definition_id'] = Variable<String>(definitionId);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || stationProfileId != null) {
      map['station_profile_id'] = Variable<String>(stationProfileId);
    }
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['settings'] = Variable<String>(settings);
    if (!nullToAbsent || remoteSessionId != null) {
      map['remote_session_id'] = Variable<int>(remoteSessionId);
    }
    map['serial_strategy'] = Variable<String>(serialStrategy);
    if (!nullToAbsent || serialRangeStart != null) {
      map['serial_range_start'] = Variable<int>(serialRangeStart);
    }
    if (!nullToAbsent || serialRangeEnd != null) {
      map['serial_range_end'] = Variable<int>(serialRangeEnd);
    }
    return map;
  }

  ContestSessionsCompanion toCompanion(bool nullToAbsent) {
    return ContestSessionsCompanion(
      originDeviceId: Value(originDeviceId),
      hlcCreated: Value(hlcCreated),
      hlcModified: Value(hlcModified),
      rev: Value(rev),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      definitionId: Value(definitionId),
      accountId: Value(accountId),
      stationProfileId: stationProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(stationProfileId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      settings: Value(settings),
      remoteSessionId: remoteSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteSessionId),
      serialStrategy: Value(serialStrategy),
      serialRangeStart: serialRangeStart == null && nullToAbsent
          ? const Value.absent()
          : Value(serialRangeStart),
      serialRangeEnd: serialRangeEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(serialRangeEnd),
    );
  }

  factory ContestSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContestSessionRow(
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      hlcCreated: serializer.fromJson<String>(json['hlcCreated']),
      hlcModified: serializer.fromJson<String>(json['hlcModified']),
      rev: serializer.fromJson<int>(json['rev']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      stationProfileId: serializer.fromJson<String?>(json['stationProfileId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      settings: serializer.fromJson<String>(json['settings']),
      remoteSessionId: serializer.fromJson<int?>(json['remoteSessionId']),
      serialStrategy: serializer.fromJson<String>(json['serialStrategy']),
      serialRangeStart: serializer.fromJson<int?>(json['serialRangeStart']),
      serialRangeEnd: serializer.fromJson<int?>(json['serialRangeEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'hlcCreated': serializer.toJson<String>(hlcCreated),
      'hlcModified': serializer.toJson<String>(hlcModified),
      'rev': serializer.toJson<int>(rev),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'definitionId': serializer.toJson<String>(definitionId),
      'accountId': serializer.toJson<String>(accountId),
      'stationProfileId': serializer.toJson<String?>(stationProfileId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'settings': serializer.toJson<String>(settings),
      'remoteSessionId': serializer.toJson<int?>(remoteSessionId),
      'serialStrategy': serializer.toJson<String>(serialStrategy),
      'serialRangeStart': serializer.toJson<int?>(serialRangeStart),
      'serialRangeEnd': serializer.toJson<int?>(serialRangeEnd),
    };
  }

  ContestSessionRow copyWith({
    String? originDeviceId,
    String? hlcCreated,
    String? hlcModified,
    int? rev,
    Value<int?> deletedAt = const Value.absent(),
    String? id,
    String? definitionId,
    String? accountId,
    Value<String?> stationProfileId = const Value.absent(),
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    String? settings,
    Value<int?> remoteSessionId = const Value.absent(),
    String? serialStrategy,
    Value<int?> serialRangeStart = const Value.absent(),
    Value<int?> serialRangeEnd = const Value.absent(),
  }) => ContestSessionRow(
    originDeviceId: originDeviceId ?? this.originDeviceId,
    hlcCreated: hlcCreated ?? this.hlcCreated,
    hlcModified: hlcModified ?? this.hlcModified,
    rev: rev ?? this.rev,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    definitionId: definitionId ?? this.definitionId,
    accountId: accountId ?? this.accountId,
    stationProfileId: stationProfileId.present
        ? stationProfileId.value
        : this.stationProfileId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    settings: settings ?? this.settings,
    remoteSessionId: remoteSessionId.present
        ? remoteSessionId.value
        : this.remoteSessionId,
    serialStrategy: serialStrategy ?? this.serialStrategy,
    serialRangeStart: serialRangeStart.present
        ? serialRangeStart.value
        : this.serialRangeStart,
    serialRangeEnd: serialRangeEnd.present
        ? serialRangeEnd.value
        : this.serialRangeEnd,
  );
  ContestSessionRow copyWithCompanion(ContestSessionsCompanion data) {
    return ContestSessionRow(
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      hlcCreated: data.hlcCreated.present
          ? data.hlcCreated.value
          : this.hlcCreated,
      hlcModified: data.hlcModified.present
          ? data.hlcModified.value
          : this.hlcModified,
      rev: data.rev.present ? data.rev.value : this.rev,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      stationProfileId: data.stationProfileId.present
          ? data.stationProfileId.value
          : this.stationProfileId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      settings: data.settings.present ? data.settings.value : this.settings,
      remoteSessionId: data.remoteSessionId.present
          ? data.remoteSessionId.value
          : this.remoteSessionId,
      serialStrategy: data.serialStrategy.present
          ? data.serialStrategy.value
          : this.serialStrategy,
      serialRangeStart: data.serialRangeStart.present
          ? data.serialRangeStart.value
          : this.serialRangeStart,
      serialRangeEnd: data.serialRangeEnd.present
          ? data.serialRangeEnd.value
          : this.serialRangeEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContestSessionRow(')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('hlcCreated: $hlcCreated, ')
          ..write('hlcModified: $hlcModified, ')
          ..write('rev: $rev, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('accountId: $accountId, ')
          ..write('stationProfileId: $stationProfileId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('settings: $settings, ')
          ..write('remoteSessionId: $remoteSessionId, ')
          ..write('serialStrategy: $serialStrategy, ')
          ..write('serialRangeStart: $serialRangeStart, ')
          ..write('serialRangeEnd: $serialRangeEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    originDeviceId,
    hlcCreated,
    hlcModified,
    rev,
    deletedAt,
    id,
    definitionId,
    accountId,
    stationProfileId,
    startedAt,
    endedAt,
    settings,
    remoteSessionId,
    serialStrategy,
    serialRangeStart,
    serialRangeEnd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContestSessionRow &&
          other.originDeviceId == this.originDeviceId &&
          other.hlcCreated == this.hlcCreated &&
          other.hlcModified == this.hlcModified &&
          other.rev == this.rev &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.definitionId == this.definitionId &&
          other.accountId == this.accountId &&
          other.stationProfileId == this.stationProfileId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.settings == this.settings &&
          other.remoteSessionId == this.remoteSessionId &&
          other.serialStrategy == this.serialStrategy &&
          other.serialRangeStart == this.serialRangeStart &&
          other.serialRangeEnd == this.serialRangeEnd);
}

class ContestSessionsCompanion extends UpdateCompanion<ContestSessionRow> {
  final Value<String> originDeviceId;
  final Value<String> hlcCreated;
  final Value<String> hlcModified;
  final Value<int> rev;
  final Value<int?> deletedAt;
  final Value<String> id;
  final Value<String> definitionId;
  final Value<String> accountId;
  final Value<String?> stationProfileId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<String> settings;
  final Value<int?> remoteSessionId;
  final Value<String> serialStrategy;
  final Value<int?> serialRangeStart;
  final Value<int?> serialRangeEnd;
  final Value<int> rowid;
  const ContestSessionsCompanion({
    this.originDeviceId = const Value.absent(),
    this.hlcCreated = const Value.absent(),
    this.hlcModified = const Value.absent(),
    this.rev = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.stationProfileId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.settings = const Value.absent(),
    this.remoteSessionId = const Value.absent(),
    this.serialStrategy = const Value.absent(),
    this.serialRangeStart = const Value.absent(),
    this.serialRangeEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContestSessionsCompanion.insert({
    required String originDeviceId,
    required String hlcCreated,
    required String hlcModified,
    this.rev = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String definitionId,
    required String accountId,
    this.stationProfileId = const Value.absent(),
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.settings = const Value.absent(),
    this.remoteSessionId = const Value.absent(),
    this.serialStrategy = const Value.absent(),
    this.serialRangeStart = const Value.absent(),
    this.serialRangeEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : originDeviceId = Value(originDeviceId),
       hlcCreated = Value(hlcCreated),
       hlcModified = Value(hlcModified),
       id = Value(id),
       definitionId = Value(definitionId),
       accountId = Value(accountId),
       startedAt = Value(startedAt);
  static Insertable<ContestSessionRow> custom({
    Expression<String>? originDeviceId,
    Expression<String>? hlcCreated,
    Expression<String>? hlcModified,
    Expression<int>? rev,
    Expression<int>? deletedAt,
    Expression<String>? id,
    Expression<String>? definitionId,
    Expression<String>? accountId,
    Expression<String>? stationProfileId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<String>? settings,
    Expression<int>? remoteSessionId,
    Expression<String>? serialStrategy,
    Expression<int>? serialRangeStart,
    Expression<int>? serialRangeEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (hlcCreated != null) 'hlc_created': hlcCreated,
      if (hlcModified != null) 'hlc_modified': hlcModified,
      if (rev != null) 'rev': rev,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (definitionId != null) 'definition_id': definitionId,
      if (accountId != null) 'account_id': accountId,
      if (stationProfileId != null) 'station_profile_id': stationProfileId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (settings != null) 'settings': settings,
      if (remoteSessionId != null) 'remote_session_id': remoteSessionId,
      if (serialStrategy != null) 'serial_strategy': serialStrategy,
      if (serialRangeStart != null) 'serial_range_start': serialRangeStart,
      if (serialRangeEnd != null) 'serial_range_end': serialRangeEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContestSessionsCompanion copyWith({
    Value<String>? originDeviceId,
    Value<String>? hlcCreated,
    Value<String>? hlcModified,
    Value<int>? rev,
    Value<int?>? deletedAt,
    Value<String>? id,
    Value<String>? definitionId,
    Value<String>? accountId,
    Value<String?>? stationProfileId,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<String>? settings,
    Value<int?>? remoteSessionId,
    Value<String>? serialStrategy,
    Value<int?>? serialRangeStart,
    Value<int?>? serialRangeEnd,
    Value<int>? rowid,
  }) {
    return ContestSessionsCompanion(
      originDeviceId: originDeviceId ?? this.originDeviceId,
      hlcCreated: hlcCreated ?? this.hlcCreated,
      hlcModified: hlcModified ?? this.hlcModified,
      rev: rev ?? this.rev,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      definitionId: definitionId ?? this.definitionId,
      accountId: accountId ?? this.accountId,
      stationProfileId: stationProfileId ?? this.stationProfileId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      settings: settings ?? this.settings,
      remoteSessionId: remoteSessionId ?? this.remoteSessionId,
      serialStrategy: serialStrategy ?? this.serialStrategy,
      serialRangeStart: serialRangeStart ?? this.serialRangeStart,
      serialRangeEnd: serialRangeEnd ?? this.serialRangeEnd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (hlcCreated.present) {
      map['hlc_created'] = Variable<String>(hlcCreated.value);
    }
    if (hlcModified.present) {
      map['hlc_modified'] = Variable<String>(hlcModified.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (stationProfileId.present) {
      map['station_profile_id'] = Variable<String>(stationProfileId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (remoteSessionId.present) {
      map['remote_session_id'] = Variable<int>(remoteSessionId.value);
    }
    if (serialStrategy.present) {
      map['serial_strategy'] = Variable<String>(serialStrategy.value);
    }
    if (serialRangeStart.present) {
      map['serial_range_start'] = Variable<int>(serialRangeStart.value);
    }
    if (serialRangeEnd.present) {
      map['serial_range_end'] = Variable<int>(serialRangeEnd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContestSessionsCompanion(')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('hlcCreated: $hlcCreated, ')
          ..write('hlcModified: $hlcModified, ')
          ..write('rev: $rev, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('accountId: $accountId, ')
          ..write('stationProfileId: $stationProfileId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('settings: $settings, ')
          ..write('remoteSessionId: $remoteSessionId, ')
          ..write('serialStrategy: $serialStrategy, ')
          ..write('serialRangeStart: $serialRangeStart, ')
          ..write('serialRangeEnd: $serialRangeEnd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivationsTable extends Activations
    with TableInfo<$ActivationsTable, ActivationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCreatedMeta = const VerificationMeta(
    'hlcCreated',
  );
  @override
  late final GeneratedColumn<String> hlcCreated = GeneratedColumn<String>(
    'hlc_created',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcModifiedMeta = const VerificationMeta(
    'hlcModified',
  );
  @override
  late final GeneratedColumn<String> hlcModified = GeneratedColumn<String>(
    'hlc_modified',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _programMeta = const VerificationMeta(
    'program',
  );
  @override
  late final GeneratedColumn<String> program = GeneratedColumn<String>(
    'program',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _myGridsquareMeta = const VerificationMeta(
    'myGridsquare',
  );
  @override
  late final GeneratedColumn<String> myGridsquare = GeneratedColumn<String>(
    'my_gridsquare',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stationProfileIdMeta = const VerificationMeta(
    'stationProfileId',
  );
  @override
  late final GeneratedColumn<String> stationProfileId = GeneratedColumn<String>(
    'station_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES station_profiles (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    originDeviceId,
    hlcCreated,
    hlcModified,
    rev,
    deletedAt,
    id,
    accountId,
    program,
    reference,
    myGridsquare,
    stationProfileId,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('hlc_created')) {
      context.handle(
        _hlcCreatedMeta,
        hlcCreated.isAcceptableOrUnknown(data['hlc_created']!, _hlcCreatedMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCreatedMeta);
    }
    if (data.containsKey('hlc_modified')) {
      context.handle(
        _hlcModifiedMeta,
        hlcModified.isAcceptableOrUnknown(
          data['hlc_modified']!,
          _hlcModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcModifiedMeta);
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('program')) {
      context.handle(
        _programMeta,
        program.isAcceptableOrUnknown(data['program']!, _programMeta),
      );
    } else if (isInserting) {
      context.missing(_programMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('my_gridsquare')) {
      context.handle(
        _myGridsquareMeta,
        myGridsquare.isAcceptableOrUnknown(
          data['my_gridsquare']!,
          _myGridsquareMeta,
        ),
      );
    }
    if (data.containsKey('station_profile_id')) {
      context.handle(
        _stationProfileIdMeta,
        stationProfileId.isAcceptableOrUnknown(
          data['station_profile_id']!,
          _stationProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivationRow(
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      hlcCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_created'],
      )!,
      hlcModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_modified'],
      )!,
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      program: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      myGridsquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_gridsquare'],
      ),
      stationProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_profile_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $ActivationsTable createAlias(String alias) {
    return $ActivationsTable(attachedDatabase, alias);
  }
}

class ActivationRow extends DataClass implements Insertable<ActivationRow> {
  /// Device that created the row.
  final String originDeviceId;

  /// Hybrid logical clock timestamp of creation.
  final String hlcCreated;

  /// Hybrid logical clock timestamp of the last change.
  final String hlcModified;

  /// Local revision counter, incremented on every change.
  final int rev;

  /// Tombstone: UTC millis of deletion, or null while the row is alive.
  final int? deletedAt;
  final String id;
  final String accountId;
  final String program;
  final String reference;
  final String? myGridsquare;
  final String? stationProfileId;
  final int startedAt;
  final int? endedAt;
  const ActivationRow({
    required this.originDeviceId,
    required this.hlcCreated,
    required this.hlcModified,
    required this.rev,
    this.deletedAt,
    required this.id,
    required this.accountId,
    required this.program,
    required this.reference,
    this.myGridsquare,
    this.stationProfileId,
    required this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['hlc_created'] = Variable<String>(hlcCreated);
    map['hlc_modified'] = Variable<String>(hlcModified);
    map['rev'] = Variable<int>(rev);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['program'] = Variable<String>(program);
    map['reference'] = Variable<String>(reference);
    if (!nullToAbsent || myGridsquare != null) {
      map['my_gridsquare'] = Variable<String>(myGridsquare);
    }
    if (!nullToAbsent || stationProfileId != null) {
      map['station_profile_id'] = Variable<String>(stationProfileId);
    }
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    return map;
  }

  ActivationsCompanion toCompanion(bool nullToAbsent) {
    return ActivationsCompanion(
      originDeviceId: Value(originDeviceId),
      hlcCreated: Value(hlcCreated),
      hlcModified: Value(hlcModified),
      rev: Value(rev),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      accountId: Value(accountId),
      program: Value(program),
      reference: Value(reference),
      myGridsquare: myGridsquare == null && nullToAbsent
          ? const Value.absent()
          : Value(myGridsquare),
      stationProfileId: stationProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(stationProfileId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory ActivationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivationRow(
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      hlcCreated: serializer.fromJson<String>(json['hlcCreated']),
      hlcModified: serializer.fromJson<String>(json['hlcModified']),
      rev: serializer.fromJson<int>(json['rev']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      program: serializer.fromJson<String>(json['program']),
      reference: serializer.fromJson<String>(json['reference']),
      myGridsquare: serializer.fromJson<String?>(json['myGridsquare']),
      stationProfileId: serializer.fromJson<String?>(json['stationProfileId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'hlcCreated': serializer.toJson<String>(hlcCreated),
      'hlcModified': serializer.toJson<String>(hlcModified),
      'rev': serializer.toJson<int>(rev),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'program': serializer.toJson<String>(program),
      'reference': serializer.toJson<String>(reference),
      'myGridsquare': serializer.toJson<String?>(myGridsquare),
      'stationProfileId': serializer.toJson<String?>(stationProfileId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
    };
  }

  ActivationRow copyWith({
    String? originDeviceId,
    String? hlcCreated,
    String? hlcModified,
    int? rev,
    Value<int?> deletedAt = const Value.absent(),
    String? id,
    String? accountId,
    String? program,
    String? reference,
    Value<String?> myGridsquare = const Value.absent(),
    Value<String?> stationProfileId = const Value.absent(),
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
  }) => ActivationRow(
    originDeviceId: originDeviceId ?? this.originDeviceId,
    hlcCreated: hlcCreated ?? this.hlcCreated,
    hlcModified: hlcModified ?? this.hlcModified,
    rev: rev ?? this.rev,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    program: program ?? this.program,
    reference: reference ?? this.reference,
    myGridsquare: myGridsquare.present ? myGridsquare.value : this.myGridsquare,
    stationProfileId: stationProfileId.present
        ? stationProfileId.value
        : this.stationProfileId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  ActivationRow copyWithCompanion(ActivationsCompanion data) {
    return ActivationRow(
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      hlcCreated: data.hlcCreated.present
          ? data.hlcCreated.value
          : this.hlcCreated,
      hlcModified: data.hlcModified.present
          ? data.hlcModified.value
          : this.hlcModified,
      rev: data.rev.present ? data.rev.value : this.rev,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      program: data.program.present ? data.program.value : this.program,
      reference: data.reference.present ? data.reference.value : this.reference,
      myGridsquare: data.myGridsquare.present
          ? data.myGridsquare.value
          : this.myGridsquare,
      stationProfileId: data.stationProfileId.present
          ? data.stationProfileId.value
          : this.stationProfileId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivationRow(')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('hlcCreated: $hlcCreated, ')
          ..write('hlcModified: $hlcModified, ')
          ..write('rev: $rev, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('program: $program, ')
          ..write('reference: $reference, ')
          ..write('myGridsquare: $myGridsquare, ')
          ..write('stationProfileId: $stationProfileId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    originDeviceId,
    hlcCreated,
    hlcModified,
    rev,
    deletedAt,
    id,
    accountId,
    program,
    reference,
    myGridsquare,
    stationProfileId,
    startedAt,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivationRow &&
          other.originDeviceId == this.originDeviceId &&
          other.hlcCreated == this.hlcCreated &&
          other.hlcModified == this.hlcModified &&
          other.rev == this.rev &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.program == this.program &&
          other.reference == this.reference &&
          other.myGridsquare == this.myGridsquare &&
          other.stationProfileId == this.stationProfileId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class ActivationsCompanion extends UpdateCompanion<ActivationRow> {
  final Value<String> originDeviceId;
  final Value<String> hlcCreated;
  final Value<String> hlcModified;
  final Value<int> rev;
  final Value<int?> deletedAt;
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> program;
  final Value<String> reference;
  final Value<String?> myGridsquare;
  final Value<String?> stationProfileId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int> rowid;
  const ActivationsCompanion({
    this.originDeviceId = const Value.absent(),
    this.hlcCreated = const Value.absent(),
    this.hlcModified = const Value.absent(),
    this.rev = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.program = const Value.absent(),
    this.reference = const Value.absent(),
    this.myGridsquare = const Value.absent(),
    this.stationProfileId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivationsCompanion.insert({
    required String originDeviceId,
    required String hlcCreated,
    required String hlcModified,
    this.rev = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String accountId,
    required String program,
    required String reference,
    this.myGridsquare = const Value.absent(),
    this.stationProfileId = const Value.absent(),
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : originDeviceId = Value(originDeviceId),
       hlcCreated = Value(hlcCreated),
       hlcModified = Value(hlcModified),
       id = Value(id),
       accountId = Value(accountId),
       program = Value(program),
       reference = Value(reference),
       startedAt = Value(startedAt);
  static Insertable<ActivationRow> custom({
    Expression<String>? originDeviceId,
    Expression<String>? hlcCreated,
    Expression<String>? hlcModified,
    Expression<int>? rev,
    Expression<int>? deletedAt,
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? program,
    Expression<String>? reference,
    Expression<String>? myGridsquare,
    Expression<String>? stationProfileId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (hlcCreated != null) 'hlc_created': hlcCreated,
      if (hlcModified != null) 'hlc_modified': hlcModified,
      if (rev != null) 'rev': rev,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (program != null) 'program': program,
      if (reference != null) 'reference': reference,
      if (myGridsquare != null) 'my_gridsquare': myGridsquare,
      if (stationProfileId != null) 'station_profile_id': stationProfileId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivationsCompanion copyWith({
    Value<String>? originDeviceId,
    Value<String>? hlcCreated,
    Value<String>? hlcModified,
    Value<int>? rev,
    Value<int?>? deletedAt,
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? program,
    Value<String>? reference,
    Value<String?>? myGridsquare,
    Value<String?>? stationProfileId,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int>? rowid,
  }) {
    return ActivationsCompanion(
      originDeviceId: originDeviceId ?? this.originDeviceId,
      hlcCreated: hlcCreated ?? this.hlcCreated,
      hlcModified: hlcModified ?? this.hlcModified,
      rev: rev ?? this.rev,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      program: program ?? this.program,
      reference: reference ?? this.reference,
      myGridsquare: myGridsquare ?? this.myGridsquare,
      stationProfileId: stationProfileId ?? this.stationProfileId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (hlcCreated.present) {
      map['hlc_created'] = Variable<String>(hlcCreated.value);
    }
    if (hlcModified.present) {
      map['hlc_modified'] = Variable<String>(hlcModified.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (program.present) {
      map['program'] = Variable<String>(program.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (myGridsquare.present) {
      map['my_gridsquare'] = Variable<String>(myGridsquare.value);
    }
    if (stationProfileId.present) {
      map['station_profile_id'] = Variable<String>(stationProfileId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivationsCompanion(')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('hlcCreated: $hlcCreated, ')
          ..write('hlcModified: $hlcModified, ')
          ..write('rev: $rev, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('program: $program, ')
          ..write('reference: $reference, ')
          ..write('myGridsquare: $myGridsquare, ')
          ..write('stationProfileId: $stationProfileId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QsosTable extends Qsos with TableInfo<$QsosTable, QsoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QsosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCreatedMeta = const VerificationMeta(
    'hlcCreated',
  );
  @override
  late final GeneratedColumn<String> hlcCreated = GeneratedColumn<String>(
    'hlc_created',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcModifiedMeta = const VerificationMeta(
    'hlcModified',
  );
  @override
  late final GeneratedColumn<String> hlcModified = GeneratedColumn<String>(
    'hlc_modified',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _stationProfileIdMeta = const VerificationMeta(
    'stationProfileId',
  );
  @override
  late final GeneratedColumn<String> stationProfileId = GeneratedColumn<String>(
    'station_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES station_profiles (id)',
    ),
  );
  static const VerificationMeta _callMeta = const VerificationMeta('call');
  @override
  late final GeneratedColumn<String> call = GeneratedColumn<String>(
    'call',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeOnMeta = const VerificationMeta('timeOn');
  @override
  late final GeneratedColumn<int> timeOn = GeneratedColumn<int>(
    'time_on',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeOffMeta = const VerificationMeta(
    'timeOff',
  );
  @override
  late final GeneratedColumn<int> timeOff = GeneratedColumn<int>(
    'time_off',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bandMeta = const VerificationMeta('band');
  @override
  late final GeneratedColumn<String> band = GeneratedColumn<String>(
    'band',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bandRxMeta = const VerificationMeta('bandRx');
  @override
  late final GeneratedColumn<String> bandRx = GeneratedColumn<String>(
    'band_rx',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submodeMeta = const VerificationMeta(
    'submode',
  );
  @override
  late final GeneratedColumn<String> submode = GeneratedColumn<String>(
    'submode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freqHzMeta = const VerificationMeta('freqHz');
  @override
  late final GeneratedColumn<int> freqHz = GeneratedColumn<int>(
    'freq_hz',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freqRxHzMeta = const VerificationMeta(
    'freqRxHz',
  );
  @override
  late final GeneratedColumn<int> freqRxHz = GeneratedColumn<int>(
    'freq_rx_hz',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rstSentMeta = const VerificationMeta(
    'rstSent',
  );
  @override
  late final GeneratedColumn<String> rstSent = GeneratedColumn<String>(
    'rst_sent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rstRcvdMeta = const VerificationMeta(
    'rstRcvd',
  );
  @override
  late final GeneratedColumn<String> rstRcvd = GeneratedColumn<String>(
    'rst_rcvd',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qthMeta = const VerificationMeta('qth');
  @override
  late final GeneratedColumn<String> qth = GeneratedColumn<String>(
    'qth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gridsquareMeta = const VerificationMeta(
    'gridsquare',
  );
  @override
  late final GeneratedColumn<String> gridsquare = GeneratedColumn<String>(
    'gridsquare',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dxccMeta = const VerificationMeta('dxcc');
  @override
  late final GeneratedColumn<int> dxcc = GeneratedColumn<int>(
    'dxcc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cqzMeta = const VerificationMeta('cqz');
  @override
  late final GeneratedColumn<int> cqz = GeneratedColumn<int>(
    'cqz',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ituzMeta = const VerificationMeta('ituz');
  @override
  late final GeneratedColumn<int> ituz = GeneratedColumn<int>(
    'ituz',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cntyMeta = const VerificationMeta('cnty');
  @override
  late final GeneratedColumn<String> cnty = GeneratedColumn<String>(
    'cnty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contMeta = const VerificationMeta('cont');
  @override
  late final GeneratedColumn<String> cont = GeneratedColumn<String>(
    'cont',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _darcDokMeta = const VerificationMeta(
    'darcDok',
  );
  @override
  late final GeneratedColumn<String> darcDok = GeneratedColumn<String>(
    'darc_dok',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iotaMeta = const VerificationMeta('iota');
  @override
  late final GeneratedColumn<String> iota = GeneratedColumn<String>(
    'iota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sotaRefMeta = const VerificationMeta(
    'sotaRef',
  );
  @override
  late final GeneratedColumn<String> sotaRef = GeneratedColumn<String>(
    'sota_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potaRefMeta = const VerificationMeta(
    'potaRef',
  );
  @override
  late final GeneratedColumn<String> potaRef = GeneratedColumn<String>(
    'pota_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wwffRefMeta = const VerificationMeta(
    'wwffRef',
  );
  @override
  late final GeneratedColumn<String> wwffRef = GeneratedColumn<String>(
    'wwff_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sigMeta = const VerificationMeta('sig');
  @override
  late final GeneratedColumn<String> sig = GeneratedColumn<String>(
    'sig',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sigInfoMeta = const VerificationMeta(
    'sigInfo',
  );
  @override
  late final GeneratedColumn<String> sigInfo = GeneratedColumn<String>(
    'sig_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mySotaRefMeta = const VerificationMeta(
    'mySotaRef',
  );
  @override
  late final GeneratedColumn<String> mySotaRef = GeneratedColumn<String>(
    'my_sota_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _myPotaRefMeta = const VerificationMeta(
    'myPotaRef',
  );
  @override
  late final GeneratedColumn<String> myPotaRef = GeneratedColumn<String>(
    'my_pota_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _myWwffRefMeta = const VerificationMeta(
    'myWwffRef',
  );
  @override
  late final GeneratedColumn<String> myWwffRef = GeneratedColumn<String>(
    'my_wwff_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mySigMeta = const VerificationMeta('mySig');
  @override
  late final GeneratedColumn<String> mySig = GeneratedColumn<String>(
    'my_sig',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mySigInfoMeta = const VerificationMeta(
    'mySigInfo',
  );
  @override
  late final GeneratedColumn<String> mySigInfo = GeneratedColumn<String>(
    'my_sig_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stationCallsignMeta = const VerificationMeta(
    'stationCallsign',
  );
  @override
  late final GeneratedColumn<String> stationCallsign = GeneratedColumn<String>(
    'station_callsign',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operatorMeta = const VerificationMeta(
    'operator',
  );
  @override
  late final GeneratedColumn<String> operator = GeneratedColumn<String>(
    'operator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _myGridsquareMeta = const VerificationMeta(
    'myGridsquare',
  );
  @override
  late final GeneratedColumn<String> myGridsquare = GeneratedColumn<String>(
    'my_gridsquare',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _txPwrMeta = const VerificationMeta('txPwr');
  @override
  late final GeneratedColumn<double> txPwr = GeneratedColumn<double>(
    'tx_pwr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contestIdMeta = const VerificationMeta(
    'contestId',
  );
  @override
  late final GeneratedColumn<String> contestId = GeneratedColumn<String>(
    'contest_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _srxMeta = const VerificationMeta('srx');
  @override
  late final GeneratedColumn<int> srx = GeneratedColumn<int>(
    'srx',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stxMeta = const VerificationMeta('stx');
  @override
  late final GeneratedColumn<int> stx = GeneratedColumn<int>(
    'stx',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _srxStringMeta = const VerificationMeta(
    'srxString',
  );
  @override
  late final GeneratedColumn<String> srxString = GeneratedColumn<String>(
    'srx_string',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stxStringMeta = const VerificationMeta(
    'stxString',
  );
  @override
  late final GeneratedColumn<String> stxString = GeneratedColumn<String>(
    'stx_string',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkMeta = const VerificationMeta('check');
  @override
  late final GeneratedColumn<String> check = GeneratedColumn<String>(
    'check',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qsoClassMeta = const VerificationMeta(
    'qsoClass',
  );
  @override
  late final GeneratedColumn<String> qsoClass = GeneratedColumn<String>(
    'class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _precedenceMeta = const VerificationMeta(
    'precedence',
  );
  @override
  late final GeneratedColumn<String> precedence = GeneratedColumn<String>(
    'precedence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arrlSectMeta = const VerificationMeta(
    'arrlSect',
  );
  @override
  late final GeneratedColumn<String> arrlSect = GeneratedColumn<String>(
    'arrl_sect',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _propModeMeta = const VerificationMeta(
    'propMode',
  );
  @override
  late final GeneratedColumn<String> propMode = GeneratedColumn<String>(
    'prop_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _satNameMeta = const VerificationMeta(
    'satName',
  );
  @override
  late final GeneratedColumn<String> satName = GeneratedColumn<String>(
    'sat_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _satModeMeta = const VerificationMeta(
    'satMode',
  );
  @override
  late final GeneratedColumn<String> satMode = GeneratedColumn<String>(
    'sat_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qslViaMeta = const VerificationMeta('qslVia');
  @override
  late final GeneratedColumn<String> qslVia = GeneratedColumn<String>(
    'qsl_via',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adifExtraMeta = const VerificationMeta(
    'adifExtra',
  );
  @override
  late final GeneratedColumn<String> adifExtra = GeneratedColumn<String>(
    'adif_extra',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _contestSessionIdMeta = const VerificationMeta(
    'contestSessionId',
  );
  @override
  late final GeneratedColumn<String> contestSessionId = GeneratedColumn<String>(
    'contest_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contest_sessions (id)',
    ),
  );
  static const VerificationMeta _activationIdMeta = const VerificationMeta(
    'activationId',
  );
  @override
  late final GeneratedColumn<String> activationId = GeneratedColumn<String>(
    'activation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activations (id)',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    originDeviceId,
    hlcCreated,
    hlcModified,
    rev,
    deletedAt,
    id,
    accountId,
    stationProfileId,
    call,
    timeOn,
    timeOff,
    band,
    bandRx,
    mode,
    submode,
    freqHz,
    freqRxHz,
    rstSent,
    rstRcvd,
    name,
    qth,
    gridsquare,
    dxcc,
    cqz,
    ituz,
    state,
    cnty,
    country,
    cont,
    darcDok,
    iota,
    sotaRef,
    potaRef,
    wwffRef,
    sig,
    sigInfo,
    mySotaRef,
    myPotaRef,
    myWwffRef,
    mySig,
    mySigInfo,
    stationCallsign,
    operator,
    myGridsquare,
    txPwr,
    contestId,
    srx,
    stx,
    srxString,
    stxString,
    check,
    qsoClass,
    precedence,
    arrlSect,
    propMode,
    satName,
    satMode,
    comment,
    notes,
    qslVia,
    adifExtra,
    contestSessionId,
    activationId,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'qsos';
  @override
  VerificationContext validateIntegrity(
    Insertable<QsoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('hlc_created')) {
      context.handle(
        _hlcCreatedMeta,
        hlcCreated.isAcceptableOrUnknown(data['hlc_created']!, _hlcCreatedMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCreatedMeta);
    }
    if (data.containsKey('hlc_modified')) {
      context.handle(
        _hlcModifiedMeta,
        hlcModified.isAcceptableOrUnknown(
          data['hlc_modified']!,
          _hlcModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hlcModifiedMeta);
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('station_profile_id')) {
      context.handle(
        _stationProfileIdMeta,
        stationProfileId.isAcceptableOrUnknown(
          data['station_profile_id']!,
          _stationProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('call')) {
      context.handle(
        _callMeta,
        call.isAcceptableOrUnknown(data['call']!, _callMeta),
      );
    } else if (isInserting) {
      context.missing(_callMeta);
    }
    if (data.containsKey('time_on')) {
      context.handle(
        _timeOnMeta,
        timeOn.isAcceptableOrUnknown(data['time_on']!, _timeOnMeta),
      );
    } else if (isInserting) {
      context.missing(_timeOnMeta);
    }
    if (data.containsKey('time_off')) {
      context.handle(
        _timeOffMeta,
        timeOff.isAcceptableOrUnknown(data['time_off']!, _timeOffMeta),
      );
    }
    if (data.containsKey('band')) {
      context.handle(
        _bandMeta,
        band.isAcceptableOrUnknown(data['band']!, _bandMeta),
      );
    } else if (isInserting) {
      context.missing(_bandMeta);
    }
    if (data.containsKey('band_rx')) {
      context.handle(
        _bandRxMeta,
        bandRx.isAcceptableOrUnknown(data['band_rx']!, _bandRxMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('submode')) {
      context.handle(
        _submodeMeta,
        submode.isAcceptableOrUnknown(data['submode']!, _submodeMeta),
      );
    }
    if (data.containsKey('freq_hz')) {
      context.handle(
        _freqHzMeta,
        freqHz.isAcceptableOrUnknown(data['freq_hz']!, _freqHzMeta),
      );
    }
    if (data.containsKey('freq_rx_hz')) {
      context.handle(
        _freqRxHzMeta,
        freqRxHz.isAcceptableOrUnknown(data['freq_rx_hz']!, _freqRxHzMeta),
      );
    }
    if (data.containsKey('rst_sent')) {
      context.handle(
        _rstSentMeta,
        rstSent.isAcceptableOrUnknown(data['rst_sent']!, _rstSentMeta),
      );
    }
    if (data.containsKey('rst_rcvd')) {
      context.handle(
        _rstRcvdMeta,
        rstRcvd.isAcceptableOrUnknown(data['rst_rcvd']!, _rstRcvdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('qth')) {
      context.handle(
        _qthMeta,
        qth.isAcceptableOrUnknown(data['qth']!, _qthMeta),
      );
    }
    if (data.containsKey('gridsquare')) {
      context.handle(
        _gridsquareMeta,
        gridsquare.isAcceptableOrUnknown(data['gridsquare']!, _gridsquareMeta),
      );
    }
    if (data.containsKey('dxcc')) {
      context.handle(
        _dxccMeta,
        dxcc.isAcceptableOrUnknown(data['dxcc']!, _dxccMeta),
      );
    }
    if (data.containsKey('cqz')) {
      context.handle(
        _cqzMeta,
        cqz.isAcceptableOrUnknown(data['cqz']!, _cqzMeta),
      );
    }
    if (data.containsKey('ituz')) {
      context.handle(
        _ituzMeta,
        ituz.isAcceptableOrUnknown(data['ituz']!, _ituzMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('cnty')) {
      context.handle(
        _cntyMeta,
        cnty.isAcceptableOrUnknown(data['cnty']!, _cntyMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('cont')) {
      context.handle(
        _contMeta,
        cont.isAcceptableOrUnknown(data['cont']!, _contMeta),
      );
    }
    if (data.containsKey('darc_dok')) {
      context.handle(
        _darcDokMeta,
        darcDok.isAcceptableOrUnknown(data['darc_dok']!, _darcDokMeta),
      );
    }
    if (data.containsKey('iota')) {
      context.handle(
        _iotaMeta,
        iota.isAcceptableOrUnknown(data['iota']!, _iotaMeta),
      );
    }
    if (data.containsKey('sota_ref')) {
      context.handle(
        _sotaRefMeta,
        sotaRef.isAcceptableOrUnknown(data['sota_ref']!, _sotaRefMeta),
      );
    }
    if (data.containsKey('pota_ref')) {
      context.handle(
        _potaRefMeta,
        potaRef.isAcceptableOrUnknown(data['pota_ref']!, _potaRefMeta),
      );
    }
    if (data.containsKey('wwff_ref')) {
      context.handle(
        _wwffRefMeta,
        wwffRef.isAcceptableOrUnknown(data['wwff_ref']!, _wwffRefMeta),
      );
    }
    if (data.containsKey('sig')) {
      context.handle(
        _sigMeta,
        sig.isAcceptableOrUnknown(data['sig']!, _sigMeta),
      );
    }
    if (data.containsKey('sig_info')) {
      context.handle(
        _sigInfoMeta,
        sigInfo.isAcceptableOrUnknown(data['sig_info']!, _sigInfoMeta),
      );
    }
    if (data.containsKey('my_sota_ref')) {
      context.handle(
        _mySotaRefMeta,
        mySotaRef.isAcceptableOrUnknown(data['my_sota_ref']!, _mySotaRefMeta),
      );
    }
    if (data.containsKey('my_pota_ref')) {
      context.handle(
        _myPotaRefMeta,
        myPotaRef.isAcceptableOrUnknown(data['my_pota_ref']!, _myPotaRefMeta),
      );
    }
    if (data.containsKey('my_wwff_ref')) {
      context.handle(
        _myWwffRefMeta,
        myWwffRef.isAcceptableOrUnknown(data['my_wwff_ref']!, _myWwffRefMeta),
      );
    }
    if (data.containsKey('my_sig')) {
      context.handle(
        _mySigMeta,
        mySig.isAcceptableOrUnknown(data['my_sig']!, _mySigMeta),
      );
    }
    if (data.containsKey('my_sig_info')) {
      context.handle(
        _mySigInfoMeta,
        mySigInfo.isAcceptableOrUnknown(data['my_sig_info']!, _mySigInfoMeta),
      );
    }
    if (data.containsKey('station_callsign')) {
      context.handle(
        _stationCallsignMeta,
        stationCallsign.isAcceptableOrUnknown(
          data['station_callsign']!,
          _stationCallsignMeta,
        ),
      );
    }
    if (data.containsKey('operator')) {
      context.handle(
        _operatorMeta,
        operator.isAcceptableOrUnknown(data['operator']!, _operatorMeta),
      );
    }
    if (data.containsKey('my_gridsquare')) {
      context.handle(
        _myGridsquareMeta,
        myGridsquare.isAcceptableOrUnknown(
          data['my_gridsquare']!,
          _myGridsquareMeta,
        ),
      );
    }
    if (data.containsKey('tx_pwr')) {
      context.handle(
        _txPwrMeta,
        txPwr.isAcceptableOrUnknown(data['tx_pwr']!, _txPwrMeta),
      );
    }
    if (data.containsKey('contest_id')) {
      context.handle(
        _contestIdMeta,
        contestId.isAcceptableOrUnknown(data['contest_id']!, _contestIdMeta),
      );
    }
    if (data.containsKey('srx')) {
      context.handle(
        _srxMeta,
        srx.isAcceptableOrUnknown(data['srx']!, _srxMeta),
      );
    }
    if (data.containsKey('stx')) {
      context.handle(
        _stxMeta,
        stx.isAcceptableOrUnknown(data['stx']!, _stxMeta),
      );
    }
    if (data.containsKey('srx_string')) {
      context.handle(
        _srxStringMeta,
        srxString.isAcceptableOrUnknown(data['srx_string']!, _srxStringMeta),
      );
    }
    if (data.containsKey('stx_string')) {
      context.handle(
        _stxStringMeta,
        stxString.isAcceptableOrUnknown(data['stx_string']!, _stxStringMeta),
      );
    }
    if (data.containsKey('check')) {
      context.handle(
        _checkMeta,
        check.isAcceptableOrUnknown(data['check']!, _checkMeta),
      );
    }
    if (data.containsKey('class')) {
      context.handle(
        _qsoClassMeta,
        qsoClass.isAcceptableOrUnknown(data['class']!, _qsoClassMeta),
      );
    }
    if (data.containsKey('precedence')) {
      context.handle(
        _precedenceMeta,
        precedence.isAcceptableOrUnknown(data['precedence']!, _precedenceMeta),
      );
    }
    if (data.containsKey('arrl_sect')) {
      context.handle(
        _arrlSectMeta,
        arrlSect.isAcceptableOrUnknown(data['arrl_sect']!, _arrlSectMeta),
      );
    }
    if (data.containsKey('prop_mode')) {
      context.handle(
        _propModeMeta,
        propMode.isAcceptableOrUnknown(data['prop_mode']!, _propModeMeta),
      );
    }
    if (data.containsKey('sat_name')) {
      context.handle(
        _satNameMeta,
        satName.isAcceptableOrUnknown(data['sat_name']!, _satNameMeta),
      );
    }
    if (data.containsKey('sat_mode')) {
      context.handle(
        _satModeMeta,
        satMode.isAcceptableOrUnknown(data['sat_mode']!, _satModeMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('qsl_via')) {
      context.handle(
        _qslViaMeta,
        qslVia.isAcceptableOrUnknown(data['qsl_via']!, _qslViaMeta),
      );
    }
    if (data.containsKey('adif_extra')) {
      context.handle(
        _adifExtraMeta,
        adifExtra.isAcceptableOrUnknown(data['adif_extra']!, _adifExtraMeta),
      );
    }
    if (data.containsKey('contest_session_id')) {
      context.handle(
        _contestSessionIdMeta,
        contestSessionId.isAcceptableOrUnknown(
          data['contest_session_id']!,
          _contestSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('activation_id')) {
      context.handle(
        _activationIdMeta,
        activationId.isAcceptableOrUnknown(
          data['activation_id']!,
          _activationIdMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QsoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QsoRow(
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      hlcCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_created'],
      )!,
      hlcModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_modified'],
      )!,
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      stationProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_profile_id'],
      ),
      call: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call'],
      )!,
      timeOn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_on'],
      )!,
      timeOff: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_off'],
      ),
      band: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}band'],
      )!,
      bandRx: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}band_rx'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      submode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submode'],
      ),
      freqHz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freq_hz'],
      ),
      freqRxHz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freq_rx_hz'],
      ),
      rstSent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rst_sent'],
      ),
      rstRcvd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rst_rcvd'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      qth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qth'],
      ),
      gridsquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gridsquare'],
      ),
      dxcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dxcc'],
      ),
      cqz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cqz'],
      ),
      ituz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ituz'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      cnty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnty'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      cont: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cont'],
      ),
      darcDok: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}darc_dok'],
      ),
      iota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iota'],
      ),
      sotaRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sota_ref'],
      ),
      potaRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pota_ref'],
      ),
      wwffRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wwff_ref'],
      ),
      sig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sig'],
      ),
      sigInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sig_info'],
      ),
      mySotaRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_sota_ref'],
      ),
      myPotaRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_pota_ref'],
      ),
      myWwffRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_wwff_ref'],
      ),
      mySig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_sig'],
      ),
      mySigInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_sig_info'],
      ),
      stationCallsign: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_callsign'],
      ),
      operator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator'],
      ),
      myGridsquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_gridsquare'],
      ),
      txPwr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tx_pwr'],
      ),
      contestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contest_id'],
      ),
      srx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}srx'],
      ),
      stx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stx'],
      ),
      srxString: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}srx_string'],
      ),
      stxString: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stx_string'],
      ),
      check: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check'],
      ),
      qsoClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class'],
      ),
      precedence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}precedence'],
      ),
      arrlSect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arrl_sect'],
      ),
      propMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prop_mode'],
      ),
      satName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sat_name'],
      ),
      satMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sat_mode'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      qslVia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qsl_via'],
      ),
      adifExtra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adif_extra'],
      )!,
      contestSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contest_session_id'],
      ),
      activationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activation_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $QsosTable createAlias(String alias) {
    return $QsosTable(attachedDatabase, alias);
  }
}

class QsoRow extends DataClass implements Insertable<QsoRow> {
  /// Device that created the row.
  final String originDeviceId;

  /// Hybrid logical clock timestamp of creation.
  final String hlcCreated;

  /// Hybrid logical clock timestamp of the last change.
  final String hlcModified;

  /// Local revision counter, incremented on every change.
  final int rev;

  /// Tombstone: UTC millis of deletion, or null while the row is alive.
  final int? deletedAt;
  final String id;
  final String accountId;

  /// Null while the QSO is a draft without a station location.
  final String? stationProfileId;
  final String call;

  /// ADIF QSO_DATE + TIME_ON as UTC epoch milliseconds.
  final int timeOn;

  /// ADIF QSO_DATE_OFF + TIME_OFF as UTC epoch milliseconds.
  final int? timeOff;
  final String band;
  final String? bandRx;
  final String mode;
  final String? submode;

  /// ADIF FREQ in integer hertz (ADIF itself uses MHz).
  final int? freqHz;

  /// ADIF FREQ_RX in integer hertz.
  final int? freqRxHz;
  final String? rstSent;
  final String? rstRcvd;
  final String? name;
  final String? qth;
  final String? gridsquare;
  final int? dxcc;
  final int? cqz;
  final int? ituz;
  final String? state;
  final String? cnty;
  final String? country;
  final String? cont;
  final String? darcDok;
  final String? iota;
  final String? sotaRef;
  final String? potaRef;
  final String? wwffRef;
  final String? sig;
  final String? sigInfo;
  final String? mySotaRef;
  final String? myPotaRef;
  final String? myWwffRef;
  final String? mySig;
  final String? mySigInfo;
  final String? stationCallsign;
  final String? operator;
  final String? myGridsquare;

  /// ADIF TX_PWR in watts.
  final double? txPwr;
  final String? contestId;
  final int? srx;
  final int? stx;
  final String? srxString;
  final String? stxString;
  final String? check;
  final String? qsoClass;
  final String? precedence;
  final String? arrlSect;
  final String? propMode;
  final String? satName;
  final String? satMode;
  final String? comment;
  final String? notes;
  final String? qslVia;

  /// JSON object of every other ADIF field (`FIELD_NAME` → value), so that
  /// import and export are lossless.
  final String adifExtra;
  final String? contestSessionId;
  final String? activationId;

  /// `manual`, `fle`, `import`, `peer` or `wsjtx`.
  final String source;
  const QsoRow({
    required this.originDeviceId,
    required this.hlcCreated,
    required this.hlcModified,
    required this.rev,
    this.deletedAt,
    required this.id,
    required this.accountId,
    this.stationProfileId,
    required this.call,
    required this.timeOn,
    this.timeOff,
    required this.band,
    this.bandRx,
    required this.mode,
    this.submode,
    this.freqHz,
    this.freqRxHz,
    this.rstSent,
    this.rstRcvd,
    this.name,
    this.qth,
    this.gridsquare,
    this.dxcc,
    this.cqz,
    this.ituz,
    this.state,
    this.cnty,
    this.country,
    this.cont,
    this.darcDok,
    this.iota,
    this.sotaRef,
    this.potaRef,
    this.wwffRef,
    this.sig,
    this.sigInfo,
    this.mySotaRef,
    this.myPotaRef,
    this.myWwffRef,
    this.mySig,
    this.mySigInfo,
    this.stationCallsign,
    this.operator,
    this.myGridsquare,
    this.txPwr,
    this.contestId,
    this.srx,
    this.stx,
    this.srxString,
    this.stxString,
    this.check,
    this.qsoClass,
    this.precedence,
    this.arrlSect,
    this.propMode,
    this.satName,
    this.satMode,
    this.comment,
    this.notes,
    this.qslVia,
    required this.adifExtra,
    this.contestSessionId,
    this.activationId,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['hlc_created'] = Variable<String>(hlcCreated);
    map['hlc_modified'] = Variable<String>(hlcModified);
    map['rev'] = Variable<int>(rev);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || stationProfileId != null) {
      map['station_profile_id'] = Variable<String>(stationProfileId);
    }
    map['call'] = Variable<String>(call);
    map['time_on'] = Variable<int>(timeOn);
    if (!nullToAbsent || timeOff != null) {
      map['time_off'] = Variable<int>(timeOff);
    }
    map['band'] = Variable<String>(band);
    if (!nullToAbsent || bandRx != null) {
      map['band_rx'] = Variable<String>(bandRx);
    }
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || submode != null) {
      map['submode'] = Variable<String>(submode);
    }
    if (!nullToAbsent || freqHz != null) {
      map['freq_hz'] = Variable<int>(freqHz);
    }
    if (!nullToAbsent || freqRxHz != null) {
      map['freq_rx_hz'] = Variable<int>(freqRxHz);
    }
    if (!nullToAbsent || rstSent != null) {
      map['rst_sent'] = Variable<String>(rstSent);
    }
    if (!nullToAbsent || rstRcvd != null) {
      map['rst_rcvd'] = Variable<String>(rstRcvd);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || qth != null) {
      map['qth'] = Variable<String>(qth);
    }
    if (!nullToAbsent || gridsquare != null) {
      map['gridsquare'] = Variable<String>(gridsquare);
    }
    if (!nullToAbsent || dxcc != null) {
      map['dxcc'] = Variable<int>(dxcc);
    }
    if (!nullToAbsent || cqz != null) {
      map['cqz'] = Variable<int>(cqz);
    }
    if (!nullToAbsent || ituz != null) {
      map['ituz'] = Variable<int>(ituz);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || cnty != null) {
      map['cnty'] = Variable<String>(cnty);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || cont != null) {
      map['cont'] = Variable<String>(cont);
    }
    if (!nullToAbsent || darcDok != null) {
      map['darc_dok'] = Variable<String>(darcDok);
    }
    if (!nullToAbsent || iota != null) {
      map['iota'] = Variable<String>(iota);
    }
    if (!nullToAbsent || sotaRef != null) {
      map['sota_ref'] = Variable<String>(sotaRef);
    }
    if (!nullToAbsent || potaRef != null) {
      map['pota_ref'] = Variable<String>(potaRef);
    }
    if (!nullToAbsent || wwffRef != null) {
      map['wwff_ref'] = Variable<String>(wwffRef);
    }
    if (!nullToAbsent || sig != null) {
      map['sig'] = Variable<String>(sig);
    }
    if (!nullToAbsent || sigInfo != null) {
      map['sig_info'] = Variable<String>(sigInfo);
    }
    if (!nullToAbsent || mySotaRef != null) {
      map['my_sota_ref'] = Variable<String>(mySotaRef);
    }
    if (!nullToAbsent || myPotaRef != null) {
      map['my_pota_ref'] = Variable<String>(myPotaRef);
    }
    if (!nullToAbsent || myWwffRef != null) {
      map['my_wwff_ref'] = Variable<String>(myWwffRef);
    }
    if (!nullToAbsent || mySig != null) {
      map['my_sig'] = Variable<String>(mySig);
    }
    if (!nullToAbsent || mySigInfo != null) {
      map['my_sig_info'] = Variable<String>(mySigInfo);
    }
    if (!nullToAbsent || stationCallsign != null) {
      map['station_callsign'] = Variable<String>(stationCallsign);
    }
    if (!nullToAbsent || operator != null) {
      map['operator'] = Variable<String>(operator);
    }
    if (!nullToAbsent || myGridsquare != null) {
      map['my_gridsquare'] = Variable<String>(myGridsquare);
    }
    if (!nullToAbsent || txPwr != null) {
      map['tx_pwr'] = Variable<double>(txPwr);
    }
    if (!nullToAbsent || contestId != null) {
      map['contest_id'] = Variable<String>(contestId);
    }
    if (!nullToAbsent || srx != null) {
      map['srx'] = Variable<int>(srx);
    }
    if (!nullToAbsent || stx != null) {
      map['stx'] = Variable<int>(stx);
    }
    if (!nullToAbsent || srxString != null) {
      map['srx_string'] = Variable<String>(srxString);
    }
    if (!nullToAbsent || stxString != null) {
      map['stx_string'] = Variable<String>(stxString);
    }
    if (!nullToAbsent || check != null) {
      map['check'] = Variable<String>(check);
    }
    if (!nullToAbsent || qsoClass != null) {
      map['class'] = Variable<String>(qsoClass);
    }
    if (!nullToAbsent || precedence != null) {
      map['precedence'] = Variable<String>(precedence);
    }
    if (!nullToAbsent || arrlSect != null) {
      map['arrl_sect'] = Variable<String>(arrlSect);
    }
    if (!nullToAbsent || propMode != null) {
      map['prop_mode'] = Variable<String>(propMode);
    }
    if (!nullToAbsent || satName != null) {
      map['sat_name'] = Variable<String>(satName);
    }
    if (!nullToAbsent || satMode != null) {
      map['sat_mode'] = Variable<String>(satMode);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || qslVia != null) {
      map['qsl_via'] = Variable<String>(qslVia);
    }
    map['adif_extra'] = Variable<String>(adifExtra);
    if (!nullToAbsent || contestSessionId != null) {
      map['contest_session_id'] = Variable<String>(contestSessionId);
    }
    if (!nullToAbsent || activationId != null) {
      map['activation_id'] = Variable<String>(activationId);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  QsosCompanion toCompanion(bool nullToAbsent) {
    return QsosCompanion(
      originDeviceId: Value(originDeviceId),
      hlcCreated: Value(hlcCreated),
      hlcModified: Value(hlcModified),
      rev: Value(rev),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      accountId: Value(accountId),
      stationProfileId: stationProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(stationProfileId),
      call: Value(call),
      timeOn: Value(timeOn),
      timeOff: timeOff == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOff),
      band: Value(band),
      bandRx: bandRx == null && nullToAbsent
          ? const Value.absent()
          : Value(bandRx),
      mode: Value(mode),
      submode: submode == null && nullToAbsent
          ? const Value.absent()
          : Value(submode),
      freqHz: freqHz == null && nullToAbsent
          ? const Value.absent()
          : Value(freqHz),
      freqRxHz: freqRxHz == null && nullToAbsent
          ? const Value.absent()
          : Value(freqRxHz),
      rstSent: rstSent == null && nullToAbsent
          ? const Value.absent()
          : Value(rstSent),
      rstRcvd: rstRcvd == null && nullToAbsent
          ? const Value.absent()
          : Value(rstRcvd),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      qth: qth == null && nullToAbsent ? const Value.absent() : Value(qth),
      gridsquare: gridsquare == null && nullToAbsent
          ? const Value.absent()
          : Value(gridsquare),
      dxcc: dxcc == null && nullToAbsent ? const Value.absent() : Value(dxcc),
      cqz: cqz == null && nullToAbsent ? const Value.absent() : Value(cqz),
      ituz: ituz == null && nullToAbsent ? const Value.absent() : Value(ituz),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      cnty: cnty == null && nullToAbsent ? const Value.absent() : Value(cnty),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      cont: cont == null && nullToAbsent ? const Value.absent() : Value(cont),
      darcDok: darcDok == null && nullToAbsent
          ? const Value.absent()
          : Value(darcDok),
      iota: iota == null && nullToAbsent ? const Value.absent() : Value(iota),
      sotaRef: sotaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sotaRef),
      potaRef: potaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(potaRef),
      wwffRef: wwffRef == null && nullToAbsent
          ? const Value.absent()
          : Value(wwffRef),
      sig: sig == null && nullToAbsent ? const Value.absent() : Value(sig),
      sigInfo: sigInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(sigInfo),
      mySotaRef: mySotaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(mySotaRef),
      myPotaRef: myPotaRef == null && nullToAbsent
          ? const Value.absent()
          : Value(myPotaRef),
      myWwffRef: myWwffRef == null && nullToAbsent
          ? const Value.absent()
          : Value(myWwffRef),
      mySig: mySig == null && nullToAbsent
          ? const Value.absent()
          : Value(mySig),
      mySigInfo: mySigInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(mySigInfo),
      stationCallsign: stationCallsign == null && nullToAbsent
          ? const Value.absent()
          : Value(stationCallsign),
      operator: operator == null && nullToAbsent
          ? const Value.absent()
          : Value(operator),
      myGridsquare: myGridsquare == null && nullToAbsent
          ? const Value.absent()
          : Value(myGridsquare),
      txPwr: txPwr == null && nullToAbsent
          ? const Value.absent()
          : Value(txPwr),
      contestId: contestId == null && nullToAbsent
          ? const Value.absent()
          : Value(contestId),
      srx: srx == null && nullToAbsent ? const Value.absent() : Value(srx),
      stx: stx == null && nullToAbsent ? const Value.absent() : Value(stx),
      srxString: srxString == null && nullToAbsent
          ? const Value.absent()
          : Value(srxString),
      stxString: stxString == null && nullToAbsent
          ? const Value.absent()
          : Value(stxString),
      check: check == null && nullToAbsent
          ? const Value.absent()
          : Value(check),
      qsoClass: qsoClass == null && nullToAbsent
          ? const Value.absent()
          : Value(qsoClass),
      precedence: precedence == null && nullToAbsent
          ? const Value.absent()
          : Value(precedence),
      arrlSect: arrlSect == null && nullToAbsent
          ? const Value.absent()
          : Value(arrlSect),
      propMode: propMode == null && nullToAbsent
          ? const Value.absent()
          : Value(propMode),
      satName: satName == null && nullToAbsent
          ? const Value.absent()
          : Value(satName),
      satMode: satMode == null && nullToAbsent
          ? const Value.absent()
          : Value(satMode),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      qslVia: qslVia == null && nullToAbsent
          ? const Value.absent()
          : Value(qslVia),
      adifExtra: Value(adifExtra),
      contestSessionId: contestSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(contestSessionId),
      activationId: activationId == null && nullToAbsent
          ? const Value.absent()
          : Value(activationId),
      source: Value(source),
    );
  }

  factory QsoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QsoRow(
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      hlcCreated: serializer.fromJson<String>(json['hlcCreated']),
      hlcModified: serializer.fromJson<String>(json['hlcModified']),
      rev: serializer.fromJson<int>(json['rev']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      stationProfileId: serializer.fromJson<String?>(json['stationProfileId']),
      call: serializer.fromJson<String>(json['call']),
      timeOn: serializer.fromJson<int>(json['timeOn']),
      timeOff: serializer.fromJson<int?>(json['timeOff']),
      band: serializer.fromJson<String>(json['band']),
      bandRx: serializer.fromJson<String?>(json['bandRx']),
      mode: serializer.fromJson<String>(json['mode']),
      submode: serializer.fromJson<String?>(json['submode']),
      freqHz: serializer.fromJson<int?>(json['freqHz']),
      freqRxHz: serializer.fromJson<int?>(json['freqRxHz']),
      rstSent: serializer.fromJson<String?>(json['rstSent']),
      rstRcvd: serializer.fromJson<String?>(json['rstRcvd']),
      name: serializer.fromJson<String?>(json['name']),
      qth: serializer.fromJson<String?>(json['qth']),
      gridsquare: serializer.fromJson<String?>(json['gridsquare']),
      dxcc: serializer.fromJson<int?>(json['dxcc']),
      cqz: serializer.fromJson<int?>(json['cqz']),
      ituz: serializer.fromJson<int?>(json['ituz']),
      state: serializer.fromJson<String?>(json['state']),
      cnty: serializer.fromJson<String?>(json['cnty']),
      country: serializer.fromJson<String?>(json['country']),
      cont: serializer.fromJson<String?>(json['cont']),
      darcDok: serializer.fromJson<String?>(json['darcDok']),
      iota: serializer.fromJson<String?>(json['iota']),
      sotaRef: serializer.fromJson<String?>(json['sotaRef']),
      potaRef: serializer.fromJson<String?>(json['potaRef']),
      wwffRef: serializer.fromJson<String?>(json['wwffRef']),
      sig: serializer.fromJson<String?>(json['sig']),
      sigInfo: serializer.fromJson<String?>(json['sigInfo']),
      mySotaRef: serializer.fromJson<String?>(json['mySotaRef']),
      myPotaRef: serializer.fromJson<String?>(json['myPotaRef']),
      myWwffRef: serializer.fromJson<String?>(json['myWwffRef']),
      mySig: serializer.fromJson<String?>(json['mySig']),
      mySigInfo: serializer.fromJson<String?>(json['mySigInfo']),
      stationCallsign: serializer.fromJson<String?>(json['stationCallsign']),
      operator: serializer.fromJson<String?>(json['operator']),
      myGridsquare: serializer.fromJson<String?>(json['myGridsquare']),
      txPwr: serializer.fromJson<double?>(json['txPwr']),
      contestId: serializer.fromJson<String?>(json['contestId']),
      srx: serializer.fromJson<int?>(json['srx']),
      stx: serializer.fromJson<int?>(json['stx']),
      srxString: serializer.fromJson<String?>(json['srxString']),
      stxString: serializer.fromJson<String?>(json['stxString']),
      check: serializer.fromJson<String?>(json['check']),
      qsoClass: serializer.fromJson<String?>(json['qsoClass']),
      precedence: serializer.fromJson<String?>(json['precedence']),
      arrlSect: serializer.fromJson<String?>(json['arrlSect']),
      propMode: serializer.fromJson<String?>(json['propMode']),
      satName: serializer.fromJson<String?>(json['satName']),
      satMode: serializer.fromJson<String?>(json['satMode']),
      comment: serializer.fromJson<String?>(json['comment']),
      notes: serializer.fromJson<String?>(json['notes']),
      qslVia: serializer.fromJson<String?>(json['qslVia']),
      adifExtra: serializer.fromJson<String>(json['adifExtra']),
      contestSessionId: serializer.fromJson<String?>(json['contestSessionId']),
      activationId: serializer.fromJson<String?>(json['activationId']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'hlcCreated': serializer.toJson<String>(hlcCreated),
      'hlcModified': serializer.toJson<String>(hlcModified),
      'rev': serializer.toJson<int>(rev),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'stationProfileId': serializer.toJson<String?>(stationProfileId),
      'call': serializer.toJson<String>(call),
      'timeOn': serializer.toJson<int>(timeOn),
      'timeOff': serializer.toJson<int?>(timeOff),
      'band': serializer.toJson<String>(band),
      'bandRx': serializer.toJson<String?>(bandRx),
      'mode': serializer.toJson<String>(mode),
      'submode': serializer.toJson<String?>(submode),
      'freqHz': serializer.toJson<int?>(freqHz),
      'freqRxHz': serializer.toJson<int?>(freqRxHz),
      'rstSent': serializer.toJson<String?>(rstSent),
      'rstRcvd': serializer.toJson<String?>(rstRcvd),
      'name': serializer.toJson<String?>(name),
      'qth': serializer.toJson<String?>(qth),
      'gridsquare': serializer.toJson<String?>(gridsquare),
      'dxcc': serializer.toJson<int?>(dxcc),
      'cqz': serializer.toJson<int?>(cqz),
      'ituz': serializer.toJson<int?>(ituz),
      'state': serializer.toJson<String?>(state),
      'cnty': serializer.toJson<String?>(cnty),
      'country': serializer.toJson<String?>(country),
      'cont': serializer.toJson<String?>(cont),
      'darcDok': serializer.toJson<String?>(darcDok),
      'iota': serializer.toJson<String?>(iota),
      'sotaRef': serializer.toJson<String?>(sotaRef),
      'potaRef': serializer.toJson<String?>(potaRef),
      'wwffRef': serializer.toJson<String?>(wwffRef),
      'sig': serializer.toJson<String?>(sig),
      'sigInfo': serializer.toJson<String?>(sigInfo),
      'mySotaRef': serializer.toJson<String?>(mySotaRef),
      'myPotaRef': serializer.toJson<String?>(myPotaRef),
      'myWwffRef': serializer.toJson<String?>(myWwffRef),
      'mySig': serializer.toJson<String?>(mySig),
      'mySigInfo': serializer.toJson<String?>(mySigInfo),
      'stationCallsign': serializer.toJson<String?>(stationCallsign),
      'operator': serializer.toJson<String?>(operator),
      'myGridsquare': serializer.toJson<String?>(myGridsquare),
      'txPwr': serializer.toJson<double?>(txPwr),
      'contestId': serializer.toJson<String?>(contestId),
      'srx': serializer.toJson<int?>(srx),
      'stx': serializer.toJson<int?>(stx),
      'srxString': serializer.toJson<String?>(srxString),
      'stxString': serializer.toJson<String?>(stxString),
      'check': serializer.toJson<String?>(check),
      'qsoClass': serializer.toJson<String?>(qsoClass),
      'precedence': serializer.toJson<String?>(precedence),
      'arrlSect': serializer.toJson<String?>(arrlSect),
      'propMode': serializer.toJson<String?>(propMode),
      'satName': serializer.toJson<String?>(satName),
      'satMode': serializer.toJson<String?>(satMode),
      'comment': serializer.toJson<String?>(comment),
      'notes': serializer.toJson<String?>(notes),
      'qslVia': serializer.toJson<String?>(qslVia),
      'adifExtra': serializer.toJson<String>(adifExtra),
      'contestSessionId': serializer.toJson<String?>(contestSessionId),
      'activationId': serializer.toJson<String?>(activationId),
      'source': serializer.toJson<String>(source),
    };
  }

  QsoRow copyWith({
    String? originDeviceId,
    String? hlcCreated,
    String? hlcModified,
    int? rev,
    Value<int?> deletedAt = const Value.absent(),
    String? id,
    String? accountId,
    Value<String?> stationProfileId = const Value.absent(),
    String? call,
    int? timeOn,
    Value<int?> timeOff = const Value.absent(),
    String? band,
    Value<String?> bandRx = const Value.absent(),
    String? mode,
    Value<String?> submode = const Value.absent(),
    Value<int?> freqHz = const Value.absent(),
    Value<int?> freqRxHz = const Value.absent(),
    Value<String?> rstSent = const Value.absent(),
    Value<String?> rstRcvd = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> qth = const Value.absent(),
    Value<String?> gridsquare = const Value.absent(),
    Value<int?> dxcc = const Value.absent(),
    Value<int?> cqz = const Value.absent(),
    Value<int?> ituz = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> cnty = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> cont = const Value.absent(),
    Value<String?> darcDok = const Value.absent(),
    Value<String?> iota = const Value.absent(),
    Value<String?> sotaRef = const Value.absent(),
    Value<String?> potaRef = const Value.absent(),
    Value<String?> wwffRef = const Value.absent(),
    Value<String?> sig = const Value.absent(),
    Value<String?> sigInfo = const Value.absent(),
    Value<String?> mySotaRef = const Value.absent(),
    Value<String?> myPotaRef = const Value.absent(),
    Value<String?> myWwffRef = const Value.absent(),
    Value<String?> mySig = const Value.absent(),
    Value<String?> mySigInfo = const Value.absent(),
    Value<String?> stationCallsign = const Value.absent(),
    Value<String?> operator = const Value.absent(),
    Value<String?> myGridsquare = const Value.absent(),
    Value<double?> txPwr = const Value.absent(),
    Value<String?> contestId = const Value.absent(),
    Value<int?> srx = const Value.absent(),
    Value<int?> stx = const Value.absent(),
    Value<String?> srxString = const Value.absent(),
    Value<String?> stxString = const Value.absent(),
    Value<String?> check = const Value.absent(),
    Value<String?> qsoClass = const Value.absent(),
    Value<String?> precedence = const Value.absent(),
    Value<String?> arrlSect = const Value.absent(),
    Value<String?> propMode = const Value.absent(),
    Value<String?> satName = const Value.absent(),
    Value<String?> satMode = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> qslVia = const Value.absent(),
    String? adifExtra,
    Value<String?> contestSessionId = const Value.absent(),
    Value<String?> activationId = const Value.absent(),
    String? source,
  }) => QsoRow(
    originDeviceId: originDeviceId ?? this.originDeviceId,
    hlcCreated: hlcCreated ?? this.hlcCreated,
    hlcModified: hlcModified ?? this.hlcModified,
    rev: rev ?? this.rev,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    stationProfileId: stationProfileId.present
        ? stationProfileId.value
        : this.stationProfileId,
    call: call ?? this.call,
    timeOn: timeOn ?? this.timeOn,
    timeOff: timeOff.present ? timeOff.value : this.timeOff,
    band: band ?? this.band,
    bandRx: bandRx.present ? bandRx.value : this.bandRx,
    mode: mode ?? this.mode,
    submode: submode.present ? submode.value : this.submode,
    freqHz: freqHz.present ? freqHz.value : this.freqHz,
    freqRxHz: freqRxHz.present ? freqRxHz.value : this.freqRxHz,
    rstSent: rstSent.present ? rstSent.value : this.rstSent,
    rstRcvd: rstRcvd.present ? rstRcvd.value : this.rstRcvd,
    name: name.present ? name.value : this.name,
    qth: qth.present ? qth.value : this.qth,
    gridsquare: gridsquare.present ? gridsquare.value : this.gridsquare,
    dxcc: dxcc.present ? dxcc.value : this.dxcc,
    cqz: cqz.present ? cqz.value : this.cqz,
    ituz: ituz.present ? ituz.value : this.ituz,
    state: state.present ? state.value : this.state,
    cnty: cnty.present ? cnty.value : this.cnty,
    country: country.present ? country.value : this.country,
    cont: cont.present ? cont.value : this.cont,
    darcDok: darcDok.present ? darcDok.value : this.darcDok,
    iota: iota.present ? iota.value : this.iota,
    sotaRef: sotaRef.present ? sotaRef.value : this.sotaRef,
    potaRef: potaRef.present ? potaRef.value : this.potaRef,
    wwffRef: wwffRef.present ? wwffRef.value : this.wwffRef,
    sig: sig.present ? sig.value : this.sig,
    sigInfo: sigInfo.present ? sigInfo.value : this.sigInfo,
    mySotaRef: mySotaRef.present ? mySotaRef.value : this.mySotaRef,
    myPotaRef: myPotaRef.present ? myPotaRef.value : this.myPotaRef,
    myWwffRef: myWwffRef.present ? myWwffRef.value : this.myWwffRef,
    mySig: mySig.present ? mySig.value : this.mySig,
    mySigInfo: mySigInfo.present ? mySigInfo.value : this.mySigInfo,
    stationCallsign: stationCallsign.present
        ? stationCallsign.value
        : this.stationCallsign,
    operator: operator.present ? operator.value : this.operator,
    myGridsquare: myGridsquare.present ? myGridsquare.value : this.myGridsquare,
    txPwr: txPwr.present ? txPwr.value : this.txPwr,
    contestId: contestId.present ? contestId.value : this.contestId,
    srx: srx.present ? srx.value : this.srx,
    stx: stx.present ? stx.value : this.stx,
    srxString: srxString.present ? srxString.value : this.srxString,
    stxString: stxString.present ? stxString.value : this.stxString,
    check: check.present ? check.value : this.check,
    qsoClass: qsoClass.present ? qsoClass.value : this.qsoClass,
    precedence: precedence.present ? precedence.value : this.precedence,
    arrlSect: arrlSect.present ? arrlSect.value : this.arrlSect,
    propMode: propMode.present ? propMode.value : this.propMode,
    satName: satName.present ? satName.value : this.satName,
    satMode: satMode.present ? satMode.value : this.satMode,
    comment: comment.present ? comment.value : this.comment,
    notes: notes.present ? notes.value : this.notes,
    qslVia: qslVia.present ? qslVia.value : this.qslVia,
    adifExtra: adifExtra ?? this.adifExtra,
    contestSessionId: contestSessionId.present
        ? contestSessionId.value
        : this.contestSessionId,
    activationId: activationId.present ? activationId.value : this.activationId,
    source: source ?? this.source,
  );
  QsoRow copyWithCompanion(QsosCompanion data) {
    return QsoRow(
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      hlcCreated: data.hlcCreated.present
          ? data.hlcCreated.value
          : this.hlcCreated,
      hlcModified: data.hlcModified.present
          ? data.hlcModified.value
          : this.hlcModified,
      rev: data.rev.present ? data.rev.value : this.rev,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      stationProfileId: data.stationProfileId.present
          ? data.stationProfileId.value
          : this.stationProfileId,
      call: data.call.present ? data.call.value : this.call,
      timeOn: data.timeOn.present ? data.timeOn.value : this.timeOn,
      timeOff: data.timeOff.present ? data.timeOff.value : this.timeOff,
      band: data.band.present ? data.band.value : this.band,
      bandRx: data.bandRx.present ? data.bandRx.value : this.bandRx,
      mode: data.mode.present ? data.mode.value : this.mode,
      submode: data.submode.present ? data.submode.value : this.submode,
      freqHz: data.freqHz.present ? data.freqHz.value : this.freqHz,
      freqRxHz: data.freqRxHz.present ? data.freqRxHz.value : this.freqRxHz,
      rstSent: data.rstSent.present ? data.rstSent.value : this.rstSent,
      rstRcvd: data.rstRcvd.present ? data.rstRcvd.value : this.rstRcvd,
      name: data.name.present ? data.name.value : this.name,
      qth: data.qth.present ? data.qth.value : this.qth,
      gridsquare: data.gridsquare.present
          ? data.gridsquare.value
          : this.gridsquare,
      dxcc: data.dxcc.present ? data.dxcc.value : this.dxcc,
      cqz: data.cqz.present ? data.cqz.value : this.cqz,
      ituz: data.ituz.present ? data.ituz.value : this.ituz,
      state: data.state.present ? data.state.value : this.state,
      cnty: data.cnty.present ? data.cnty.value : this.cnty,
      country: data.country.present ? data.country.value : this.country,
      cont: data.cont.present ? data.cont.value : this.cont,
      darcDok: data.darcDok.present ? data.darcDok.value : this.darcDok,
      iota: data.iota.present ? data.iota.value : this.iota,
      sotaRef: data.sotaRef.present ? data.sotaRef.value : this.sotaRef,
      potaRef: data.potaRef.present ? data.potaRef.value : this.potaRef,
      wwffRef: data.wwffRef.present ? data.wwffRef.value : this.wwffRef,
      sig: data.sig.present ? data.sig.value : this.sig,
      sigInfo: data.sigInfo.present ? data.sigInfo.value : this.sigInfo,
      mySotaRef: data.mySotaRef.present ? data.mySotaRef.value : this.mySotaRef,
      myPotaRef: data.myPotaRef.present ? data.myPotaRef.value : this.myPotaRef,
      myWwffRef: data.myWwffRef.present ? data.myWwffRef.value : this.myWwffRef,
      mySig: data.mySig.present ? data.mySig.value : this.mySig,
      mySigInfo: data.mySigInfo.present ? data.mySigInfo.value : this.mySigInfo,
      stationCallsign: data.stationCallsign.present
          ? data.stationCallsign.value
          : this.stationCallsign,
      operator: data.operator.present ? data.operator.value : this.operator,
      myGridsquare: data.myGridsquare.present
          ? data.myGridsquare.value
          : this.myGridsquare,
      txPwr: data.txPwr.present ? data.txPwr.value : this.txPwr,
      contestId: data.contestId.present ? data.contestId.value : this.contestId,
      srx: data.srx.present ? data.srx.value : this.srx,
      stx: data.stx.present ? data.stx.value : this.stx,
      srxString: data.srxString.present ? data.srxString.value : this.srxString,
      stxString: data.stxString.present ? data.stxString.value : this.stxString,
      check: data.check.present ? data.check.value : this.check,
      qsoClass: data.qsoClass.present ? data.qsoClass.value : this.qsoClass,
      precedence: data.precedence.present
          ? data.precedence.value
          : this.precedence,
      arrlSect: data.arrlSect.present ? data.arrlSect.value : this.arrlSect,
      propMode: data.propMode.present ? data.propMode.value : this.propMode,
      satName: data.satName.present ? data.satName.value : this.satName,
      satMode: data.satMode.present ? data.satMode.value : this.satMode,
      comment: data.comment.present ? data.comment.value : this.comment,
      notes: data.notes.present ? data.notes.value : this.notes,
      qslVia: data.qslVia.present ? data.qslVia.value : this.qslVia,
      adifExtra: data.adifExtra.present ? data.adifExtra.value : this.adifExtra,
      contestSessionId: data.contestSessionId.present
          ? data.contestSessionId.value
          : this.contestSessionId,
      activationId: data.activationId.present
          ? data.activationId.value
          : this.activationId,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QsoRow(')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('hlcCreated: $hlcCreated, ')
          ..write('hlcModified: $hlcModified, ')
          ..write('rev: $rev, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('stationProfileId: $stationProfileId, ')
          ..write('call: $call, ')
          ..write('timeOn: $timeOn, ')
          ..write('timeOff: $timeOff, ')
          ..write('band: $band, ')
          ..write('bandRx: $bandRx, ')
          ..write('mode: $mode, ')
          ..write('submode: $submode, ')
          ..write('freqHz: $freqHz, ')
          ..write('freqRxHz: $freqRxHz, ')
          ..write('rstSent: $rstSent, ')
          ..write('rstRcvd: $rstRcvd, ')
          ..write('name: $name, ')
          ..write('qth: $qth, ')
          ..write('gridsquare: $gridsquare, ')
          ..write('dxcc: $dxcc, ')
          ..write('cqz: $cqz, ')
          ..write('ituz: $ituz, ')
          ..write('state: $state, ')
          ..write('cnty: $cnty, ')
          ..write('country: $country, ')
          ..write('cont: $cont, ')
          ..write('darcDok: $darcDok, ')
          ..write('iota: $iota, ')
          ..write('sotaRef: $sotaRef, ')
          ..write('potaRef: $potaRef, ')
          ..write('wwffRef: $wwffRef, ')
          ..write('sig: $sig, ')
          ..write('sigInfo: $sigInfo, ')
          ..write('mySotaRef: $mySotaRef, ')
          ..write('myPotaRef: $myPotaRef, ')
          ..write('myWwffRef: $myWwffRef, ')
          ..write('mySig: $mySig, ')
          ..write('mySigInfo: $mySigInfo, ')
          ..write('stationCallsign: $stationCallsign, ')
          ..write('operator: $operator, ')
          ..write('myGridsquare: $myGridsquare, ')
          ..write('txPwr: $txPwr, ')
          ..write('contestId: $contestId, ')
          ..write('srx: $srx, ')
          ..write('stx: $stx, ')
          ..write('srxString: $srxString, ')
          ..write('stxString: $stxString, ')
          ..write('check: $check, ')
          ..write('qsoClass: $qsoClass, ')
          ..write('precedence: $precedence, ')
          ..write('arrlSect: $arrlSect, ')
          ..write('propMode: $propMode, ')
          ..write('satName: $satName, ')
          ..write('satMode: $satMode, ')
          ..write('comment: $comment, ')
          ..write('notes: $notes, ')
          ..write('qslVia: $qslVia, ')
          ..write('adifExtra: $adifExtra, ')
          ..write('contestSessionId: $contestSessionId, ')
          ..write('activationId: $activationId, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    originDeviceId,
    hlcCreated,
    hlcModified,
    rev,
    deletedAt,
    id,
    accountId,
    stationProfileId,
    call,
    timeOn,
    timeOff,
    band,
    bandRx,
    mode,
    submode,
    freqHz,
    freqRxHz,
    rstSent,
    rstRcvd,
    name,
    qth,
    gridsquare,
    dxcc,
    cqz,
    ituz,
    state,
    cnty,
    country,
    cont,
    darcDok,
    iota,
    sotaRef,
    potaRef,
    wwffRef,
    sig,
    sigInfo,
    mySotaRef,
    myPotaRef,
    myWwffRef,
    mySig,
    mySigInfo,
    stationCallsign,
    operator,
    myGridsquare,
    txPwr,
    contestId,
    srx,
    stx,
    srxString,
    stxString,
    check,
    qsoClass,
    precedence,
    arrlSect,
    propMode,
    satName,
    satMode,
    comment,
    notes,
    qslVia,
    adifExtra,
    contestSessionId,
    activationId,
    source,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QsoRow &&
          other.originDeviceId == this.originDeviceId &&
          other.hlcCreated == this.hlcCreated &&
          other.hlcModified == this.hlcModified &&
          other.rev == this.rev &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.stationProfileId == this.stationProfileId &&
          other.call == this.call &&
          other.timeOn == this.timeOn &&
          other.timeOff == this.timeOff &&
          other.band == this.band &&
          other.bandRx == this.bandRx &&
          other.mode == this.mode &&
          other.submode == this.submode &&
          other.freqHz == this.freqHz &&
          other.freqRxHz == this.freqRxHz &&
          other.rstSent == this.rstSent &&
          other.rstRcvd == this.rstRcvd &&
          other.name == this.name &&
          other.qth == this.qth &&
          other.gridsquare == this.gridsquare &&
          other.dxcc == this.dxcc &&
          other.cqz == this.cqz &&
          other.ituz == this.ituz &&
          other.state == this.state &&
          other.cnty == this.cnty &&
          other.country == this.country &&
          other.cont == this.cont &&
          other.darcDok == this.darcDok &&
          other.iota == this.iota &&
          other.sotaRef == this.sotaRef &&
          other.potaRef == this.potaRef &&
          other.wwffRef == this.wwffRef &&
          other.sig == this.sig &&
          other.sigInfo == this.sigInfo &&
          other.mySotaRef == this.mySotaRef &&
          other.myPotaRef == this.myPotaRef &&
          other.myWwffRef == this.myWwffRef &&
          other.mySig == this.mySig &&
          other.mySigInfo == this.mySigInfo &&
          other.stationCallsign == this.stationCallsign &&
          other.operator == this.operator &&
          other.myGridsquare == this.myGridsquare &&
          other.txPwr == this.txPwr &&
          other.contestId == this.contestId &&
          other.srx == this.srx &&
          other.stx == this.stx &&
          other.srxString == this.srxString &&
          other.stxString == this.stxString &&
          other.check == this.check &&
          other.qsoClass == this.qsoClass &&
          other.precedence == this.precedence &&
          other.arrlSect == this.arrlSect &&
          other.propMode == this.propMode &&
          other.satName == this.satName &&
          other.satMode == this.satMode &&
          other.comment == this.comment &&
          other.notes == this.notes &&
          other.qslVia == this.qslVia &&
          other.adifExtra == this.adifExtra &&
          other.contestSessionId == this.contestSessionId &&
          other.activationId == this.activationId &&
          other.source == this.source);
}

class QsosCompanion extends UpdateCompanion<QsoRow> {
  final Value<String> originDeviceId;
  final Value<String> hlcCreated;
  final Value<String> hlcModified;
  final Value<int> rev;
  final Value<int?> deletedAt;
  final Value<String> id;
  final Value<String> accountId;
  final Value<String?> stationProfileId;
  final Value<String> call;
  final Value<int> timeOn;
  final Value<int?> timeOff;
  final Value<String> band;
  final Value<String?> bandRx;
  final Value<String> mode;
  final Value<String?> submode;
  final Value<int?> freqHz;
  final Value<int?> freqRxHz;
  final Value<String?> rstSent;
  final Value<String?> rstRcvd;
  final Value<String?> name;
  final Value<String?> qth;
  final Value<String?> gridsquare;
  final Value<int?> dxcc;
  final Value<int?> cqz;
  final Value<int?> ituz;
  final Value<String?> state;
  final Value<String?> cnty;
  final Value<String?> country;
  final Value<String?> cont;
  final Value<String?> darcDok;
  final Value<String?> iota;
  final Value<String?> sotaRef;
  final Value<String?> potaRef;
  final Value<String?> wwffRef;
  final Value<String?> sig;
  final Value<String?> sigInfo;
  final Value<String?> mySotaRef;
  final Value<String?> myPotaRef;
  final Value<String?> myWwffRef;
  final Value<String?> mySig;
  final Value<String?> mySigInfo;
  final Value<String?> stationCallsign;
  final Value<String?> operator;
  final Value<String?> myGridsquare;
  final Value<double?> txPwr;
  final Value<String?> contestId;
  final Value<int?> srx;
  final Value<int?> stx;
  final Value<String?> srxString;
  final Value<String?> stxString;
  final Value<String?> check;
  final Value<String?> qsoClass;
  final Value<String?> precedence;
  final Value<String?> arrlSect;
  final Value<String?> propMode;
  final Value<String?> satName;
  final Value<String?> satMode;
  final Value<String?> comment;
  final Value<String?> notes;
  final Value<String?> qslVia;
  final Value<String> adifExtra;
  final Value<String?> contestSessionId;
  final Value<String?> activationId;
  final Value<String> source;
  final Value<int> rowid;
  const QsosCompanion({
    this.originDeviceId = const Value.absent(),
    this.hlcCreated = const Value.absent(),
    this.hlcModified = const Value.absent(),
    this.rev = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.stationProfileId = const Value.absent(),
    this.call = const Value.absent(),
    this.timeOn = const Value.absent(),
    this.timeOff = const Value.absent(),
    this.band = const Value.absent(),
    this.bandRx = const Value.absent(),
    this.mode = const Value.absent(),
    this.submode = const Value.absent(),
    this.freqHz = const Value.absent(),
    this.freqRxHz = const Value.absent(),
    this.rstSent = const Value.absent(),
    this.rstRcvd = const Value.absent(),
    this.name = const Value.absent(),
    this.qth = const Value.absent(),
    this.gridsquare = const Value.absent(),
    this.dxcc = const Value.absent(),
    this.cqz = const Value.absent(),
    this.ituz = const Value.absent(),
    this.state = const Value.absent(),
    this.cnty = const Value.absent(),
    this.country = const Value.absent(),
    this.cont = const Value.absent(),
    this.darcDok = const Value.absent(),
    this.iota = const Value.absent(),
    this.sotaRef = const Value.absent(),
    this.potaRef = const Value.absent(),
    this.wwffRef = const Value.absent(),
    this.sig = const Value.absent(),
    this.sigInfo = const Value.absent(),
    this.mySotaRef = const Value.absent(),
    this.myPotaRef = const Value.absent(),
    this.myWwffRef = const Value.absent(),
    this.mySig = const Value.absent(),
    this.mySigInfo = const Value.absent(),
    this.stationCallsign = const Value.absent(),
    this.operator = const Value.absent(),
    this.myGridsquare = const Value.absent(),
    this.txPwr = const Value.absent(),
    this.contestId = const Value.absent(),
    this.srx = const Value.absent(),
    this.stx = const Value.absent(),
    this.srxString = const Value.absent(),
    this.stxString = const Value.absent(),
    this.check = const Value.absent(),
    this.qsoClass = const Value.absent(),
    this.precedence = const Value.absent(),
    this.arrlSect = const Value.absent(),
    this.propMode = const Value.absent(),
    this.satName = const Value.absent(),
    this.satMode = const Value.absent(),
    this.comment = const Value.absent(),
    this.notes = const Value.absent(),
    this.qslVia = const Value.absent(),
    this.adifExtra = const Value.absent(),
    this.contestSessionId = const Value.absent(),
    this.activationId = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QsosCompanion.insert({
    required String originDeviceId,
    required String hlcCreated,
    required String hlcModified,
    this.rev = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String accountId,
    this.stationProfileId = const Value.absent(),
    required String call,
    required int timeOn,
    this.timeOff = const Value.absent(),
    required String band,
    this.bandRx = const Value.absent(),
    required String mode,
    this.submode = const Value.absent(),
    this.freqHz = const Value.absent(),
    this.freqRxHz = const Value.absent(),
    this.rstSent = const Value.absent(),
    this.rstRcvd = const Value.absent(),
    this.name = const Value.absent(),
    this.qth = const Value.absent(),
    this.gridsquare = const Value.absent(),
    this.dxcc = const Value.absent(),
    this.cqz = const Value.absent(),
    this.ituz = const Value.absent(),
    this.state = const Value.absent(),
    this.cnty = const Value.absent(),
    this.country = const Value.absent(),
    this.cont = const Value.absent(),
    this.darcDok = const Value.absent(),
    this.iota = const Value.absent(),
    this.sotaRef = const Value.absent(),
    this.potaRef = const Value.absent(),
    this.wwffRef = const Value.absent(),
    this.sig = const Value.absent(),
    this.sigInfo = const Value.absent(),
    this.mySotaRef = const Value.absent(),
    this.myPotaRef = const Value.absent(),
    this.myWwffRef = const Value.absent(),
    this.mySig = const Value.absent(),
    this.mySigInfo = const Value.absent(),
    this.stationCallsign = const Value.absent(),
    this.operator = const Value.absent(),
    this.myGridsquare = const Value.absent(),
    this.txPwr = const Value.absent(),
    this.contestId = const Value.absent(),
    this.srx = const Value.absent(),
    this.stx = const Value.absent(),
    this.srxString = const Value.absent(),
    this.stxString = const Value.absent(),
    this.check = const Value.absent(),
    this.qsoClass = const Value.absent(),
    this.precedence = const Value.absent(),
    this.arrlSect = const Value.absent(),
    this.propMode = const Value.absent(),
    this.satName = const Value.absent(),
    this.satMode = const Value.absent(),
    this.comment = const Value.absent(),
    this.notes = const Value.absent(),
    this.qslVia = const Value.absent(),
    this.adifExtra = const Value.absent(),
    this.contestSessionId = const Value.absent(),
    this.activationId = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : originDeviceId = Value(originDeviceId),
       hlcCreated = Value(hlcCreated),
       hlcModified = Value(hlcModified),
       id = Value(id),
       accountId = Value(accountId),
       call = Value(call),
       timeOn = Value(timeOn),
       band = Value(band),
       mode = Value(mode);
  static Insertable<QsoRow> custom({
    Expression<String>? originDeviceId,
    Expression<String>? hlcCreated,
    Expression<String>? hlcModified,
    Expression<int>? rev,
    Expression<int>? deletedAt,
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? stationProfileId,
    Expression<String>? call,
    Expression<int>? timeOn,
    Expression<int>? timeOff,
    Expression<String>? band,
    Expression<String>? bandRx,
    Expression<String>? mode,
    Expression<String>? submode,
    Expression<int>? freqHz,
    Expression<int>? freqRxHz,
    Expression<String>? rstSent,
    Expression<String>? rstRcvd,
    Expression<String>? name,
    Expression<String>? qth,
    Expression<String>? gridsquare,
    Expression<int>? dxcc,
    Expression<int>? cqz,
    Expression<int>? ituz,
    Expression<String>? state,
    Expression<String>? cnty,
    Expression<String>? country,
    Expression<String>? cont,
    Expression<String>? darcDok,
    Expression<String>? iota,
    Expression<String>? sotaRef,
    Expression<String>? potaRef,
    Expression<String>? wwffRef,
    Expression<String>? sig,
    Expression<String>? sigInfo,
    Expression<String>? mySotaRef,
    Expression<String>? myPotaRef,
    Expression<String>? myWwffRef,
    Expression<String>? mySig,
    Expression<String>? mySigInfo,
    Expression<String>? stationCallsign,
    Expression<String>? operator,
    Expression<String>? myGridsquare,
    Expression<double>? txPwr,
    Expression<String>? contestId,
    Expression<int>? srx,
    Expression<int>? stx,
    Expression<String>? srxString,
    Expression<String>? stxString,
    Expression<String>? check,
    Expression<String>? qsoClass,
    Expression<String>? precedence,
    Expression<String>? arrlSect,
    Expression<String>? propMode,
    Expression<String>? satName,
    Expression<String>? satMode,
    Expression<String>? comment,
    Expression<String>? notes,
    Expression<String>? qslVia,
    Expression<String>? adifExtra,
    Expression<String>? contestSessionId,
    Expression<String>? activationId,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (hlcCreated != null) 'hlc_created': hlcCreated,
      if (hlcModified != null) 'hlc_modified': hlcModified,
      if (rev != null) 'rev': rev,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (stationProfileId != null) 'station_profile_id': stationProfileId,
      if (call != null) 'call': call,
      if (timeOn != null) 'time_on': timeOn,
      if (timeOff != null) 'time_off': timeOff,
      if (band != null) 'band': band,
      if (bandRx != null) 'band_rx': bandRx,
      if (mode != null) 'mode': mode,
      if (submode != null) 'submode': submode,
      if (freqHz != null) 'freq_hz': freqHz,
      if (freqRxHz != null) 'freq_rx_hz': freqRxHz,
      if (rstSent != null) 'rst_sent': rstSent,
      if (rstRcvd != null) 'rst_rcvd': rstRcvd,
      if (name != null) 'name': name,
      if (qth != null) 'qth': qth,
      if (gridsquare != null) 'gridsquare': gridsquare,
      if (dxcc != null) 'dxcc': dxcc,
      if (cqz != null) 'cqz': cqz,
      if (ituz != null) 'ituz': ituz,
      if (state != null) 'state': state,
      if (cnty != null) 'cnty': cnty,
      if (country != null) 'country': country,
      if (cont != null) 'cont': cont,
      if (darcDok != null) 'darc_dok': darcDok,
      if (iota != null) 'iota': iota,
      if (sotaRef != null) 'sota_ref': sotaRef,
      if (potaRef != null) 'pota_ref': potaRef,
      if (wwffRef != null) 'wwff_ref': wwffRef,
      if (sig != null) 'sig': sig,
      if (sigInfo != null) 'sig_info': sigInfo,
      if (mySotaRef != null) 'my_sota_ref': mySotaRef,
      if (myPotaRef != null) 'my_pota_ref': myPotaRef,
      if (myWwffRef != null) 'my_wwff_ref': myWwffRef,
      if (mySig != null) 'my_sig': mySig,
      if (mySigInfo != null) 'my_sig_info': mySigInfo,
      if (stationCallsign != null) 'station_callsign': stationCallsign,
      if (operator != null) 'operator': operator,
      if (myGridsquare != null) 'my_gridsquare': myGridsquare,
      if (txPwr != null) 'tx_pwr': txPwr,
      if (contestId != null) 'contest_id': contestId,
      if (srx != null) 'srx': srx,
      if (stx != null) 'stx': stx,
      if (srxString != null) 'srx_string': srxString,
      if (stxString != null) 'stx_string': stxString,
      if (check != null) 'check': check,
      if (qsoClass != null) 'class': qsoClass,
      if (precedence != null) 'precedence': precedence,
      if (arrlSect != null) 'arrl_sect': arrlSect,
      if (propMode != null) 'prop_mode': propMode,
      if (satName != null) 'sat_name': satName,
      if (satMode != null) 'sat_mode': satMode,
      if (comment != null) 'comment': comment,
      if (notes != null) 'notes': notes,
      if (qslVia != null) 'qsl_via': qslVia,
      if (adifExtra != null) 'adif_extra': adifExtra,
      if (contestSessionId != null) 'contest_session_id': contestSessionId,
      if (activationId != null) 'activation_id': activationId,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QsosCompanion copyWith({
    Value<String>? originDeviceId,
    Value<String>? hlcCreated,
    Value<String>? hlcModified,
    Value<int>? rev,
    Value<int?>? deletedAt,
    Value<String>? id,
    Value<String>? accountId,
    Value<String?>? stationProfileId,
    Value<String>? call,
    Value<int>? timeOn,
    Value<int?>? timeOff,
    Value<String>? band,
    Value<String?>? bandRx,
    Value<String>? mode,
    Value<String?>? submode,
    Value<int?>? freqHz,
    Value<int?>? freqRxHz,
    Value<String?>? rstSent,
    Value<String?>? rstRcvd,
    Value<String?>? name,
    Value<String?>? qth,
    Value<String?>? gridsquare,
    Value<int?>? dxcc,
    Value<int?>? cqz,
    Value<int?>? ituz,
    Value<String?>? state,
    Value<String?>? cnty,
    Value<String?>? country,
    Value<String?>? cont,
    Value<String?>? darcDok,
    Value<String?>? iota,
    Value<String?>? sotaRef,
    Value<String?>? potaRef,
    Value<String?>? wwffRef,
    Value<String?>? sig,
    Value<String?>? sigInfo,
    Value<String?>? mySotaRef,
    Value<String?>? myPotaRef,
    Value<String?>? myWwffRef,
    Value<String?>? mySig,
    Value<String?>? mySigInfo,
    Value<String?>? stationCallsign,
    Value<String?>? operator,
    Value<String?>? myGridsquare,
    Value<double?>? txPwr,
    Value<String?>? contestId,
    Value<int?>? srx,
    Value<int?>? stx,
    Value<String?>? srxString,
    Value<String?>? stxString,
    Value<String?>? check,
    Value<String?>? qsoClass,
    Value<String?>? precedence,
    Value<String?>? arrlSect,
    Value<String?>? propMode,
    Value<String?>? satName,
    Value<String?>? satMode,
    Value<String?>? comment,
    Value<String?>? notes,
    Value<String?>? qslVia,
    Value<String>? adifExtra,
    Value<String?>? contestSessionId,
    Value<String?>? activationId,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return QsosCompanion(
      originDeviceId: originDeviceId ?? this.originDeviceId,
      hlcCreated: hlcCreated ?? this.hlcCreated,
      hlcModified: hlcModified ?? this.hlcModified,
      rev: rev ?? this.rev,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      stationProfileId: stationProfileId ?? this.stationProfileId,
      call: call ?? this.call,
      timeOn: timeOn ?? this.timeOn,
      timeOff: timeOff ?? this.timeOff,
      band: band ?? this.band,
      bandRx: bandRx ?? this.bandRx,
      mode: mode ?? this.mode,
      submode: submode ?? this.submode,
      freqHz: freqHz ?? this.freqHz,
      freqRxHz: freqRxHz ?? this.freqRxHz,
      rstSent: rstSent ?? this.rstSent,
      rstRcvd: rstRcvd ?? this.rstRcvd,
      name: name ?? this.name,
      qth: qth ?? this.qth,
      gridsquare: gridsquare ?? this.gridsquare,
      dxcc: dxcc ?? this.dxcc,
      cqz: cqz ?? this.cqz,
      ituz: ituz ?? this.ituz,
      state: state ?? this.state,
      cnty: cnty ?? this.cnty,
      country: country ?? this.country,
      cont: cont ?? this.cont,
      darcDok: darcDok ?? this.darcDok,
      iota: iota ?? this.iota,
      sotaRef: sotaRef ?? this.sotaRef,
      potaRef: potaRef ?? this.potaRef,
      wwffRef: wwffRef ?? this.wwffRef,
      sig: sig ?? this.sig,
      sigInfo: sigInfo ?? this.sigInfo,
      mySotaRef: mySotaRef ?? this.mySotaRef,
      myPotaRef: myPotaRef ?? this.myPotaRef,
      myWwffRef: myWwffRef ?? this.myWwffRef,
      mySig: mySig ?? this.mySig,
      mySigInfo: mySigInfo ?? this.mySigInfo,
      stationCallsign: stationCallsign ?? this.stationCallsign,
      operator: operator ?? this.operator,
      myGridsquare: myGridsquare ?? this.myGridsquare,
      txPwr: txPwr ?? this.txPwr,
      contestId: contestId ?? this.contestId,
      srx: srx ?? this.srx,
      stx: stx ?? this.stx,
      srxString: srxString ?? this.srxString,
      stxString: stxString ?? this.stxString,
      check: check ?? this.check,
      qsoClass: qsoClass ?? this.qsoClass,
      precedence: precedence ?? this.precedence,
      arrlSect: arrlSect ?? this.arrlSect,
      propMode: propMode ?? this.propMode,
      satName: satName ?? this.satName,
      satMode: satMode ?? this.satMode,
      comment: comment ?? this.comment,
      notes: notes ?? this.notes,
      qslVia: qslVia ?? this.qslVia,
      adifExtra: adifExtra ?? this.adifExtra,
      contestSessionId: contestSessionId ?? this.contestSessionId,
      activationId: activationId ?? this.activationId,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (hlcCreated.present) {
      map['hlc_created'] = Variable<String>(hlcCreated.value);
    }
    if (hlcModified.present) {
      map['hlc_modified'] = Variable<String>(hlcModified.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (stationProfileId.present) {
      map['station_profile_id'] = Variable<String>(stationProfileId.value);
    }
    if (call.present) {
      map['call'] = Variable<String>(call.value);
    }
    if (timeOn.present) {
      map['time_on'] = Variable<int>(timeOn.value);
    }
    if (timeOff.present) {
      map['time_off'] = Variable<int>(timeOff.value);
    }
    if (band.present) {
      map['band'] = Variable<String>(band.value);
    }
    if (bandRx.present) {
      map['band_rx'] = Variable<String>(bandRx.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (submode.present) {
      map['submode'] = Variable<String>(submode.value);
    }
    if (freqHz.present) {
      map['freq_hz'] = Variable<int>(freqHz.value);
    }
    if (freqRxHz.present) {
      map['freq_rx_hz'] = Variable<int>(freqRxHz.value);
    }
    if (rstSent.present) {
      map['rst_sent'] = Variable<String>(rstSent.value);
    }
    if (rstRcvd.present) {
      map['rst_rcvd'] = Variable<String>(rstRcvd.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qth.present) {
      map['qth'] = Variable<String>(qth.value);
    }
    if (gridsquare.present) {
      map['gridsquare'] = Variable<String>(gridsquare.value);
    }
    if (dxcc.present) {
      map['dxcc'] = Variable<int>(dxcc.value);
    }
    if (cqz.present) {
      map['cqz'] = Variable<int>(cqz.value);
    }
    if (ituz.present) {
      map['ituz'] = Variable<int>(ituz.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (cnty.present) {
      map['cnty'] = Variable<String>(cnty.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (cont.present) {
      map['cont'] = Variable<String>(cont.value);
    }
    if (darcDok.present) {
      map['darc_dok'] = Variable<String>(darcDok.value);
    }
    if (iota.present) {
      map['iota'] = Variable<String>(iota.value);
    }
    if (sotaRef.present) {
      map['sota_ref'] = Variable<String>(sotaRef.value);
    }
    if (potaRef.present) {
      map['pota_ref'] = Variable<String>(potaRef.value);
    }
    if (wwffRef.present) {
      map['wwff_ref'] = Variable<String>(wwffRef.value);
    }
    if (sig.present) {
      map['sig'] = Variable<String>(sig.value);
    }
    if (sigInfo.present) {
      map['sig_info'] = Variable<String>(sigInfo.value);
    }
    if (mySotaRef.present) {
      map['my_sota_ref'] = Variable<String>(mySotaRef.value);
    }
    if (myPotaRef.present) {
      map['my_pota_ref'] = Variable<String>(myPotaRef.value);
    }
    if (myWwffRef.present) {
      map['my_wwff_ref'] = Variable<String>(myWwffRef.value);
    }
    if (mySig.present) {
      map['my_sig'] = Variable<String>(mySig.value);
    }
    if (mySigInfo.present) {
      map['my_sig_info'] = Variable<String>(mySigInfo.value);
    }
    if (stationCallsign.present) {
      map['station_callsign'] = Variable<String>(stationCallsign.value);
    }
    if (operator.present) {
      map['operator'] = Variable<String>(operator.value);
    }
    if (myGridsquare.present) {
      map['my_gridsquare'] = Variable<String>(myGridsquare.value);
    }
    if (txPwr.present) {
      map['tx_pwr'] = Variable<double>(txPwr.value);
    }
    if (contestId.present) {
      map['contest_id'] = Variable<String>(contestId.value);
    }
    if (srx.present) {
      map['srx'] = Variable<int>(srx.value);
    }
    if (stx.present) {
      map['stx'] = Variable<int>(stx.value);
    }
    if (srxString.present) {
      map['srx_string'] = Variable<String>(srxString.value);
    }
    if (stxString.present) {
      map['stx_string'] = Variable<String>(stxString.value);
    }
    if (check.present) {
      map['check'] = Variable<String>(check.value);
    }
    if (qsoClass.present) {
      map['class'] = Variable<String>(qsoClass.value);
    }
    if (precedence.present) {
      map['precedence'] = Variable<String>(precedence.value);
    }
    if (arrlSect.present) {
      map['arrl_sect'] = Variable<String>(arrlSect.value);
    }
    if (propMode.present) {
      map['prop_mode'] = Variable<String>(propMode.value);
    }
    if (satName.present) {
      map['sat_name'] = Variable<String>(satName.value);
    }
    if (satMode.present) {
      map['sat_mode'] = Variable<String>(satMode.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (qslVia.present) {
      map['qsl_via'] = Variable<String>(qslVia.value);
    }
    if (adifExtra.present) {
      map['adif_extra'] = Variable<String>(adifExtra.value);
    }
    if (contestSessionId.present) {
      map['contest_session_id'] = Variable<String>(contestSessionId.value);
    }
    if (activationId.present) {
      map['activation_id'] = Variable<String>(activationId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QsosCompanion(')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('hlcCreated: $hlcCreated, ')
          ..write('hlcModified: $hlcModified, ')
          ..write('rev: $rev, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('stationProfileId: $stationProfileId, ')
          ..write('call: $call, ')
          ..write('timeOn: $timeOn, ')
          ..write('timeOff: $timeOff, ')
          ..write('band: $band, ')
          ..write('bandRx: $bandRx, ')
          ..write('mode: $mode, ')
          ..write('submode: $submode, ')
          ..write('freqHz: $freqHz, ')
          ..write('freqRxHz: $freqRxHz, ')
          ..write('rstSent: $rstSent, ')
          ..write('rstRcvd: $rstRcvd, ')
          ..write('name: $name, ')
          ..write('qth: $qth, ')
          ..write('gridsquare: $gridsquare, ')
          ..write('dxcc: $dxcc, ')
          ..write('cqz: $cqz, ')
          ..write('ituz: $ituz, ')
          ..write('state: $state, ')
          ..write('cnty: $cnty, ')
          ..write('country: $country, ')
          ..write('cont: $cont, ')
          ..write('darcDok: $darcDok, ')
          ..write('iota: $iota, ')
          ..write('sotaRef: $sotaRef, ')
          ..write('potaRef: $potaRef, ')
          ..write('wwffRef: $wwffRef, ')
          ..write('sig: $sig, ')
          ..write('sigInfo: $sigInfo, ')
          ..write('mySotaRef: $mySotaRef, ')
          ..write('myPotaRef: $myPotaRef, ')
          ..write('myWwffRef: $myWwffRef, ')
          ..write('mySig: $mySig, ')
          ..write('mySigInfo: $mySigInfo, ')
          ..write('stationCallsign: $stationCallsign, ')
          ..write('operator: $operator, ')
          ..write('myGridsquare: $myGridsquare, ')
          ..write('txPwr: $txPwr, ')
          ..write('contestId: $contestId, ')
          ..write('srx: $srx, ')
          ..write('stx: $stx, ')
          ..write('srxString: $srxString, ')
          ..write('stxString: $stxString, ')
          ..write('check: $check, ')
          ..write('qsoClass: $qsoClass, ')
          ..write('precedence: $precedence, ')
          ..write('arrlSect: $arrlSect, ')
          ..write('propMode: $propMode, ')
          ..write('satName: $satName, ')
          ..write('satMode: $satMode, ')
          ..write('comment: $comment, ')
          ..write('notes: $notes, ')
          ..write('qslVia: $qslVia, ')
          ..write('adifExtra: $adifExtra, ')
          ..write('contestSessionId: $contestSessionId, ')
          ..write('activationId: $activationId, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QsoSyncTable extends QsoSync with TableInfo<$QsoSyncTable, QsoSyncRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QsoSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _qsoIdMeta = const VerificationMeta('qsoId');
  @override
  late final GeneratedColumn<String> qsoId = GeneratedColumn<String>(
    'qso_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES qsos (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('create'),
  );
  static const VerificationMeta _remoteQsoIdMeta = const VerificationMeta(
    'remoteQsoId',
  );
  @override
  late final GeneratedColumn<int> remoteQsoId = GeneratedColumn<int>(
    'remote_qso_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAt = GeneratedColumn<int>(
    'next_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorKeyMeta = const VerificationMeta(
    'lastErrorKey',
  );
  @override
  late final GeneratedColumn<String> lastErrorKey = GeneratedColumn<String>(
    'last_error_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverMessageMeta = const VerificationMeta(
    'serverMessage',
  );
  @override
  late final GeneratedColumn<String> serverMessage = GeneratedColumn<String>(
    'server_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedRevMeta = const VerificationMeta(
    'syncedRev',
  );
  @override
  late final GeneratedColumn<int> syncedRev = GeneratedColumn<int>(
    'synced_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedHashMeta = const VerificationMeta(
    'syncedHash',
  );
  @override
  late final GeneratedColumn<String> syncedHash = GeneratedColumn<String>(
    'synced_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    qsoId,
    accountId,
    state,
    operation,
    remoteQsoId,
    attempts,
    nextAttemptAt,
    lastErrorCode,
    lastErrorKey,
    serverMessage,
    syncedRev,
    syncedHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'qso_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<QsoSyncRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('qso_id')) {
      context.handle(
        _qsoIdMeta,
        qsoId.isAcceptableOrUnknown(data['qso_id']!, _qsoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_qsoIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    }
    if (data.containsKey('remote_qso_id')) {
      context.handle(
        _remoteQsoIdMeta,
        remoteQsoId.isAcceptableOrUnknown(
          data['remote_qso_id']!,
          _remoteQsoIdMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_error_key')) {
      context.handle(
        _lastErrorKeyMeta,
        lastErrorKey.isAcceptableOrUnknown(
          data['last_error_key']!,
          _lastErrorKeyMeta,
        ),
      );
    }
    if (data.containsKey('server_message')) {
      context.handle(
        _serverMessageMeta,
        serverMessage.isAcceptableOrUnknown(
          data['server_message']!,
          _serverMessageMeta,
        ),
      );
    }
    if (data.containsKey('synced_rev')) {
      context.handle(
        _syncedRevMeta,
        syncedRev.isAcceptableOrUnknown(data['synced_rev']!, _syncedRevMeta),
      );
    }
    if (data.containsKey('synced_hash')) {
      context.handle(
        _syncedHashMeta,
        syncedHash.isAcceptableOrUnknown(data['synced_hash']!, _syncedHashMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {qsoId, accountId};
  @override
  QsoSyncRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QsoSyncRow(
      qsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qso_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      remoteQsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_qso_id'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      lastErrorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_key'],
      ),
      serverMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_message'],
      ),
      syncedRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_rev'],
      ),
      syncedHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_hash'],
      ),
    );
  }

  @override
  $QsoSyncTable createAlias(String alias) {
    return $QsoSyncTable(attachedDatabase, alias);
  }
}

class QsoSyncRow extends DataClass implements Insertable<QsoSyncRow> {
  final String qsoId;
  final String accountId;

  /// `SyncState.name` from tideline_domain.
  final String state;

  /// `SyncOperation.name` from tideline_domain.
  final String operation;

  /// Wavelog QSO id, once known.
  final int? remoteQsoId;
  final int attempts;
  final int? nextAttemptAt;
  final String? lastErrorCode;

  /// Localisation key of the plain-language explanation.
  final String? lastErrorKey;

  /// The server's own message, redacted.
  final String? serverMessage;
  final int? syncedRev;
  final String? syncedHash;
  const QsoSyncRow({
    required this.qsoId,
    required this.accountId,
    required this.state,
    required this.operation,
    this.remoteQsoId,
    required this.attempts,
    this.nextAttemptAt,
    this.lastErrorCode,
    this.lastErrorKey,
    this.serverMessage,
    this.syncedRev,
    this.syncedHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['qso_id'] = Variable<String>(qsoId);
    map['account_id'] = Variable<String>(accountId);
    map['state'] = Variable<String>(state);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || remoteQsoId != null) {
      map['remote_qso_id'] = Variable<int>(remoteQsoId);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastErrorKey != null) {
      map['last_error_key'] = Variable<String>(lastErrorKey);
    }
    if (!nullToAbsent || serverMessage != null) {
      map['server_message'] = Variable<String>(serverMessage);
    }
    if (!nullToAbsent || syncedRev != null) {
      map['synced_rev'] = Variable<int>(syncedRev);
    }
    if (!nullToAbsent || syncedHash != null) {
      map['synced_hash'] = Variable<String>(syncedHash);
    }
    return map;
  }

  QsoSyncCompanion toCompanion(bool nullToAbsent) {
    return QsoSyncCompanion(
      qsoId: Value(qsoId),
      accountId: Value(accountId),
      state: Value(state),
      operation: Value(operation),
      remoteQsoId: remoteQsoId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteQsoId),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastErrorKey: lastErrorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorKey),
      serverMessage: serverMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(serverMessage),
      syncedRev: syncedRev == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedRev),
      syncedHash: syncedHash == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedHash),
    );
  }

  factory QsoSyncRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QsoSyncRow(
      qsoId: serializer.fromJson<String>(json['qsoId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      state: serializer.fromJson<String>(json['state']),
      operation: serializer.fromJson<String>(json['operation']),
      remoteQsoId: serializer.fromJson<int?>(json['remoteQsoId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<int?>(json['nextAttemptAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastErrorKey: serializer.fromJson<String?>(json['lastErrorKey']),
      serverMessage: serializer.fromJson<String?>(json['serverMessage']),
      syncedRev: serializer.fromJson<int?>(json['syncedRev']),
      syncedHash: serializer.fromJson<String?>(json['syncedHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'qsoId': serializer.toJson<String>(qsoId),
      'accountId': serializer.toJson<String>(accountId),
      'state': serializer.toJson<String>(state),
      'operation': serializer.toJson<String>(operation),
      'remoteQsoId': serializer.toJson<int?>(remoteQsoId),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<int?>(nextAttemptAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastErrorKey': serializer.toJson<String?>(lastErrorKey),
      'serverMessage': serializer.toJson<String?>(serverMessage),
      'syncedRev': serializer.toJson<int?>(syncedRev),
      'syncedHash': serializer.toJson<String?>(syncedHash),
    };
  }

  QsoSyncRow copyWith({
    String? qsoId,
    String? accountId,
    String? state,
    String? operation,
    Value<int?> remoteQsoId = const Value.absent(),
    int? attempts,
    Value<int?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> lastErrorKey = const Value.absent(),
    Value<String?> serverMessage = const Value.absent(),
    Value<int?> syncedRev = const Value.absent(),
    Value<String?> syncedHash = const Value.absent(),
  }) => QsoSyncRow(
    qsoId: qsoId ?? this.qsoId,
    accountId: accountId ?? this.accountId,
    state: state ?? this.state,
    operation: operation ?? this.operation,
    remoteQsoId: remoteQsoId.present ? remoteQsoId.value : this.remoteQsoId,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    lastErrorKey: lastErrorKey.present ? lastErrorKey.value : this.lastErrorKey,
    serverMessage: serverMessage.present
        ? serverMessage.value
        : this.serverMessage,
    syncedRev: syncedRev.present ? syncedRev.value : this.syncedRev,
    syncedHash: syncedHash.present ? syncedHash.value : this.syncedHash,
  );
  QsoSyncRow copyWithCompanion(QsoSyncCompanion data) {
    return QsoSyncRow(
      qsoId: data.qsoId.present ? data.qsoId.value : this.qsoId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      state: data.state.present ? data.state.value : this.state,
      operation: data.operation.present ? data.operation.value : this.operation,
      remoteQsoId: data.remoteQsoId.present
          ? data.remoteQsoId.value
          : this.remoteQsoId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastErrorKey: data.lastErrorKey.present
          ? data.lastErrorKey.value
          : this.lastErrorKey,
      serverMessage: data.serverMessage.present
          ? data.serverMessage.value
          : this.serverMessage,
      syncedRev: data.syncedRev.present ? data.syncedRev.value : this.syncedRev,
      syncedHash: data.syncedHash.present
          ? data.syncedHash.value
          : this.syncedHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QsoSyncRow(')
          ..write('qsoId: $qsoId, ')
          ..write('accountId: $accountId, ')
          ..write('state: $state, ')
          ..write('operation: $operation, ')
          ..write('remoteQsoId: $remoteQsoId, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorKey: $lastErrorKey, ')
          ..write('serverMessage: $serverMessage, ')
          ..write('syncedRev: $syncedRev, ')
          ..write('syncedHash: $syncedHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    qsoId,
    accountId,
    state,
    operation,
    remoteQsoId,
    attempts,
    nextAttemptAt,
    lastErrorCode,
    lastErrorKey,
    serverMessage,
    syncedRev,
    syncedHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QsoSyncRow &&
          other.qsoId == this.qsoId &&
          other.accountId == this.accountId &&
          other.state == this.state &&
          other.operation == this.operation &&
          other.remoteQsoId == this.remoteQsoId &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastErrorKey == this.lastErrorKey &&
          other.serverMessage == this.serverMessage &&
          other.syncedRev == this.syncedRev &&
          other.syncedHash == this.syncedHash);
}

class QsoSyncCompanion extends UpdateCompanion<QsoSyncRow> {
  final Value<String> qsoId;
  final Value<String> accountId;
  final Value<String> state;
  final Value<String> operation;
  final Value<int?> remoteQsoId;
  final Value<int> attempts;
  final Value<int?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<String?> lastErrorKey;
  final Value<String?> serverMessage;
  final Value<int?> syncedRev;
  final Value<String?> syncedHash;
  final Value<int> rowid;
  const QsoSyncCompanion({
    this.qsoId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.state = const Value.absent(),
    this.operation = const Value.absent(),
    this.remoteQsoId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorKey = const Value.absent(),
    this.serverMessage = const Value.absent(),
    this.syncedRev = const Value.absent(),
    this.syncedHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QsoSyncCompanion.insert({
    required String qsoId,
    required String accountId,
    required String state,
    this.operation = const Value.absent(),
    this.remoteQsoId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorKey = const Value.absent(),
    this.serverMessage = const Value.absent(),
    this.syncedRev = const Value.absent(),
    this.syncedHash = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : qsoId = Value(qsoId),
       accountId = Value(accountId),
       state = Value(state);
  static Insertable<QsoSyncRow> custom({
    Expression<String>? qsoId,
    Expression<String>? accountId,
    Expression<String>? state,
    Expression<String>? operation,
    Expression<int>? remoteQsoId,
    Expression<int>? attempts,
    Expression<int>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<String>? lastErrorKey,
    Expression<String>? serverMessage,
    Expression<int>? syncedRev,
    Expression<String>? syncedHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (qsoId != null) 'qso_id': qsoId,
      if (accountId != null) 'account_id': accountId,
      if (state != null) 'state': state,
      if (operation != null) 'operation': operation,
      if (remoteQsoId != null) 'remote_qso_id': remoteQsoId,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastErrorKey != null) 'last_error_key': lastErrorKey,
      if (serverMessage != null) 'server_message': serverMessage,
      if (syncedRev != null) 'synced_rev': syncedRev,
      if (syncedHash != null) 'synced_hash': syncedHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QsoSyncCompanion copyWith({
    Value<String>? qsoId,
    Value<String>? accountId,
    Value<String>? state,
    Value<String>? operation,
    Value<int?>? remoteQsoId,
    Value<int>? attempts,
    Value<int?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<String?>? lastErrorKey,
    Value<String?>? serverMessage,
    Value<int?>? syncedRev,
    Value<String?>? syncedHash,
    Value<int>? rowid,
  }) {
    return QsoSyncCompanion(
      qsoId: qsoId ?? this.qsoId,
      accountId: accountId ?? this.accountId,
      state: state ?? this.state,
      operation: operation ?? this.operation,
      remoteQsoId: remoteQsoId ?? this.remoteQsoId,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastErrorKey: lastErrorKey ?? this.lastErrorKey,
      serverMessage: serverMessage ?? this.serverMessage,
      syncedRev: syncedRev ?? this.syncedRev,
      syncedHash: syncedHash ?? this.syncedHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (qsoId.present) {
      map['qso_id'] = Variable<String>(qsoId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (remoteQsoId.present) {
      map['remote_qso_id'] = Variable<int>(remoteQsoId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastErrorKey.present) {
      map['last_error_key'] = Variable<String>(lastErrorKey.value);
    }
    if (serverMessage.present) {
      map['server_message'] = Variable<String>(serverMessage.value);
    }
    if (syncedRev.present) {
      map['synced_rev'] = Variable<int>(syncedRev.value);
    }
    if (syncedHash.present) {
      map['synced_hash'] = Variable<String>(syncedHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QsoSyncCompanion(')
          ..write('qsoId: $qsoId, ')
          ..write('accountId: $accountId, ')
          ..write('state: $state, ')
          ..write('operation: $operation, ')
          ..write('remoteQsoId: $remoteQsoId, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorKey: $lastErrorKey, ')
          ..write('serverMessage: $serverMessage, ')
          ..write('syncedRev: $syncedRev, ')
          ..write('syncedHash: $syncedHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncJournalTable extends SyncJournal
    with TableInfo<$SyncJournalTable, SyncJournalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncJournalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _qsoIdMeta = const VerificationMeta('qsoId');
  @override
  late final GeneratedColumn<String> qsoId = GeneratedColumn<String>(
    'qso_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventMeta = const VerificationMeta('event');
  @override
  late final GeneratedColumn<String> event = GeneratedColumn<String>(
    'event',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    qsoId,
    at,
    event,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_journal';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncJournalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('qso_id')) {
      context.handle(
        _qsoIdMeta,
        qsoId.isAcceptableOrUnknown(data['qso_id']!, _qsoIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('event')) {
      context.handle(
        _eventMeta,
        event.isAcceptableOrUnknown(data['event']!, _eventMeta),
      );
    } else if (isInserting) {
      context.missing(_eventMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncJournalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncJournalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      qsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qso_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      event: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      )!,
    );
  }

  @override
  $SyncJournalTable createAlias(String alias) {
    return $SyncJournalTable(attachedDatabase, alias);
  }
}

class SyncJournalRow extends DataClass implements Insertable<SyncJournalRow> {
  final int id;
  final String accountId;
  final String? qsoId;
  final int at;
  final String event;

  /// Redacted JSON detail.
  final String detail;
  const SyncJournalRow({
    required this.id,
    required this.accountId,
    this.qsoId,
    required this.at,
    required this.event,
    required this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || qsoId != null) {
      map['qso_id'] = Variable<String>(qsoId);
    }
    map['at'] = Variable<int>(at);
    map['event'] = Variable<String>(event);
    map['detail'] = Variable<String>(detail);
    return map;
  }

  SyncJournalCompanion toCompanion(bool nullToAbsent) {
    return SyncJournalCompanion(
      id: Value(id),
      accountId: Value(accountId),
      qsoId: qsoId == null && nullToAbsent
          ? const Value.absent()
          : Value(qsoId),
      at: Value(at),
      event: Value(event),
      detail: Value(detail),
    );
  }

  factory SyncJournalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncJournalRow(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      qsoId: serializer.fromJson<String?>(json['qsoId']),
      at: serializer.fromJson<int>(json['at']),
      event: serializer.fromJson<String>(json['event']),
      detail: serializer.fromJson<String>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<String>(accountId),
      'qsoId': serializer.toJson<String?>(qsoId),
      'at': serializer.toJson<int>(at),
      'event': serializer.toJson<String>(event),
      'detail': serializer.toJson<String>(detail),
    };
  }

  SyncJournalRow copyWith({
    int? id,
    String? accountId,
    Value<String?> qsoId = const Value.absent(),
    int? at,
    String? event,
    String? detail,
  }) => SyncJournalRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    qsoId: qsoId.present ? qsoId.value : this.qsoId,
    at: at ?? this.at,
    event: event ?? this.event,
    detail: detail ?? this.detail,
  );
  SyncJournalRow copyWithCompanion(SyncJournalCompanion data) {
    return SyncJournalRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      qsoId: data.qsoId.present ? data.qsoId.value : this.qsoId,
      at: data.at.present ? data.at.value : this.at,
      event: data.event.present ? data.event.value : this.event,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncJournalRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('qsoId: $qsoId, ')
          ..write('at: $at, ')
          ..write('event: $event, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, qsoId, at, event, detail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncJournalRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.qsoId == this.qsoId &&
          other.at == this.at &&
          other.event == this.event &&
          other.detail == this.detail);
}

class SyncJournalCompanion extends UpdateCompanion<SyncJournalRow> {
  final Value<int> id;
  final Value<String> accountId;
  final Value<String?> qsoId;
  final Value<int> at;
  final Value<String> event;
  final Value<String> detail;
  const SyncJournalCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.qsoId = const Value.absent(),
    this.at = const Value.absent(),
    this.event = const Value.absent(),
    this.detail = const Value.absent(),
  });
  SyncJournalCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    this.qsoId = const Value.absent(),
    required int at,
    required String event,
    this.detail = const Value.absent(),
  }) : accountId = Value(accountId),
       at = Value(at),
       event = Value(event);
  static Insertable<SyncJournalRow> custom({
    Expression<int>? id,
    Expression<String>? accountId,
    Expression<String>? qsoId,
    Expression<int>? at,
    Expression<String>? event,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (qsoId != null) 'qso_id': qsoId,
      if (at != null) 'at': at,
      if (event != null) 'event': event,
      if (detail != null) 'detail': detail,
    });
  }

  SyncJournalCompanion copyWith({
    Value<int>? id,
    Value<String>? accountId,
    Value<String?>? qsoId,
    Value<int>? at,
    Value<String>? event,
    Value<String>? detail,
  }) {
    return SyncJournalCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      qsoId: qsoId ?? this.qsoId,
      at: at ?? this.at,
      event: event ?? this.event,
      detail: detail ?? this.detail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (qsoId.present) {
      map['qso_id'] = Variable<String>(qsoId.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (event.present) {
      map['event'] = Variable<String>(event.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncJournalCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('qsoId: $qsoId, ')
          ..write('at: $at, ')
          ..write('event: $event, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

class $SerialAllocationsTable extends SerialAllocations
    with TableInfo<$SerialAllocationsTable, SerialAllocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SerialAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contest_sessions (id)',
    ),
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<int> serial = GeneratedColumn<int>(
    'serial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qsoIdMeta = const VerificationMeta('qsoId');
  @override
  late final GeneratedColumn<String> qsoId = GeneratedColumn<String>(
    'qso_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allocatedAtMeta = const VerificationMeta(
    'allocatedAt',
  );
  @override
  late final GeneratedColumn<int> allocatedAt = GeneratedColumn<int>(
    'allocated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, serial, qsoId, allocatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'serial_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SerialAllocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    } else if (isInserting) {
      context.missing(_serialMeta);
    }
    if (data.containsKey('qso_id')) {
      context.handle(
        _qsoIdMeta,
        qsoId.isAcceptableOrUnknown(data['qso_id']!, _qsoIdMeta),
      );
    }
    if (data.containsKey('allocated_at')) {
      context.handle(
        _allocatedAtMeta,
        allocatedAt.isAcceptableOrUnknown(
          data['allocated_at']!,
          _allocatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, serial};
  @override
  SerialAllocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SerialAllocationRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serial'],
      )!,
      qsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qso_id'],
      ),
      allocatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allocated_at'],
      )!,
    );
  }

  @override
  $SerialAllocationsTable createAlias(String alias) {
    return $SerialAllocationsTable(attachedDatabase, alias);
  }
}

class SerialAllocationRow extends DataClass
    implements Insertable<SerialAllocationRow> {
  final String sessionId;
  final int serial;

  /// Null once the QSO that used the serial was deleted.
  final String? qsoId;
  final int allocatedAt;
  const SerialAllocationRow({
    required this.sessionId,
    required this.serial,
    this.qsoId,
    required this.allocatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['serial'] = Variable<int>(serial);
    if (!nullToAbsent || qsoId != null) {
      map['qso_id'] = Variable<String>(qsoId);
    }
    map['allocated_at'] = Variable<int>(allocatedAt);
    return map;
  }

  SerialAllocationsCompanion toCompanion(bool nullToAbsent) {
    return SerialAllocationsCompanion(
      sessionId: Value(sessionId),
      serial: Value(serial),
      qsoId: qsoId == null && nullToAbsent
          ? const Value.absent()
          : Value(qsoId),
      allocatedAt: Value(allocatedAt),
    );
  }

  factory SerialAllocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SerialAllocationRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      serial: serializer.fromJson<int>(json['serial']),
      qsoId: serializer.fromJson<String?>(json['qsoId']),
      allocatedAt: serializer.fromJson<int>(json['allocatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'serial': serializer.toJson<int>(serial),
      'qsoId': serializer.toJson<String?>(qsoId),
      'allocatedAt': serializer.toJson<int>(allocatedAt),
    };
  }

  SerialAllocationRow copyWith({
    String? sessionId,
    int? serial,
    Value<String?> qsoId = const Value.absent(),
    int? allocatedAt,
  }) => SerialAllocationRow(
    sessionId: sessionId ?? this.sessionId,
    serial: serial ?? this.serial,
    qsoId: qsoId.present ? qsoId.value : this.qsoId,
    allocatedAt: allocatedAt ?? this.allocatedAt,
  );
  SerialAllocationRow copyWithCompanion(SerialAllocationsCompanion data) {
    return SerialAllocationRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      serial: data.serial.present ? data.serial.value : this.serial,
      qsoId: data.qsoId.present ? data.qsoId.value : this.qsoId,
      allocatedAt: data.allocatedAt.present
          ? data.allocatedAt.value
          : this.allocatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SerialAllocationRow(')
          ..write('sessionId: $sessionId, ')
          ..write('serial: $serial, ')
          ..write('qsoId: $qsoId, ')
          ..write('allocatedAt: $allocatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, serial, qsoId, allocatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SerialAllocationRow &&
          other.sessionId == this.sessionId &&
          other.serial == this.serial &&
          other.qsoId == this.qsoId &&
          other.allocatedAt == this.allocatedAt);
}

class SerialAllocationsCompanion extends UpdateCompanion<SerialAllocationRow> {
  final Value<String> sessionId;
  final Value<int> serial;
  final Value<String?> qsoId;
  final Value<int> allocatedAt;
  final Value<int> rowid;
  const SerialAllocationsCompanion({
    this.sessionId = const Value.absent(),
    this.serial = const Value.absent(),
    this.qsoId = const Value.absent(),
    this.allocatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SerialAllocationsCompanion.insert({
    required String sessionId,
    required int serial,
    this.qsoId = const Value.absent(),
    required int allocatedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       serial = Value(serial),
       allocatedAt = Value(allocatedAt);
  static Insertable<SerialAllocationRow> custom({
    Expression<String>? sessionId,
    Expression<int>? serial,
    Expression<String>? qsoId,
    Expression<int>? allocatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (serial != null) 'serial': serial,
      if (qsoId != null) 'qso_id': qsoId,
      if (allocatedAt != null) 'allocated_at': allocatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SerialAllocationsCompanion copyWith({
    Value<String>? sessionId,
    Value<int>? serial,
    Value<String?>? qsoId,
    Value<int>? allocatedAt,
    Value<int>? rowid,
  }) {
    return SerialAllocationsCompanion(
      sessionId: sessionId ?? this.sessionId,
      serial: serial ?? this.serial,
      qsoId: qsoId ?? this.qsoId,
      allocatedAt: allocatedAt ?? this.allocatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (serial.present) {
      map['serial'] = Variable<int>(serial.value);
    }
    if (qsoId.present) {
      map['qso_id'] = Variable<String>(qsoId.value);
    }
    if (allocatedAt.present) {
      map['allocated_at'] = Variable<int>(allocatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SerialAllocationsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('serial: $serial, ')
          ..write('qsoId: $qsoId, ')
          ..write('allocatedAt: $allocatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramRulesTable extends ProgramRules
    with TableInfo<$ProgramRulesTable, ProgramRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _programMeta = const VerificationMeta(
    'program',
  );
  @override
  late final GeneratedColumn<String> program = GeneratedColumn<String>(
    'program',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesMeta = const VerificationMeta('rules');
  @override
  late final GeneratedColumn<String> rules = GeneratedColumn<String>(
    'rules',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [program, version, rules];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('program')) {
      context.handle(
        _programMeta,
        program.isAcceptableOrUnknown(data['program']!, _programMeta),
      );
    } else if (isInserting) {
      context.missing(_programMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('rules')) {
      context.handle(
        _rulesMeta,
        rules.isAcceptableOrUnknown(data['rules']!, _rulesMeta),
      );
    } else if (isInserting) {
      context.missing(_rulesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {program};
  @override
  ProgramRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramRuleRow(
      program: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      rules: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules'],
      )!,
    );
  }

  @override
  $ProgramRulesTable createAlias(String alias) {
    return $ProgramRulesTable(attachedDatabase, alias);
  }
}

class ProgramRuleRow extends DataClass implements Insertable<ProgramRuleRow> {
  final String program;
  final int version;

  /// JSON: validity threshold, per-band/mode rules.
  final String rules;
  const ProgramRuleRow({
    required this.program,
    required this.version,
    required this.rules,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['program'] = Variable<String>(program);
    map['version'] = Variable<int>(version);
    map['rules'] = Variable<String>(rules);
    return map;
  }

  ProgramRulesCompanion toCompanion(bool nullToAbsent) {
    return ProgramRulesCompanion(
      program: Value(program),
      version: Value(version),
      rules: Value(rules),
    );
  }

  factory ProgramRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramRuleRow(
      program: serializer.fromJson<String>(json['program']),
      version: serializer.fromJson<int>(json['version']),
      rules: serializer.fromJson<String>(json['rules']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'program': serializer.toJson<String>(program),
      'version': serializer.toJson<int>(version),
      'rules': serializer.toJson<String>(rules),
    };
  }

  ProgramRuleRow copyWith({String? program, int? version, String? rules}) =>
      ProgramRuleRow(
        program: program ?? this.program,
        version: version ?? this.version,
        rules: rules ?? this.rules,
      );
  ProgramRuleRow copyWithCompanion(ProgramRulesCompanion data) {
    return ProgramRuleRow(
      program: data.program.present ? data.program.value : this.program,
      version: data.version.present ? data.version.value : this.version,
      rules: data.rules.present ? data.rules.value : this.rules,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramRuleRow(')
          ..write('program: $program, ')
          ..write('version: $version, ')
          ..write('rules: $rules')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(program, version, rules);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramRuleRow &&
          other.program == this.program &&
          other.version == this.version &&
          other.rules == this.rules);
}

class ProgramRulesCompanion extends UpdateCompanion<ProgramRuleRow> {
  final Value<String> program;
  final Value<int> version;
  final Value<String> rules;
  final Value<int> rowid;
  const ProgramRulesCompanion({
    this.program = const Value.absent(),
    this.version = const Value.absent(),
    this.rules = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramRulesCompanion.insert({
    required String program,
    required int version,
    required String rules,
    this.rowid = const Value.absent(),
  }) : program = Value(program),
       version = Value(version),
       rules = Value(rules);
  static Insertable<ProgramRuleRow> custom({
    Expression<String>? program,
    Expression<int>? version,
    Expression<String>? rules,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (program != null) 'program': program,
      if (version != null) 'version': version,
      if (rules != null) 'rules': rules,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramRulesCompanion copyWith({
    Value<String>? program,
    Value<int>? version,
    Value<String>? rules,
    Value<int>? rowid,
  }) {
    return ProgramRulesCompanion(
      program: program ?? this.program,
      version: version ?? this.version,
      rules: rules ?? this.rules,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (program.present) {
      map['program'] = Variable<String>(program.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rules.present) {
      map['rules'] = Variable<String>(rules.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramRulesCompanion(')
          ..write('program: $program, ')
          ..write('version: $version, ')
          ..write('rules: $rules, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferencePacksTable extends ReferencePacks
    with TableInfo<$ReferencePacksTable, ReferencePackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferencePacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionFilterMeta = const VerificationMeta(
    'regionFilter',
  );
  @override
  late final GeneratedColumn<String> regionFilter = GeneratedColumn<String>(
    'region_filter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenceNoteMeta = const VerificationMeta(
    'licenceNote',
  );
  @override
  late final GeneratedColumn<String> licenceNote = GeneratedColumn<String>(
    'licence_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    version,
    sourceUrl,
    sha256,
    fetchedAt,
    regionFilter,
    licenceNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReferencePackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('region_filter')) {
      context.handle(
        _regionFilterMeta,
        regionFilter.isAcceptableOrUnknown(
          data['region_filter']!,
          _regionFilterMeta,
        ),
      );
    }
    if (data.containsKey('licence_note')) {
      context.handle(
        _licenceNoteMeta,
        licenceNote.isAcceptableOrUnknown(
          data['licence_note']!,
          _licenceNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReferencePackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferencePackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
      regionFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_filter'],
      ),
      licenceNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}licence_note'],
      ),
    );
  }

  @override
  $ReferencePacksTable createAlias(String alias) {
    return $ReferencePacksTable(attachedDatabase, alias);
  }
}

class ReferencePackRow extends DataClass
    implements Insertable<ReferencePackRow> {
  final String id;

  /// `dxcc`, `sota`, `pota`, `wwff`, `iota` or `scp`.
  final String kind;
  final String version;
  final String sourceUrl;
  final String sha256;
  final int fetchedAt;
  final String? regionFilter;
  final String? licenceNote;
  const ReferencePackRow({
    required this.id,
    required this.kind,
    required this.version,
    required this.sourceUrl,
    required this.sha256,
    required this.fetchedAt,
    this.regionFilter,
    this.licenceNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['version'] = Variable<String>(version);
    map['source_url'] = Variable<String>(sourceUrl);
    map['sha256'] = Variable<String>(sha256);
    map['fetched_at'] = Variable<int>(fetchedAt);
    if (!nullToAbsent || regionFilter != null) {
      map['region_filter'] = Variable<String>(regionFilter);
    }
    if (!nullToAbsent || licenceNote != null) {
      map['licence_note'] = Variable<String>(licenceNote);
    }
    return map;
  }

  ReferencePacksCompanion toCompanion(bool nullToAbsent) {
    return ReferencePacksCompanion(
      id: Value(id),
      kind: Value(kind),
      version: Value(version),
      sourceUrl: Value(sourceUrl),
      sha256: Value(sha256),
      fetchedAt: Value(fetchedAt),
      regionFilter: regionFilter == null && nullToAbsent
          ? const Value.absent()
          : Value(regionFilter),
      licenceNote: licenceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(licenceNote),
    );
  }

  factory ReferencePackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferencePackRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      version: serializer.fromJson<String>(json['version']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      sha256: serializer.fromJson<String>(json['sha256']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
      regionFilter: serializer.fromJson<String?>(json['regionFilter']),
      licenceNote: serializer.fromJson<String?>(json['licenceNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'version': serializer.toJson<String>(version),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'sha256': serializer.toJson<String>(sha256),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
      'regionFilter': serializer.toJson<String?>(regionFilter),
      'licenceNote': serializer.toJson<String?>(licenceNote),
    };
  }

  ReferencePackRow copyWith({
    String? id,
    String? kind,
    String? version,
    String? sourceUrl,
    String? sha256,
    int? fetchedAt,
    Value<String?> regionFilter = const Value.absent(),
    Value<String?> licenceNote = const Value.absent(),
  }) => ReferencePackRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    version: version ?? this.version,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    sha256: sha256 ?? this.sha256,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    regionFilter: regionFilter.present ? regionFilter.value : this.regionFilter,
    licenceNote: licenceNote.present ? licenceNote.value : this.licenceNote,
  );
  ReferencePackRow copyWithCompanion(ReferencePacksCompanion data) {
    return ReferencePackRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      version: data.version.present ? data.version.value : this.version,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      regionFilter: data.regionFilter.present
          ? data.regionFilter.value
          : this.regionFilter,
      licenceNote: data.licenceNote.present
          ? data.licenceNote.value
          : this.licenceNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferencePackRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('version: $version, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sha256: $sha256, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('regionFilter: $regionFilter, ')
          ..write('licenceNote: $licenceNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    version,
    sourceUrl,
    sha256,
    fetchedAt,
    regionFilter,
    licenceNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferencePackRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.version == this.version &&
          other.sourceUrl == this.sourceUrl &&
          other.sha256 == this.sha256 &&
          other.fetchedAt == this.fetchedAt &&
          other.regionFilter == this.regionFilter &&
          other.licenceNote == this.licenceNote);
}

class ReferencePacksCompanion extends UpdateCompanion<ReferencePackRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> version;
  final Value<String> sourceUrl;
  final Value<String> sha256;
  final Value<int> fetchedAt;
  final Value<String?> regionFilter;
  final Value<String?> licenceNote;
  final Value<int> rowid;
  const ReferencePacksCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.version = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.regionFilter = const Value.absent(),
    this.licenceNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferencePacksCompanion.insert({
    required String id,
    required String kind,
    required String version,
    required String sourceUrl,
    required String sha256,
    required int fetchedAt,
    this.regionFilter = const Value.absent(),
    this.licenceNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       version = Value(version),
       sourceUrl = Value(sourceUrl),
       sha256 = Value(sha256),
       fetchedAt = Value(fetchedAt);
  static Insertable<ReferencePackRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? version,
    Expression<String>? sourceUrl,
    Expression<String>? sha256,
    Expression<int>? fetchedAt,
    Expression<String>? regionFilter,
    Expression<String>? licenceNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (version != null) 'version': version,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (sha256 != null) 'sha256': sha256,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (regionFilter != null) 'region_filter': regionFilter,
      if (licenceNote != null) 'licence_note': licenceNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferencePacksCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? version,
    Value<String>? sourceUrl,
    Value<String>? sha256,
    Value<int>? fetchedAt,
    Value<String?>? regionFilter,
    Value<String?>? licenceNote,
    Value<int>? rowid,
  }) {
    return ReferencePacksCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      version: version ?? this.version,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sha256: sha256 ?? this.sha256,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      regionFilter: regionFilter ?? this.regionFilter,
      licenceNote: licenceNote ?? this.licenceNote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (regionFilter.present) {
      map['region_filter'] = Variable<String>(regionFilter.value);
    }
    if (licenceNote.present) {
      map['licence_note'] = Variable<String>(licenceNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferencePacksCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('version: $version, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sha256: $sha256, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('regionFilter: $regionFilter, ')
          ..write('licenceNote: $licenceNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DxccEntitiesTable extends DxccEntities
    with TableInfo<$DxccEntitiesTable, DxccEntityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DxccEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dxccMeta = const VerificationMeta('dxcc');
  @override
  late final GeneratedColumn<int> dxcc = GeneratedColumn<int>(
    'dxcc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prefixMeta = const VerificationMeta('prefix');
  @override
  late final GeneratedColumn<String> prefix = GeneratedColumn<String>(
    'prefix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cqzMeta = const VerificationMeta('cqz');
  @override
  late final GeneratedColumn<int> cqz = GeneratedColumn<int>(
    'cqz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ituzMeta = const VerificationMeta('ituz');
  @override
  late final GeneratedColumn<int> ituz = GeneratedColumn<int>(
    'ituz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contMeta = const VerificationMeta('cont');
  @override
  late final GeneratedColumn<String> cont = GeneratedColumn<String>(
    'cont',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dxcc,
    name,
    prefix,
    cqz,
    ituz,
    cont,
    lat,
    lon,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dxcc_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<DxccEntityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dxcc')) {
      context.handle(
        _dxccMeta,
        dxcc.isAcceptableOrUnknown(data['dxcc']!, _dxccMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('prefix')) {
      context.handle(
        _prefixMeta,
        prefix.isAcceptableOrUnknown(data['prefix']!, _prefixMeta),
      );
    } else if (isInserting) {
      context.missing(_prefixMeta);
    }
    if (data.containsKey('cqz')) {
      context.handle(
        _cqzMeta,
        cqz.isAcceptableOrUnknown(data['cqz']!, _cqzMeta),
      );
    } else if (isInserting) {
      context.missing(_cqzMeta);
    }
    if (data.containsKey('ituz')) {
      context.handle(
        _ituzMeta,
        ituz.isAcceptableOrUnknown(data['ituz']!, _ituzMeta),
      );
    } else if (isInserting) {
      context.missing(_ituzMeta);
    }
    if (data.containsKey('cont')) {
      context.handle(
        _contMeta,
        cont.isAcceptableOrUnknown(data['cont']!, _contMeta),
      );
    } else if (isInserting) {
      context.missing(_contMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dxcc};
  @override
  DxccEntityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DxccEntityRow(
      dxcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dxcc'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      prefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prefix'],
      )!,
      cqz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cqz'],
      )!,
      ituz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ituz'],
      )!,
      cont: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cont'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $DxccEntitiesTable createAlias(String alias) {
    return $DxccEntitiesTable(attachedDatabase, alias);
  }
}

class DxccEntityRow extends DataClass implements Insertable<DxccEntityRow> {
  final int dxcc;
  final String name;
  final String prefix;
  final int cqz;
  final int ituz;
  final String cont;
  final double lat;
  final double lon;
  final bool deleted;
  const DxccEntityRow({
    required this.dxcc,
    required this.name,
    required this.prefix,
    required this.cqz,
    required this.ituz,
    required this.cont,
    required this.lat,
    required this.lon,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dxcc'] = Variable<int>(dxcc);
    map['name'] = Variable<String>(name);
    map['prefix'] = Variable<String>(prefix);
    map['cqz'] = Variable<int>(cqz);
    map['ituz'] = Variable<int>(ituz);
    map['cont'] = Variable<String>(cont);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  DxccEntitiesCompanion toCompanion(bool nullToAbsent) {
    return DxccEntitiesCompanion(
      dxcc: Value(dxcc),
      name: Value(name),
      prefix: Value(prefix),
      cqz: Value(cqz),
      ituz: Value(ituz),
      cont: Value(cont),
      lat: Value(lat),
      lon: Value(lon),
      deleted: Value(deleted),
    );
  }

  factory DxccEntityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DxccEntityRow(
      dxcc: serializer.fromJson<int>(json['dxcc']),
      name: serializer.fromJson<String>(json['name']),
      prefix: serializer.fromJson<String>(json['prefix']),
      cqz: serializer.fromJson<int>(json['cqz']),
      ituz: serializer.fromJson<int>(json['ituz']),
      cont: serializer.fromJson<String>(json['cont']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dxcc': serializer.toJson<int>(dxcc),
      'name': serializer.toJson<String>(name),
      'prefix': serializer.toJson<String>(prefix),
      'cqz': serializer.toJson<int>(cqz),
      'ituz': serializer.toJson<int>(ituz),
      'cont': serializer.toJson<String>(cont),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  DxccEntityRow copyWith({
    int? dxcc,
    String? name,
    String? prefix,
    int? cqz,
    int? ituz,
    String? cont,
    double? lat,
    double? lon,
    bool? deleted,
  }) => DxccEntityRow(
    dxcc: dxcc ?? this.dxcc,
    name: name ?? this.name,
    prefix: prefix ?? this.prefix,
    cqz: cqz ?? this.cqz,
    ituz: ituz ?? this.ituz,
    cont: cont ?? this.cont,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    deleted: deleted ?? this.deleted,
  );
  DxccEntityRow copyWithCompanion(DxccEntitiesCompanion data) {
    return DxccEntityRow(
      dxcc: data.dxcc.present ? data.dxcc.value : this.dxcc,
      name: data.name.present ? data.name.value : this.name,
      prefix: data.prefix.present ? data.prefix.value : this.prefix,
      cqz: data.cqz.present ? data.cqz.value : this.cqz,
      ituz: data.ituz.present ? data.ituz.value : this.ituz,
      cont: data.cont.present ? data.cont.value : this.cont,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DxccEntityRow(')
          ..write('dxcc: $dxcc, ')
          ..write('name: $name, ')
          ..write('prefix: $prefix, ')
          ..write('cqz: $cqz, ')
          ..write('ituz: $ituz, ')
          ..write('cont: $cont, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(dxcc, name, prefix, cqz, ituz, cont, lat, lon, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DxccEntityRow &&
          other.dxcc == this.dxcc &&
          other.name == this.name &&
          other.prefix == this.prefix &&
          other.cqz == this.cqz &&
          other.ituz == this.ituz &&
          other.cont == this.cont &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.deleted == this.deleted);
}

class DxccEntitiesCompanion extends UpdateCompanion<DxccEntityRow> {
  final Value<int> dxcc;
  final Value<String> name;
  final Value<String> prefix;
  final Value<int> cqz;
  final Value<int> ituz;
  final Value<String> cont;
  final Value<double> lat;
  final Value<double> lon;
  final Value<bool> deleted;
  const DxccEntitiesCompanion({
    this.dxcc = const Value.absent(),
    this.name = const Value.absent(),
    this.prefix = const Value.absent(),
    this.cqz = const Value.absent(),
    this.ituz = const Value.absent(),
    this.cont = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  DxccEntitiesCompanion.insert({
    this.dxcc = const Value.absent(),
    required String name,
    required String prefix,
    required int cqz,
    required int ituz,
    required String cont,
    required double lat,
    required double lon,
    this.deleted = const Value.absent(),
  }) : name = Value(name),
       prefix = Value(prefix),
       cqz = Value(cqz),
       ituz = Value(ituz),
       cont = Value(cont),
       lat = Value(lat),
       lon = Value(lon);
  static Insertable<DxccEntityRow> custom({
    Expression<int>? dxcc,
    Expression<String>? name,
    Expression<String>? prefix,
    Expression<int>? cqz,
    Expression<int>? ituz,
    Expression<String>? cont,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (dxcc != null) 'dxcc': dxcc,
      if (name != null) 'name': name,
      if (prefix != null) 'prefix': prefix,
      if (cqz != null) 'cqz': cqz,
      if (ituz != null) 'ituz': ituz,
      if (cont != null) 'cont': cont,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (deleted != null) 'deleted': deleted,
    });
  }

  DxccEntitiesCompanion copyWith({
    Value<int>? dxcc,
    Value<String>? name,
    Value<String>? prefix,
    Value<int>? cqz,
    Value<int>? ituz,
    Value<String>? cont,
    Value<double>? lat,
    Value<double>? lon,
    Value<bool>? deleted,
  }) {
    return DxccEntitiesCompanion(
      dxcc: dxcc ?? this.dxcc,
      name: name ?? this.name,
      prefix: prefix ?? this.prefix,
      cqz: cqz ?? this.cqz,
      ituz: ituz ?? this.ituz,
      cont: cont ?? this.cont,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dxcc.present) {
      map['dxcc'] = Variable<int>(dxcc.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (prefix.present) {
      map['prefix'] = Variable<String>(prefix.value);
    }
    if (cqz.present) {
      map['cqz'] = Variable<int>(cqz.value);
    }
    if (ituz.present) {
      map['ituz'] = Variable<int>(ituz.value);
    }
    if (cont.present) {
      map['cont'] = Variable<String>(cont.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DxccEntitiesCompanion(')
          ..write('dxcc: $dxcc, ')
          ..write('name: $name, ')
          ..write('prefix: $prefix, ')
          ..write('cqz: $cqz, ')
          ..write('ituz: $ituz, ')
          ..write('cont: $cont, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $DxccPrefixesTable extends DxccPrefixes
    with TableInfo<$DxccPrefixesTable, DxccPrefixRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DxccPrefixesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prefixOrCallMeta = const VerificationMeta(
    'prefixOrCall',
  );
  @override
  late final GeneratedColumn<String> prefixOrCall = GeneratedColumn<String>(
    'prefix_or_call',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exactMeta = const VerificationMeta('exact');
  @override
  late final GeneratedColumn<bool> exact = GeneratedColumn<bool>(
    'exact',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exact" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dxccMeta = const VerificationMeta('dxcc');
  @override
  late final GeneratedColumn<int> dxcc = GeneratedColumn<int>(
    'dxcc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dxcc_entities (dxcc)',
    ),
  );
  static const VerificationMeta _cqzOverrideMeta = const VerificationMeta(
    'cqzOverride',
  );
  @override
  late final GeneratedColumn<int> cqzOverride = GeneratedColumn<int>(
    'cqz_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ituzOverrideMeta = const VerificationMeta(
    'ituzOverride',
  );
  @override
  late final GeneratedColumn<int> ituzOverride = GeneratedColumn<int>(
    'ituz_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    prefixOrCall,
    exact,
    dxcc,
    cqzOverride,
    ituzOverride,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dxcc_prefixes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DxccPrefixRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prefix_or_call')) {
      context.handle(
        _prefixOrCallMeta,
        prefixOrCall.isAcceptableOrUnknown(
          data['prefix_or_call']!,
          _prefixOrCallMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prefixOrCallMeta);
    }
    if (data.containsKey('exact')) {
      context.handle(
        _exactMeta,
        exact.isAcceptableOrUnknown(data['exact']!, _exactMeta),
      );
    } else if (isInserting) {
      context.missing(_exactMeta);
    }
    if (data.containsKey('dxcc')) {
      context.handle(
        _dxccMeta,
        dxcc.isAcceptableOrUnknown(data['dxcc']!, _dxccMeta),
      );
    } else if (isInserting) {
      context.missing(_dxccMeta);
    }
    if (data.containsKey('cqz_override')) {
      context.handle(
        _cqzOverrideMeta,
        cqzOverride.isAcceptableOrUnknown(
          data['cqz_override']!,
          _cqzOverrideMeta,
        ),
      );
    }
    if (data.containsKey('ituz_override')) {
      context.handle(
        _ituzOverrideMeta,
        ituzOverride.isAcceptableOrUnknown(
          data['ituz_override']!,
          _ituzOverrideMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prefixOrCall, exact};
  @override
  DxccPrefixRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DxccPrefixRow(
      prefixOrCall: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prefix_or_call'],
      )!,
      exact: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exact'],
      )!,
      dxcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dxcc'],
      )!,
      cqzOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cqz_override'],
      ),
      ituzOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ituz_override'],
      ),
    );
  }

  @override
  $DxccPrefixesTable createAlias(String alias) {
    return $DxccPrefixesTable(attachedDatabase, alias);
  }
}

class DxccPrefixRow extends DataClass implements Insertable<DxccPrefixRow> {
  final String prefixOrCall;

  /// True for full-callsign exceptions (`=CALL` in cty.dat).
  final bool exact;
  final int dxcc;
  final int? cqzOverride;
  final int? ituzOverride;
  const DxccPrefixRow({
    required this.prefixOrCall,
    required this.exact,
    required this.dxcc,
    this.cqzOverride,
    this.ituzOverride,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prefix_or_call'] = Variable<String>(prefixOrCall);
    map['exact'] = Variable<bool>(exact);
    map['dxcc'] = Variable<int>(dxcc);
    if (!nullToAbsent || cqzOverride != null) {
      map['cqz_override'] = Variable<int>(cqzOverride);
    }
    if (!nullToAbsent || ituzOverride != null) {
      map['ituz_override'] = Variable<int>(ituzOverride);
    }
    return map;
  }

  DxccPrefixesCompanion toCompanion(bool nullToAbsent) {
    return DxccPrefixesCompanion(
      prefixOrCall: Value(prefixOrCall),
      exact: Value(exact),
      dxcc: Value(dxcc),
      cqzOverride: cqzOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(cqzOverride),
      ituzOverride: ituzOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(ituzOverride),
    );
  }

  factory DxccPrefixRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DxccPrefixRow(
      prefixOrCall: serializer.fromJson<String>(json['prefixOrCall']),
      exact: serializer.fromJson<bool>(json['exact']),
      dxcc: serializer.fromJson<int>(json['dxcc']),
      cqzOverride: serializer.fromJson<int?>(json['cqzOverride']),
      ituzOverride: serializer.fromJson<int?>(json['ituzOverride']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prefixOrCall': serializer.toJson<String>(prefixOrCall),
      'exact': serializer.toJson<bool>(exact),
      'dxcc': serializer.toJson<int>(dxcc),
      'cqzOverride': serializer.toJson<int?>(cqzOverride),
      'ituzOverride': serializer.toJson<int?>(ituzOverride),
    };
  }

  DxccPrefixRow copyWith({
    String? prefixOrCall,
    bool? exact,
    int? dxcc,
    Value<int?> cqzOverride = const Value.absent(),
    Value<int?> ituzOverride = const Value.absent(),
  }) => DxccPrefixRow(
    prefixOrCall: prefixOrCall ?? this.prefixOrCall,
    exact: exact ?? this.exact,
    dxcc: dxcc ?? this.dxcc,
    cqzOverride: cqzOverride.present ? cqzOverride.value : this.cqzOverride,
    ituzOverride: ituzOverride.present ? ituzOverride.value : this.ituzOverride,
  );
  DxccPrefixRow copyWithCompanion(DxccPrefixesCompanion data) {
    return DxccPrefixRow(
      prefixOrCall: data.prefixOrCall.present
          ? data.prefixOrCall.value
          : this.prefixOrCall,
      exact: data.exact.present ? data.exact.value : this.exact,
      dxcc: data.dxcc.present ? data.dxcc.value : this.dxcc,
      cqzOverride: data.cqzOverride.present
          ? data.cqzOverride.value
          : this.cqzOverride,
      ituzOverride: data.ituzOverride.present
          ? data.ituzOverride.value
          : this.ituzOverride,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DxccPrefixRow(')
          ..write('prefixOrCall: $prefixOrCall, ')
          ..write('exact: $exact, ')
          ..write('dxcc: $dxcc, ')
          ..write('cqzOverride: $cqzOverride, ')
          ..write('ituzOverride: $ituzOverride')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(prefixOrCall, exact, dxcc, cqzOverride, ituzOverride);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DxccPrefixRow &&
          other.prefixOrCall == this.prefixOrCall &&
          other.exact == this.exact &&
          other.dxcc == this.dxcc &&
          other.cqzOverride == this.cqzOverride &&
          other.ituzOverride == this.ituzOverride);
}

class DxccPrefixesCompanion extends UpdateCompanion<DxccPrefixRow> {
  final Value<String> prefixOrCall;
  final Value<bool> exact;
  final Value<int> dxcc;
  final Value<int?> cqzOverride;
  final Value<int?> ituzOverride;
  final Value<int> rowid;
  const DxccPrefixesCompanion({
    this.prefixOrCall = const Value.absent(),
    this.exact = const Value.absent(),
    this.dxcc = const Value.absent(),
    this.cqzOverride = const Value.absent(),
    this.ituzOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DxccPrefixesCompanion.insert({
    required String prefixOrCall,
    required bool exact,
    required int dxcc,
    this.cqzOverride = const Value.absent(),
    this.ituzOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : prefixOrCall = Value(prefixOrCall),
       exact = Value(exact),
       dxcc = Value(dxcc);
  static Insertable<DxccPrefixRow> custom({
    Expression<String>? prefixOrCall,
    Expression<bool>? exact,
    Expression<int>? dxcc,
    Expression<int>? cqzOverride,
    Expression<int>? ituzOverride,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prefixOrCall != null) 'prefix_or_call': prefixOrCall,
      if (exact != null) 'exact': exact,
      if (dxcc != null) 'dxcc': dxcc,
      if (cqzOverride != null) 'cqz_override': cqzOverride,
      if (ituzOverride != null) 'ituz_override': ituzOverride,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DxccPrefixesCompanion copyWith({
    Value<String>? prefixOrCall,
    Value<bool>? exact,
    Value<int>? dxcc,
    Value<int?>? cqzOverride,
    Value<int?>? ituzOverride,
    Value<int>? rowid,
  }) {
    return DxccPrefixesCompanion(
      prefixOrCall: prefixOrCall ?? this.prefixOrCall,
      exact: exact ?? this.exact,
      dxcc: dxcc ?? this.dxcc,
      cqzOverride: cqzOverride ?? this.cqzOverride,
      ituzOverride: ituzOverride ?? this.ituzOverride,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prefixOrCall.present) {
      map['prefix_or_call'] = Variable<String>(prefixOrCall.value);
    }
    if (exact.present) {
      map['exact'] = Variable<bool>(exact.value);
    }
    if (dxcc.present) {
      map['dxcc'] = Variable<int>(dxcc.value);
    }
    if (cqzOverride.present) {
      map['cqz_override'] = Variable<int>(cqzOverride.value);
    }
    if (ituzOverride.present) {
      map['ituz_override'] = Variable<int>(ituzOverride.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DxccPrefixesCompanion(')
          ..write('prefixOrCall: $prefixOrCall, ')
          ..write('exact: $exact, ')
          ..write('dxcc: $dxcc, ')
          ..write('cqzOverride: $cqzOverride, ')
          ..write('ituzOverride: $ituzOverride, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgramReferencesTable extends ProgramReferences
    with TableInfo<$ProgramReferencesTable, ProgramReferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _programMeta = const VerificationMeta(
    'program',
  );
  @override
  late final GeneratedColumn<String> program = GeneratedColumn<String>(
    'program',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validFromMeta = const VerificationMeta(
    'validFrom',
  );
  @override
  late final GeneratedColumn<int> validFrom = GeneratedColumn<int>(
    'valid_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validToMeta = const VerificationMeta(
    'validTo',
  );
  @override
  late final GeneratedColumn<int> validTo = GeneratedColumn<int>(
    'valid_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    program,
    ref,
    name,
    region,
    lat,
    lon,
    validFrom,
    validTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'program_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramReferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('program')) {
      context.handle(
        _programMeta,
        program.isAcceptableOrUnknown(data['program']!, _programMeta),
      );
    } else if (isInserting) {
      context.missing(_programMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    }
    if (data.containsKey('valid_to')) {
      context.handle(
        _validToMeta,
        validTo.isAcceptableOrUnknown(data['valid_to']!, _validToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {program, ref};
  @override
  ProgramReferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramReferenceRow(
      program: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valid_from'],
      ),
      validTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valid_to'],
      ),
    );
  }

  @override
  $ProgramReferencesTable createAlias(String alias) {
    return $ProgramReferencesTable(attachedDatabase, alias);
  }
}

class ProgramReferenceRow extends DataClass
    implements Insertable<ProgramReferenceRow> {
  final String program;
  final String ref;
  final String name;
  final String? region;
  final double? lat;
  final double? lon;
  final int? validFrom;
  final int? validTo;
  const ProgramReferenceRow({
    required this.program,
    required this.ref,
    required this.name,
    this.region,
    this.lat,
    this.lon,
    this.validFrom,
    this.validTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['program'] = Variable<String>(program);
    map['ref'] = Variable<String>(ref);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    if (!nullToAbsent || validFrom != null) {
      map['valid_from'] = Variable<int>(validFrom);
    }
    if (!nullToAbsent || validTo != null) {
      map['valid_to'] = Variable<int>(validTo);
    }
    return map;
  }

  ProgramReferencesCompanion toCompanion(bool nullToAbsent) {
    return ProgramReferencesCompanion(
      program: Value(program),
      ref: Value(ref),
      name: Value(name),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      validFrom: validFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(validFrom),
      validTo: validTo == null && nullToAbsent
          ? const Value.absent()
          : Value(validTo),
    );
  }

  factory ProgramReferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramReferenceRow(
      program: serializer.fromJson<String>(json['program']),
      ref: serializer.fromJson<String>(json['ref']),
      name: serializer.fromJson<String>(json['name']),
      region: serializer.fromJson<String?>(json['region']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      validFrom: serializer.fromJson<int?>(json['validFrom']),
      validTo: serializer.fromJson<int?>(json['validTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'program': serializer.toJson<String>(program),
      'ref': serializer.toJson<String>(ref),
      'name': serializer.toJson<String>(name),
      'region': serializer.toJson<String?>(region),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'validFrom': serializer.toJson<int?>(validFrom),
      'validTo': serializer.toJson<int?>(validTo),
    };
  }

  ProgramReferenceRow copyWith({
    String? program,
    String? ref,
    String? name,
    Value<String?> region = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    Value<int?> validFrom = const Value.absent(),
    Value<int?> validTo = const Value.absent(),
  }) => ProgramReferenceRow(
    program: program ?? this.program,
    ref: ref ?? this.ref,
    name: name ?? this.name,
    region: region.present ? region.value : this.region,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    validFrom: validFrom.present ? validFrom.value : this.validFrom,
    validTo: validTo.present ? validTo.value : this.validTo,
  );
  ProgramReferenceRow copyWithCompanion(ProgramReferencesCompanion data) {
    return ProgramReferenceRow(
      program: data.program.present ? data.program.value : this.program,
      ref: data.ref.present ? data.ref.value : this.ref,
      name: data.name.present ? data.name.value : this.name,
      region: data.region.present ? data.region.value : this.region,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      validTo: data.validTo.present ? data.validTo.value : this.validTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramReferenceRow(')
          ..write('program: $program, ')
          ..write('ref: $ref, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(program, ref, name, region, lat, lon, validFrom, validTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramReferenceRow &&
          other.program == this.program &&
          other.ref == this.ref &&
          other.name == this.name &&
          other.region == this.region &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.validFrom == this.validFrom &&
          other.validTo == this.validTo);
}

class ProgramReferencesCompanion extends UpdateCompanion<ProgramReferenceRow> {
  final Value<String> program;
  final Value<String> ref;
  final Value<String> name;
  final Value<String?> region;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<int?> validFrom;
  final Value<int?> validTo;
  final Value<int> rowid;
  const ProgramReferencesCompanion({
    this.program = const Value.absent(),
    this.ref = const Value.absent(),
    this.name = const Value.absent(),
    this.region = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgramReferencesCompanion.insert({
    required String program,
    required String ref,
    required String name,
    this.region = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validTo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : program = Value(program),
       ref = Value(ref),
       name = Value(name);
  static Insertable<ProgramReferenceRow> custom({
    Expression<String>? program,
    Expression<String>? ref,
    Expression<String>? name,
    Expression<String>? region,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? validFrom,
    Expression<int>? validTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (program != null) 'program': program,
      if (ref != null) 'ref': ref,
      if (name != null) 'name': name,
      if (region != null) 'region': region,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (validFrom != null) 'valid_from': validFrom,
      if (validTo != null) 'valid_to': validTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgramReferencesCompanion copyWith({
    Value<String>? program,
    Value<String>? ref,
    Value<String>? name,
    Value<String?>? region,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<int?>? validFrom,
    Value<int?>? validTo,
    Value<int>? rowid,
  }) {
    return ProgramReferencesCompanion(
      program: program ?? this.program,
      ref: ref ?? this.ref,
      name: name ?? this.name,
      region: region ?? this.region,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (program.present) {
      map['program'] = Variable<String>(program.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<int>(validFrom.value);
    }
    if (validTo.present) {
      map['valid_to'] = Variable<int>(validTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramReferencesCompanion(')
          ..write('program: $program, ')
          ..write('ref: $ref, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScpCallsTable extends ScpCalls
    with TableInfo<$ScpCallsTable, ScpCallRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScpCallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _callMeta = const VerificationMeta('call');
  @override
  late final GeneratedColumn<String> call = GeneratedColumn<String>(
    'call',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [call];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scp_calls';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScpCallRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('call')) {
      context.handle(
        _callMeta,
        call.isAcceptableOrUnknown(data['call']!, _callMeta),
      );
    } else if (isInserting) {
      context.missing(_callMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {call};
  @override
  ScpCallRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScpCallRow(
      call: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call'],
      )!,
    );
  }

  @override
  $ScpCallsTable createAlias(String alias) {
    return $ScpCallsTable(attachedDatabase, alias);
  }
}

class ScpCallRow extends DataClass implements Insertable<ScpCallRow> {
  final String call;
  const ScpCallRow({required this.call});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['call'] = Variable<String>(call);
    return map;
  }

  ScpCallsCompanion toCompanion(bool nullToAbsent) {
    return ScpCallsCompanion(call: Value(call));
  }

  factory ScpCallRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScpCallRow(call: serializer.fromJson<String>(json['call']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'call': serializer.toJson<String>(call)};
  }

  ScpCallRow copyWith({String? call}) => ScpCallRow(call: call ?? this.call);
  ScpCallRow copyWithCompanion(ScpCallsCompanion data) {
    return ScpCallRow(call: data.call.present ? data.call.value : this.call);
  }

  @override
  String toString() {
    return (StringBuffer('ScpCallRow(')
          ..write('call: $call')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => call.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScpCallRow && other.call == this.call);
}

class ScpCallsCompanion extends UpdateCompanion<ScpCallRow> {
  final Value<String> call;
  final Value<int> rowid;
  const ScpCallsCompanion({
    this.call = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScpCallsCompanion.insert({
    required String call,
    this.rowid = const Value.absent(),
  }) : call = Value(call);
  static Insertable<ScpCallRow> custom({
    Expression<String>? call,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (call != null) 'call': call,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScpCallsCompanion copyWith({Value<String>? call, Value<int>? rowid}) {
    return ScpCallsCompanion(
      call: call ?? this.call,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (call.present) {
      map['call'] = Variable<String>(call.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScpCallsCompanion(')
          ..write('call: $call, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkedBeforeTable extends WorkedBefore
    with TableInfo<$WorkedBeforeTable, WorkedBeforeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkedBeforeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _callMeta = const VerificationMeta('call');
  @override
  late final GeneratedColumn<String> call = GeneratedColumn<String>(
    'call',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bandMeta = const VerificationMeta('band');
  @override
  late final GeneratedColumn<String> band = GeneratedColumn<String>(
    'band',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dxccMeta = const VerificationMeta('dxcc');
  @override
  late final GeneratedColumn<int> dxcc = GeneratedColumn<int>(
    'dxcc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gridsquareMeta = const VerificationMeta(
    'gridsquare',
  );
  @override
  late final GeneratedColumn<String> gridsquare = GeneratedColumn<String>(
    'gridsquare',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstTimeMeta = const VerificationMeta(
    'firstTime',
  );
  @override
  late final GeneratedColumn<int> firstTime = GeneratedColumn<int>(
    'first_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    call,
    band,
    mode,
    dxcc,
    gridsquare,
    firstTime,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worked_before';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkedBeforeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('call')) {
      context.handle(
        _callMeta,
        call.isAcceptableOrUnknown(data['call']!, _callMeta),
      );
    } else if (isInserting) {
      context.missing(_callMeta);
    }
    if (data.containsKey('band')) {
      context.handle(
        _bandMeta,
        band.isAcceptableOrUnknown(data['band']!, _bandMeta),
      );
    } else if (isInserting) {
      context.missing(_bandMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('dxcc')) {
      context.handle(
        _dxccMeta,
        dxcc.isAcceptableOrUnknown(data['dxcc']!, _dxccMeta),
      );
    }
    if (data.containsKey('gridsquare')) {
      context.handle(
        _gridsquareMeta,
        gridsquare.isAcceptableOrUnknown(data['gridsquare']!, _gridsquareMeta),
      );
    }
    if (data.containsKey('first_time')) {
      context.handle(
        _firstTimeMeta,
        firstTime.isAcceptableOrUnknown(data['first_time']!, _firstTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_firstTimeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, call, band, mode};
  @override
  WorkedBeforeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkedBeforeRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      call: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call'],
      )!,
      band: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}band'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      dxcc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dxcc'],
      ),
      gridsquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gridsquare'],
      ),
      firstTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_time'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $WorkedBeforeTable createAlias(String alias) {
    return $WorkedBeforeTable(attachedDatabase, alias);
  }
}

class WorkedBeforeRow extends DataClass implements Insertable<WorkedBeforeRow> {
  final String accountId;
  final String call;
  final String band;
  final String mode;
  final int? dxcc;
  final String? gridsquare;
  final int firstTime;

  /// `server` or `local`.
  final String source;
  const WorkedBeforeRow({
    required this.accountId,
    required this.call,
    required this.band,
    required this.mode,
    this.dxcc,
    this.gridsquare,
    required this.firstTime,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['call'] = Variable<String>(call);
    map['band'] = Variable<String>(band);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || dxcc != null) {
      map['dxcc'] = Variable<int>(dxcc);
    }
    if (!nullToAbsent || gridsquare != null) {
      map['gridsquare'] = Variable<String>(gridsquare);
    }
    map['first_time'] = Variable<int>(firstTime);
    map['source'] = Variable<String>(source);
    return map;
  }

  WorkedBeforeCompanion toCompanion(bool nullToAbsent) {
    return WorkedBeforeCompanion(
      accountId: Value(accountId),
      call: Value(call),
      band: Value(band),
      mode: Value(mode),
      dxcc: dxcc == null && nullToAbsent ? const Value.absent() : Value(dxcc),
      gridsquare: gridsquare == null && nullToAbsent
          ? const Value.absent()
          : Value(gridsquare),
      firstTime: Value(firstTime),
      source: Value(source),
    );
  }

  factory WorkedBeforeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkedBeforeRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      call: serializer.fromJson<String>(json['call']),
      band: serializer.fromJson<String>(json['band']),
      mode: serializer.fromJson<String>(json['mode']),
      dxcc: serializer.fromJson<int?>(json['dxcc']),
      gridsquare: serializer.fromJson<String?>(json['gridsquare']),
      firstTime: serializer.fromJson<int>(json['firstTime']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'call': serializer.toJson<String>(call),
      'band': serializer.toJson<String>(band),
      'mode': serializer.toJson<String>(mode),
      'dxcc': serializer.toJson<int?>(dxcc),
      'gridsquare': serializer.toJson<String?>(gridsquare),
      'firstTime': serializer.toJson<int>(firstTime),
      'source': serializer.toJson<String>(source),
    };
  }

  WorkedBeforeRow copyWith({
    String? accountId,
    String? call,
    String? band,
    String? mode,
    Value<int?> dxcc = const Value.absent(),
    Value<String?> gridsquare = const Value.absent(),
    int? firstTime,
    String? source,
  }) => WorkedBeforeRow(
    accountId: accountId ?? this.accountId,
    call: call ?? this.call,
    band: band ?? this.band,
    mode: mode ?? this.mode,
    dxcc: dxcc.present ? dxcc.value : this.dxcc,
    gridsquare: gridsquare.present ? gridsquare.value : this.gridsquare,
    firstTime: firstTime ?? this.firstTime,
    source: source ?? this.source,
  );
  WorkedBeforeRow copyWithCompanion(WorkedBeforeCompanion data) {
    return WorkedBeforeRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      call: data.call.present ? data.call.value : this.call,
      band: data.band.present ? data.band.value : this.band,
      mode: data.mode.present ? data.mode.value : this.mode,
      dxcc: data.dxcc.present ? data.dxcc.value : this.dxcc,
      gridsquare: data.gridsquare.present
          ? data.gridsquare.value
          : this.gridsquare,
      firstTime: data.firstTime.present ? data.firstTime.value : this.firstTime,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkedBeforeRow(')
          ..write('accountId: $accountId, ')
          ..write('call: $call, ')
          ..write('band: $band, ')
          ..write('mode: $mode, ')
          ..write('dxcc: $dxcc, ')
          ..write('gridsquare: $gridsquare, ')
          ..write('firstTime: $firstTime, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    call,
    band,
    mode,
    dxcc,
    gridsquare,
    firstTime,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkedBeforeRow &&
          other.accountId == this.accountId &&
          other.call == this.call &&
          other.band == this.band &&
          other.mode == this.mode &&
          other.dxcc == this.dxcc &&
          other.gridsquare == this.gridsquare &&
          other.firstTime == this.firstTime &&
          other.source == this.source);
}

class WorkedBeforeCompanion extends UpdateCompanion<WorkedBeforeRow> {
  final Value<String> accountId;
  final Value<String> call;
  final Value<String> band;
  final Value<String> mode;
  final Value<int?> dxcc;
  final Value<String?> gridsquare;
  final Value<int> firstTime;
  final Value<String> source;
  final Value<int> rowid;
  const WorkedBeforeCompanion({
    this.accountId = const Value.absent(),
    this.call = const Value.absent(),
    this.band = const Value.absent(),
    this.mode = const Value.absent(),
    this.dxcc = const Value.absent(),
    this.gridsquare = const Value.absent(),
    this.firstTime = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkedBeforeCompanion.insert({
    required String accountId,
    required String call,
    required String band,
    required String mode,
    this.dxcc = const Value.absent(),
    this.gridsquare = const Value.absent(),
    required int firstTime,
    required String source,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       call = Value(call),
       band = Value(band),
       mode = Value(mode),
       firstTime = Value(firstTime),
       source = Value(source);
  static Insertable<WorkedBeforeRow> custom({
    Expression<String>? accountId,
    Expression<String>? call,
    Expression<String>? band,
    Expression<String>? mode,
    Expression<int>? dxcc,
    Expression<String>? gridsquare,
    Expression<int>? firstTime,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (call != null) 'call': call,
      if (band != null) 'band': band,
      if (mode != null) 'mode': mode,
      if (dxcc != null) 'dxcc': dxcc,
      if (gridsquare != null) 'gridsquare': gridsquare,
      if (firstTime != null) 'first_time': firstTime,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkedBeforeCompanion copyWith({
    Value<String>? accountId,
    Value<String>? call,
    Value<String>? band,
    Value<String>? mode,
    Value<int?>? dxcc,
    Value<String?>? gridsquare,
    Value<int>? firstTime,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return WorkedBeforeCompanion(
      accountId: accountId ?? this.accountId,
      call: call ?? this.call,
      band: band ?? this.band,
      mode: mode ?? this.mode,
      dxcc: dxcc ?? this.dxcc,
      gridsquare: gridsquare ?? this.gridsquare,
      firstTime: firstTime ?? this.firstTime,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (call.present) {
      map['call'] = Variable<String>(call.value);
    }
    if (band.present) {
      map['band'] = Variable<String>(band.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (dxcc.present) {
      map['dxcc'] = Variable<int>(dxcc.value);
    }
    if (gridsquare.present) {
      map['gridsquare'] = Variable<String>(gridsquare.value);
    }
    if (firstTime.present) {
      map['first_time'] = Variable<int>(firstTime.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkedBeforeCompanion(')
          ..write('accountId: $accountId, ')
          ..write('call: $call, ')
          ..write('band: $band, ')
          ..write('mode: $mode, ')
          ..write('dxcc: $dxcc, ')
          ..write('gridsquare: $gridsquare, ')
          ..write('firstTime: $firstTime, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, DeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtMeta = const VerificationMeta(
    'pairedAt',
  );
  @override
  late final GeneratedColumn<int> pairedAt = GeneratedColumn<int>(
    'paired_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<int> revokedAt = GeneratedColumn<int>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    publicKey,
    pairedAt,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('paired_at')) {
      context.handle(
        _pairedAtMeta,
        pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pairedAtMeta);
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      pairedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paired_at'],
      )!,
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revoked_at'],
      ),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class DeviceRow extends DataClass implements Insertable<DeviceRow> {
  final String id;
  final String name;
  final String publicKey;
  final int pairedAt;
  final int? revokedAt;
  const DeviceRow({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.pairedAt,
    this.revokedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['public_key'] = Variable<String>(publicKey);
    map['paired_at'] = Variable<int>(pairedAt);
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<int>(revokedAt);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      publicKey: Value(publicKey),
      pairedAt: Value(pairedAt),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
    );
  }

  factory DeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      pairedAt: serializer.fromJson<int>(json['pairedAt']),
      revokedAt: serializer.fromJson<int?>(json['revokedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'publicKey': serializer.toJson<String>(publicKey),
      'pairedAt': serializer.toJson<int>(pairedAt),
      'revokedAt': serializer.toJson<int?>(revokedAt),
    };
  }

  DeviceRow copyWith({
    String? id,
    String? name,
    String? publicKey,
    int? pairedAt,
    Value<int?> revokedAt = const Value.absent(),
  }) => DeviceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    publicKey: publicKey ?? this.publicKey,
    pairedAt: pairedAt ?? this.pairedAt,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
  );
  DeviceRow copyWithCompanion(DevicesCompanion data) {
    return DeviceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('publicKey: $publicKey, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, publicKey, pairedAt, revokedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.publicKey == this.publicKey &&
          other.pairedAt == this.pairedAt &&
          other.revokedAt == this.revokedAt);
}

class DevicesCompanion extends UpdateCompanion<DeviceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> publicKey;
  final Value<int> pairedAt;
  final Value<int?> revokedAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String name,
    required String publicKey,
    required int pairedAt,
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       publicKey = Value(publicKey),
       pairedAt = Value(pairedAt);
  static Insertable<DeviceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? publicKey,
    Expression<int>? pairedAt,
    Expression<int>? revokedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (publicKey != null) 'public_key': publicKey,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? publicKey,
    Value<int>? pairedAt,
    Value<int?>? revokedAt,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      pairedAt: pairedAt ?? this.pairedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<int>(pairedAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<int>(revokedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('publicKey: $publicKey, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeerCursorsTable extends PeerCursors
    with TableInfo<$PeerCursorsTable, PeerCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeerCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _lastHlcMeta = const VerificationMeta(
    'lastHlc',
  );
  @override
  late final GeneratedColumn<String> lastHlc = GeneratedColumn<String>(
    'last_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deviceId, lastHlc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'peer_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeerCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_hlc')) {
      context.handle(
        _lastHlcMeta,
        lastHlc.isAcceptableOrUnknown(data['last_hlc']!, _lastHlcMeta),
      );
    } else if (isInserting) {
      context.missing(_lastHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  PeerCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeerCursorRow(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      lastHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_hlc'],
      )!,
    );
  }

  @override
  $PeerCursorsTable createAlias(String alias) {
    return $PeerCursorsTable(attachedDatabase, alias);
  }
}

class PeerCursorRow extends DataClass implements Insertable<PeerCursorRow> {
  final String deviceId;
  final String lastHlc;
  const PeerCursorRow({required this.deviceId, required this.lastHlc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['last_hlc'] = Variable<String>(lastHlc);
    return map;
  }

  PeerCursorsCompanion toCompanion(bool nullToAbsent) {
    return PeerCursorsCompanion(
      deviceId: Value(deviceId),
      lastHlc: Value(lastHlc),
    );
  }

  factory PeerCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeerCursorRow(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastHlc: serializer.fromJson<String>(json['lastHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'lastHlc': serializer.toJson<String>(lastHlc),
    };
  }

  PeerCursorRow copyWith({String? deviceId, String? lastHlc}) => PeerCursorRow(
    deviceId: deviceId ?? this.deviceId,
    lastHlc: lastHlc ?? this.lastHlc,
  );
  PeerCursorRow copyWithCompanion(PeerCursorsCompanion data) {
    return PeerCursorRow(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastHlc: data.lastHlc.present ? data.lastHlc.value : this.lastHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeerCursorRow(')
          ..write('deviceId: $deviceId, ')
          ..write('lastHlc: $lastHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, lastHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeerCursorRow &&
          other.deviceId == this.deviceId &&
          other.lastHlc == this.lastHlc);
}

class PeerCursorsCompanion extends UpdateCompanion<PeerCursorRow> {
  final Value<String> deviceId;
  final Value<String> lastHlc;
  final Value<int> rowid;
  const PeerCursorsCompanion({
    this.deviceId = const Value.absent(),
    this.lastHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeerCursorsCompanion.insert({
    required String deviceId,
    required String lastHlc,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       lastHlc = Value(lastHlc);
  static Insertable<PeerCursorRow> custom({
    Expression<String>? deviceId,
    Expression<String>? lastHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (lastHlc != null) 'last_hlc': lastHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeerCursorsCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? lastHlc,
    Value<int>? rowid,
  }) {
    return PeerCursorsCompanion(
      deviceId: deviceId ?? this.deviceId,
      lastHlc: lastHlc ?? this.lastHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastHlc.present) {
      map['last_hlc'] = Variable<String>(lastHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeerCursorsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('lastHlc: $lastHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShortcutBindingsTable extends ShortcutBindings
    with TableInfo<$ShortcutBindingsTable, ShortcutBindingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShortcutBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  @override
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bindingMeta = const VerificationMeta(
    'binding',
  );
  @override
  late final GeneratedColumn<String> binding = GeneratedColumn<String>(
    'binding',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [commandId, platform, binding];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shortcut_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShortcutBindingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('binding')) {
      context.handle(
        _bindingMeta,
        binding.isAcceptableOrUnknown(data['binding']!, _bindingMeta),
      );
    } else if (isInserting) {
      context.missing(_bindingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {commandId, platform};
  @override
  ShortcutBindingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShortcutBindingRow(
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      binding: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}binding'],
      )!,
    );
  }

  @override
  $ShortcutBindingsTable createAlias(String alias) {
    return $ShortcutBindingsTable(attachedDatabase, alias);
  }
}

class ShortcutBindingRow extends DataClass
    implements Insertable<ShortcutBindingRow> {
  final String commandId;

  /// `apple`, `other` or `all`.
  final String platform;

  /// Serialised key combination, or empty to unbind.
  final String binding;
  const ShortcutBindingRow({
    required this.commandId,
    required this.platform,
    required this.binding,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['command_id'] = Variable<String>(commandId);
    map['platform'] = Variable<String>(platform);
    map['binding'] = Variable<String>(binding);
    return map;
  }

  ShortcutBindingsCompanion toCompanion(bool nullToAbsent) {
    return ShortcutBindingsCompanion(
      commandId: Value(commandId),
      platform: Value(platform),
      binding: Value(binding),
    );
  }

  factory ShortcutBindingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShortcutBindingRow(
      commandId: serializer.fromJson<String>(json['commandId']),
      platform: serializer.fromJson<String>(json['platform']),
      binding: serializer.fromJson<String>(json['binding']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'commandId': serializer.toJson<String>(commandId),
      'platform': serializer.toJson<String>(platform),
      'binding': serializer.toJson<String>(binding),
    };
  }

  ShortcutBindingRow copyWith({
    String? commandId,
    String? platform,
    String? binding,
  }) => ShortcutBindingRow(
    commandId: commandId ?? this.commandId,
    platform: platform ?? this.platform,
    binding: binding ?? this.binding,
  );
  ShortcutBindingRow copyWithCompanion(ShortcutBindingsCompanion data) {
    return ShortcutBindingRow(
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      platform: data.platform.present ? data.platform.value : this.platform,
      binding: data.binding.present ? data.binding.value : this.binding,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShortcutBindingRow(')
          ..write('commandId: $commandId, ')
          ..write('platform: $platform, ')
          ..write('binding: $binding')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(commandId, platform, binding);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShortcutBindingRow &&
          other.commandId == this.commandId &&
          other.platform == this.platform &&
          other.binding == this.binding);
}

class ShortcutBindingsCompanion extends UpdateCompanion<ShortcutBindingRow> {
  final Value<String> commandId;
  final Value<String> platform;
  final Value<String> binding;
  final Value<int> rowid;
  const ShortcutBindingsCompanion({
    this.commandId = const Value.absent(),
    this.platform = const Value.absent(),
    this.binding = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShortcutBindingsCompanion.insert({
    required String commandId,
    required String platform,
    required String binding,
    this.rowid = const Value.absent(),
  }) : commandId = Value(commandId),
       platform = Value(platform),
       binding = Value(binding);
  static Insertable<ShortcutBindingRow> custom({
    Expression<String>? commandId,
    Expression<String>? platform,
    Expression<String>? binding,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (commandId != null) 'command_id': commandId,
      if (platform != null) 'platform': platform,
      if (binding != null) 'binding': binding,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShortcutBindingsCompanion copyWith({
    Value<String>? commandId,
    Value<String>? platform,
    Value<String>? binding,
    Value<int>? rowid,
  }) {
    return ShortcutBindingsCompanion(
      commandId: commandId ?? this.commandId,
      platform: platform ?? this.platform,
      binding: binding ?? this.binding,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (binding.present) {
      map['binding'] = Variable<String>(binding.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShortcutBindingsCompanion(')
          ..write('commandId: $commandId, ')
          ..write('platform: $platform, ')
          ..write('binding: $binding, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TidelineDatabase extends GeneratedDatabase {
  _$TidelineDatabase(QueryExecutor e) : super(e);
  $TidelineDatabaseManager get managers => $TidelineDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $StationProfilesTable stationProfiles = $StationProfilesTable(
    this,
  );
  late final $ContestDefinitionsTable contestDefinitions =
      $ContestDefinitionsTable(this);
  late final $ContestSessionsTable contestSessions = $ContestSessionsTable(
    this,
  );
  late final $ActivationsTable activations = $ActivationsTable(this);
  late final $QsosTable qsos = $QsosTable(this);
  late final $QsoSyncTable qsoSync = $QsoSyncTable(this);
  late final $SyncJournalTable syncJournal = $SyncJournalTable(this);
  late final $SerialAllocationsTable serialAllocations =
      $SerialAllocationsTable(this);
  late final $ProgramRulesTable programRules = $ProgramRulesTable(this);
  late final $ReferencePacksTable referencePacks = $ReferencePacksTable(this);
  late final $DxccEntitiesTable dxccEntities = $DxccEntitiesTable(this);
  late final $DxccPrefixesTable dxccPrefixes = $DxccPrefixesTable(this);
  late final $ProgramReferencesTable programReferences =
      $ProgramReferencesTable(this);
  late final $ScpCallsTable scpCalls = $ScpCallsTable(this);
  late final $WorkedBeforeTable workedBefore = $WorkedBeforeTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $PeerCursorsTable peerCursors = $PeerCursorsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ShortcutBindingsTable shortcutBindings = $ShortcutBindingsTable(
    this,
  );
  late final Index qsosAccountTime = Index(
    'qsos_account_time',
    'CREATE INDEX qsos_account_time ON qsos (account_id, time_on)',
  );
  late final Index qsosCall = Index(
    'qsos_call',
    'CREATE INDEX qsos_call ON qsos (call)',
  );
  late final Index qsosContestSession = Index(
    'qsos_contest_session',
    'CREATE INDEX qsos_contest_session ON qsos (contest_session_id)',
  );
  late final Index qsoSyncAccountState = Index(
    'qso_sync_account_state',
    'CREATE INDEX qso_sync_account_state ON qso_sync (account_id, state)',
  );
  late final Index syncJournalAccountAt = Index(
    'sync_journal_account_at',
    'CREATE INDEX sync_journal_account_at ON sync_journal (account_id, at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    stationProfiles,
    contestDefinitions,
    contestSessions,
    activations,
    qsos,
    qsoSync,
    syncJournal,
    serialAllocations,
    programRules,
    referencePacks,
    dxccEntities,
    dxccPrefixes,
    programReferences,
    scpCalls,
    workedBefore,
    devices,
    peerCursors,
    settings,
    shortcutBindings,
    qsosAccountTime,
    qsosCall,
    qsosContestSession,
    qsoSyncAccountState,
    syncJournalAccountAt,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String label,
  required String baseUrl,
  Value<bool> usesIndexPhp,
  Value<String?> certPinSha256,
  Value<bool> allowHttpLan,
  Value<String> serverCaps,
  Value<String> scopes,
  Value<int?> tokenExpiresAt,
  required int createdAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> label,
  Value<String> baseUrl,
  Value<bool> usesIndexPhp,
  Value<String?> certPinSha256,
  Value<bool> allowHttpLan,
  Value<String> serverCaps,
  Value<String> scopes,
  Value<int?> tokenExpiresAt,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$TidelineDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StationProfilesTable, List<StationProfileRow>>
  _stationProfilesRefsTable(_$TidelineDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stationProfiles,
        aliasName: 'accounts__id__station_profiles__account_id',
      );

  $$StationProfilesTableProcessedTableManager get stationProfilesRefs {
    final manager = $$StationProfilesTableTableManager(
      $_db,
      $_db.stationProfiles,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stationProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ContestSessionsTable, List<ContestSessionRow>>
  _contestSessionsRefsTable(_$TidelineDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contestSessions,
        aliasName: 'accounts__id__contest_sessions__account_id',
      );

  $$ContestSessionsTableProcessedTableManager get contestSessionsRefs {
    final manager = $$ContestSessionsTableTableManager(
      $_db,
      $_db.contestSessions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _contestSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivationsTable, List<ActivationRow>>
  _activationsRefsTable(_$TidelineDatabase db) => MultiTypedResultKey.fromTable(
    db.activations,
    aliasName: 'accounts__id__activations__account_id',
  );

  $$ActivationsTableProcessedTableManager get activationsRefs {
    final manager = $$ActivationsTableTableManager(
      $_db,
      $_db.activations,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QsosTable, List<QsoRow>> _qsosRefsTable(
    _$TidelineDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.qsos,
    aliasName: 'accounts__id__qsos__account_id',
  );

  $$QsosTableProcessedTableManager get qsosRefs {
    final manager = $$QsosTableTableManager(
      $_db,
      $_db.qsos,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_qsosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QsoSyncTable, List<QsoSyncRow>> _qsoSyncRefsTable(
    _$TidelineDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.qsoSync,
    aliasName: 'accounts__id__qso_sync__account_id',
  );

  $$QsoSyncTableProcessedTableManager get qsoSyncRefs {
    final manager = $$QsoSyncTableTableManager(
      $_db,
      $_db.qsoSync,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_qsoSyncRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncJournalTable, List<SyncJournalRow>>
  _syncJournalRefsTable(_$TidelineDatabase db) => MultiTypedResultKey.fromTable(
    db.syncJournal,
    aliasName: 'accounts__id__sync_journal__account_id',
  );

  $$SyncJournalTableProcessedTableManager get syncJournalRefs {
    final manager = $$SyncJournalTableTableManager(
      $_db,
      $_db.syncJournal,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncJournalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkedBeforeTable, List<WorkedBeforeRow>>
  _workedBeforeRefsTable(_$TidelineDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workedBefore,
        aliasName: 'accounts__id__worked_before__account_id',
      );

  $$WorkedBeforeTableProcessedTableManager get workedBeforeRefs {
    final manager = $$WorkedBeforeTableTableManager(
      $_db,
      $_db.workedBefore,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workedBeforeRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$TidelineDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usesIndexPhp => $composableBuilder(
    column: $table.usesIndexPhp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certPinSha256 => $composableBuilder(
    column: $table.certPinSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowHttpLan => $composableBuilder(
    column: $table.allowHttpLan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverCaps => $composableBuilder(
    column: $table.serverCaps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopes => $composableBuilder(
    column: $table.scopes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenExpiresAt => $composableBuilder(
    column: $table.tokenExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stationProfilesRefs(
    Expression<bool> Function($$StationProfilesTableFilterComposer f) f,
  ) {
    final $$StationProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableFilterComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> contestSessionsRefs(
    Expression<bool> Function($$ContestSessionsTableFilterComposer f) f,
  ) {
    final $$ContestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activationsRefs(
    Expression<bool> Function($$ActivationsTableFilterComposer f) f,
  ) {
    final $$ActivationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivationsTableFilterComposer(
            $db: $db,
            $table: $db.activations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> qsosRefs(
    Expression<bool> Function($$QsosTableFilterComposer f) f,
  ) {
    final $$QsosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableFilterComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> qsoSyncRefs(
    Expression<bool> Function($$QsoSyncTableFilterComposer f) f,
  ) {
    final $$QsoSyncTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsoSync,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsoSyncTableFilterComposer(
            $db: $db,
            $table: $db.qsoSync,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncJournalRefs(
    Expression<bool> Function($$SyncJournalTableFilterComposer f) f,
  ) {
    final $$SyncJournalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncJournal,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncJournalTableFilterComposer(
            $db: $db,
            $table: $db.syncJournal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workedBeforeRefs(
    Expression<bool> Function($$WorkedBeforeTableFilterComposer f) f,
  ) {
    final $$WorkedBeforeTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workedBefore,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkedBeforeTableFilterComposer(
            $db: $db,
            $table: $db.workedBefore,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usesIndexPhp => $composableBuilder(
    column: $table.usesIndexPhp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certPinSha256 => $composableBuilder(
    column: $table.certPinSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowHttpLan => $composableBuilder(
    column: $table.allowHttpLan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverCaps => $composableBuilder(
    column: $table.serverCaps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopes => $composableBuilder(
    column: $table.scopes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenExpiresAt => $composableBuilder(
    column: $table.tokenExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<bool> get usesIndexPhp => $composableBuilder(
    column: $table.usesIndexPhp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get certPinSha256 => $composableBuilder(
    column: $table.certPinSha256,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowHttpLan => $composableBuilder(
    column: $table.allowHttpLan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverCaps => $composableBuilder(
    column: $table.serverCaps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopes =>
      $composableBuilder(column: $table.scopes, builder: (column) => column);

  GeneratedColumn<int> get tokenExpiresAt => $composableBuilder(
    column: $table.tokenExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> stationProfilesRefs<T extends Object>(
    Expression<T> Function($$StationProfilesTableAnnotationComposer a) f,
  ) {
    final $$StationProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> contestSessionsRefs<T extends Object>(
    Expression<T> Function($$ContestSessionsTableAnnotationComposer a) f,
  ) {
    final $$ContestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activationsRefs<T extends Object>(
    Expression<T> Function($$ActivationsTableAnnotationComposer a) f,
  ) {
    final $$ActivationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivationsTableAnnotationComposer(
            $db: $db,
            $table: $db.activations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> qsosRefs<T extends Object>(
    Expression<T> Function($$QsosTableAnnotationComposer a) f,
  ) {
    final $$QsosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableAnnotationComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> qsoSyncRefs<T extends Object>(
    Expression<T> Function($$QsoSyncTableAnnotationComposer a) f,
  ) {
    final $$QsoSyncTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsoSync,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsoSyncTableAnnotationComposer(
            $db: $db,
            $table: $db.qsoSync,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncJournalRefs<T extends Object>(
    Expression<T> Function($$SyncJournalTableAnnotationComposer a) f,
  ) {
    final $$SyncJournalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncJournal,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncJournalTableAnnotationComposer(
            $db: $db,
            $table: $db.syncJournal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workedBeforeRefs<T extends Object>(
    Expression<T> Function($$WorkedBeforeTableAnnotationComposer a) f,
  ) {
    final $$WorkedBeforeTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workedBefore,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkedBeforeTableAnnotationComposer(
            $db: $db,
            $table: $db.workedBefore,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({
            bool stationProfilesRefs,
            bool contestSessionsRefs,
            bool activationsRefs,
            bool qsosRefs,
            bool qsoSyncRefs,
            bool syncJournalRefs,
            bool workedBeforeRefs,
          })
        > {
  $$AccountsTableTableManager(_$TidelineDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<bool> usesIndexPhp = const Value.absent(),
                Value<String?> certPinSha256 = const Value.absent(),
                Value<bool> allowHttpLan = const Value.absent(),
                Value<String> serverCaps = const Value.absent(),
                Value<String> scopes = const Value.absent(),
                Value<int?> tokenExpiresAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                label: label,
                baseUrl: baseUrl,
                usesIndexPhp: usesIndexPhp,
                certPinSha256: certPinSha256,
                allowHttpLan: allowHttpLan,
                serverCaps: serverCaps,
                scopes: scopes,
                tokenExpiresAt: tokenExpiresAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String baseUrl,
                Value<bool> usesIndexPhp = const Value.absent(),
                Value<String?> certPinSha256 = const Value.absent(),
                Value<bool> allowHttpLan = const Value.absent(),
                Value<String> serverCaps = const Value.absent(),
                Value<String> scopes = const Value.absent(),
                Value<int?> tokenExpiresAt = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                label: label,
                baseUrl: baseUrl,
                usesIndexPhp: usesIndexPhp,
                certPinSha256: certPinSha256,
                allowHttpLan: allowHttpLan,
                serverCaps: serverCaps,
                scopes: scopes,
                tokenExpiresAt: tokenExpiresAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, AccountRow>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stationProfilesRefs = false,
                contestSessionsRefs = false,
                activationsRefs = false,
                qsosRefs = false,
                qsoSyncRefs = false,
                syncJournalRefs = false,
                workedBeforeRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stationProfilesRefs) db.stationProfiles,
                    if (contestSessionsRefs) db.contestSessions,
                    if (activationsRefs) db.activations,
                    if (qsosRefs) db.qsos,
                    if (qsoSyncRefs) db.qsoSync,
                    if (syncJournalRefs) db.syncJournal,
                    if (workedBeforeRefs) db.workedBefore,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stationProfilesRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          StationProfileRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._stationProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).stationProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (contestSessionsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          ContestSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._contestSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).contestSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activationsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          ActivationRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._activationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).activationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (qsosRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          QsoRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._qsosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(db, table, p0).qsosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (qsoSyncRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          QsoSyncRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._qsoSyncRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).qsoSyncRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncJournalRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          SyncJournalRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._syncJournalRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncJournalRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workedBeforeRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          WorkedBeforeRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._workedBeforeRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).workedBeforeRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({
        bool stationProfilesRefs,
        bool contestSessionsRefs,
        bool activationsRefs,
        bool qsosRefs,
        bool qsoSyncRefs,
        bool syncJournalRefs,
        bool workedBeforeRefs,
      })
    >;
typedef $$StationProfilesTableCreateCompanionBuilder =
    StationProfilesCompanion Function({
      required String id,
      required String accountId,
      required int remoteId,
      required String name,
      required String callsign,
      Value<String?> gridsquare,
      Value<int?> dxcc,
      Value<int?> cqz,
      Value<int?> ituz,
      Value<String?> sotaRef,
      Value<String?> potaRef,
      Value<String?> wwffRef,
      Value<String?> iota,
      Value<String?> sig,
      Value<String?> sigInfo,
      Value<bool> active,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$StationProfilesTableUpdateCompanionBuilder =
    StationProfilesCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<int> remoteId,
      Value<String> name,
      Value<String> callsign,
      Value<String?> gridsquare,
      Value<int?> dxcc,
      Value<int?> cqz,
      Value<int?> ituz,
      Value<String?> sotaRef,
      Value<String?> potaRef,
      Value<String?> wwffRef,
      Value<String?> iota,
      Value<String?> sig,
      Value<String?> sigInfo,
      Value<bool> active,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

final class $$StationProfilesTableReferences
    extends
        BaseReferences<
          _$TidelineDatabase,
          $StationProfilesTable,
          StationProfileRow
        > {
  $$StationProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$TidelineDatabase db) =>
      db.accounts.createAlias('station_profiles__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ContestSessionsTable, List<ContestSessionRow>>
  _contestSessionsRefsTable(_$TidelineDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contestSessions,
        aliasName: 'station_profiles__id__contest_sessions__station_profile_id',
      );

  $$ContestSessionsTableProcessedTableManager get contestSessionsRefs {
    final manager =
        $$ContestSessionsTableTableManager($_db, $_db.contestSessions).filter(
          (f) => f.stationProfileId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _contestSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivationsTable, List<ActivationRow>>
  _activationsRefsTable(_$TidelineDatabase db) => MultiTypedResultKey.fromTable(
    db.activations,
    aliasName: 'station_profiles__id__activations__station_profile_id',
  );

  $$ActivationsTableProcessedTableManager get activationsRefs {
    final manager = $$ActivationsTableTableManager($_db, $_db.activations)
        .filter(
          (f) => f.stationProfileId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_activationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QsosTable, List<QsoRow>> _qsosRefsTable(
    _$TidelineDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.qsos,
    aliasName: 'station_profiles__id__qsos__station_profile_id',
  );

  $$QsosTableProcessedTableManager get qsosRefs {
    final manager = $$QsosTableTableManager($_db, $_db.qsos).filter(
      (f) => f.stationProfileId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_qsosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StationProfilesTableFilterComposer
    extends Composer<_$TidelineDatabase, $StationProfilesTable> {
  $$StationProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callsign => $composableBuilder(
    column: $table.callsign,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cqz => $composableBuilder(
    column: $table.cqz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ituz => $composableBuilder(
    column: $table.ituz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sotaRef => $composableBuilder(
    column: $table.sotaRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get potaRef => $composableBuilder(
    column: $table.potaRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wwffRef => $composableBuilder(
    column: $table.wwffRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iota => $composableBuilder(
    column: $table.iota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sigInfo => $composableBuilder(
    column: $table.sigInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> contestSessionsRefs(
    Expression<bool> Function($$ContestSessionsTableFilterComposer f) f,
  ) {
    final $$ContestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.stationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activationsRefs(
    Expression<bool> Function($$ActivationsTableFilterComposer f) f,
  ) {
    final $$ActivationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activations,
      getReferencedColumn: (t) => t.stationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivationsTableFilterComposer(
            $db: $db,
            $table: $db.activations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> qsosRefs(
    Expression<bool> Function($$QsosTableFilterComposer f) f,
  ) {
    final $$QsosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.stationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableFilterComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationProfilesTableOrderingComposer
    extends Composer<_$TidelineDatabase, $StationProfilesTable> {
  $$StationProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callsign => $composableBuilder(
    column: $table.callsign,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cqz => $composableBuilder(
    column: $table.cqz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ituz => $composableBuilder(
    column: $table.ituz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sotaRef => $composableBuilder(
    column: $table.sotaRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get potaRef => $composableBuilder(
    column: $table.potaRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wwffRef => $composableBuilder(
    column: $table.wwffRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iota => $composableBuilder(
    column: $table.iota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sigInfo => $composableBuilder(
    column: $table.sigInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StationProfilesTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $StationProfilesTable> {
  $$StationProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get callsign =>
      $composableBuilder(column: $table.callsign, builder: (column) => column);

  GeneratedColumn<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dxcc =>
      $composableBuilder(column: $table.dxcc, builder: (column) => column);

  GeneratedColumn<int> get cqz =>
      $composableBuilder(column: $table.cqz, builder: (column) => column);

  GeneratedColumn<int> get ituz =>
      $composableBuilder(column: $table.ituz, builder: (column) => column);

  GeneratedColumn<String> get sotaRef =>
      $composableBuilder(column: $table.sotaRef, builder: (column) => column);

  GeneratedColumn<String> get potaRef =>
      $composableBuilder(column: $table.potaRef, builder: (column) => column);

  GeneratedColumn<String> get wwffRef =>
      $composableBuilder(column: $table.wwffRef, builder: (column) => column);

  GeneratedColumn<String> get iota =>
      $composableBuilder(column: $table.iota, builder: (column) => column);

  GeneratedColumn<String> get sig =>
      $composableBuilder(column: $table.sig, builder: (column) => column);

  GeneratedColumn<String> get sigInfo =>
      $composableBuilder(column: $table.sigInfo, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> contestSessionsRefs<T extends Object>(
    Expression<T> Function($$ContestSessionsTableAnnotationComposer a) f,
  ) {
    final $$ContestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.stationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activationsRefs<T extends Object>(
    Expression<T> Function($$ActivationsTableAnnotationComposer a) f,
  ) {
    final $$ActivationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activations,
      getReferencedColumn: (t) => t.stationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivationsTableAnnotationComposer(
            $db: $db,
            $table: $db.activations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> qsosRefs<T extends Object>(
    Expression<T> Function($$QsosTableAnnotationComposer a) f,
  ) {
    final $$QsosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.stationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableAnnotationComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationProfilesTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $StationProfilesTable,
          StationProfileRow,
          $$StationProfilesTableFilterComposer,
          $$StationProfilesTableOrderingComposer,
          $$StationProfilesTableAnnotationComposer,
          $$StationProfilesTableCreateCompanionBuilder,
          $$StationProfilesTableUpdateCompanionBuilder,
          (StationProfileRow, $$StationProfilesTableReferences),
          StationProfileRow,
          PrefetchHooks Function({
            bool accountId,
            bool contestSessionsRefs,
            bool activationsRefs,
            bool qsosRefs,
          })
        > {
  $$StationProfilesTableTableManager(
    _$TidelineDatabase db,
    $StationProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StationProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StationProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StationProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> callsign = const Value.absent(),
                Value<String?> gridsquare = const Value.absent(),
                Value<int?> dxcc = const Value.absent(),
                Value<int?> cqz = const Value.absent(),
                Value<int?> ituz = const Value.absent(),
                Value<String?> sotaRef = const Value.absent(),
                Value<String?> potaRef = const Value.absent(),
                Value<String?> wwffRef = const Value.absent(),
                Value<String?> iota = const Value.absent(),
                Value<String?> sig = const Value.absent(),
                Value<String?> sigInfo = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StationProfilesCompanion(
                id: id,
                accountId: accountId,
                remoteId: remoteId,
                name: name,
                callsign: callsign,
                gridsquare: gridsquare,
                dxcc: dxcc,
                cqz: cqz,
                ituz: ituz,
                sotaRef: sotaRef,
                potaRef: potaRef,
                wwffRef: wwffRef,
                iota: iota,
                sig: sig,
                sigInfo: sigInfo,
                active: active,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required int remoteId,
                required String name,
                required String callsign,
                Value<String?> gridsquare = const Value.absent(),
                Value<int?> dxcc = const Value.absent(),
                Value<int?> cqz = const Value.absent(),
                Value<int?> ituz = const Value.absent(),
                Value<String?> sotaRef = const Value.absent(),
                Value<String?> potaRef = const Value.absent(),
                Value<String?> wwffRef = const Value.absent(),
                Value<String?> iota = const Value.absent(),
                Value<String?> sig = const Value.absent(),
                Value<String?> sigInfo = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => StationProfilesCompanion.insert(
                id: id,
                accountId: accountId,
                remoteId: remoteId,
                name: name,
                callsign: callsign,
                gridsquare: gridsquare,
                dxcc: dxcc,
                cqz: cqz,
                ituz: ituz,
                sotaRef: sotaRef,
                potaRef: potaRef,
                wwffRef: wwffRef,
                iota: iota,
                sig: sig,
                sigInfo: sigInfo,
                active: active,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StationProfilesTable, StationProfileRow>(table),
                  $$StationProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                contestSessionsRefs = false,
                activationsRefs = false,
                qsosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (contestSessionsRefs) db.contestSessions,
                    if (activationsRefs) db.activations,
                    if (qsosRefs) db.qsos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$StationProfilesTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$StationProfilesTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (contestSessionsRefs)
                        await $_getPrefetchedData<
                          StationProfileRow,
                          $StationProfilesTable,
                          ContestSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StationProfilesTableReferences
                              ._contestSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StationProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).contestSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stationProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activationsRefs)
                        await $_getPrefetchedData<
                          StationProfileRow,
                          $StationProfilesTable,
                          ActivationRow
                        >(
                          currentTable: table,
                          referencedTable: $$StationProfilesTableReferences
                              ._activationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StationProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).activationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stationProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (qsosRefs)
                        await $_getPrefetchedData<
                          StationProfileRow,
                          $StationProfilesTable,
                          QsoRow
                        >(
                          currentTable: table,
                          referencedTable: $$StationProfilesTableReferences
                              ._qsosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StationProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).qsosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stationProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StationProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $StationProfilesTable,
      StationProfileRow,
      $$StationProfilesTableFilterComposer,
      $$StationProfilesTableOrderingComposer,
      $$StationProfilesTableAnnotationComposer,
      $$StationProfilesTableCreateCompanionBuilder,
      $$StationProfilesTableUpdateCompanionBuilder,
      (StationProfileRow, $$StationProfilesTableReferences),
      StationProfileRow,
      PrefetchHooks Function({
        bool accountId,
        bool contestSessionsRefs,
        bool activationsRefs,
        bool qsosRefs,
      })
    >;
typedef $$ContestDefinitionsTableCreateCompanionBuilder =
    ContestDefinitionsCompanion Function({
      required String id,
      required String name,
      Value<String?> cabrilloName,
      Value<String?> wavelogAdifName,
      required int version,
      required String definition,
      Value<bool> builtin,
      Value<int> rowid,
    });
typedef $$ContestDefinitionsTableUpdateCompanionBuilder =
    ContestDefinitionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> cabrilloName,
      Value<String?> wavelogAdifName,
      Value<int> version,
      Value<String> definition,
      Value<bool> builtin,
      Value<int> rowid,
    });

final class $$ContestDefinitionsTableReferences
    extends
        BaseReferences<
          _$TidelineDatabase,
          $ContestDefinitionsTable,
          ContestDefinitionRow
        > {
  $$ContestDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ContestSessionsTable, List<ContestSessionRow>>
  _contestSessionsRefsTable(_$TidelineDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contestSessions,
        aliasName: 'contest_definitions__id__contest_sessions__definition_id',
      );

  $$ContestSessionsTableProcessedTableManager get contestSessionsRefs {
    final manager = $$ContestSessionsTableTableManager(
      $_db,
      $_db.contestSessions,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _contestSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContestDefinitionsTableFilterComposer
    extends Composer<_$TidelineDatabase, $ContestDefinitionsTable> {
  $$ContestDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cabrilloName => $composableBuilder(
    column: $table.cabrilloName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wavelogAdifName => $composableBuilder(
    column: $table.wavelogAdifName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtin => $composableBuilder(
    column: $table.builtin,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contestSessionsRefs(
    Expression<bool> Function($$ContestSessionsTableFilterComposer f) f,
  ) {
    final $$ContestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContestDefinitionsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ContestDefinitionsTable> {
  $$ContestDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cabrilloName => $composableBuilder(
    column: $table.cabrilloName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wavelogAdifName => $composableBuilder(
    column: $table.wavelogAdifName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtin => $composableBuilder(
    column: $table.builtin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContestDefinitionsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ContestDefinitionsTable> {
  $$ContestDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get cabrilloName => $composableBuilder(
    column: $table.cabrilloName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wavelogAdifName => $composableBuilder(
    column: $table.wavelogAdifName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get builtin =>
      $composableBuilder(column: $table.builtin, builder: (column) => column);

  Expression<T> contestSessionsRefs<T extends Object>(
    Expression<T> Function($$ContestSessionsTableAnnotationComposer a) f,
  ) {
    final $$ContestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContestDefinitionsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ContestDefinitionsTable,
          ContestDefinitionRow,
          $$ContestDefinitionsTableFilterComposer,
          $$ContestDefinitionsTableOrderingComposer,
          $$ContestDefinitionsTableAnnotationComposer,
          $$ContestDefinitionsTableCreateCompanionBuilder,
          $$ContestDefinitionsTableUpdateCompanionBuilder,
          (ContestDefinitionRow, $$ContestDefinitionsTableReferences),
          ContestDefinitionRow,
          PrefetchHooks Function({bool contestSessionsRefs})
        > {
  $$ContestDefinitionsTableTableManager(
    _$TidelineDatabase db,
    $ContestDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContestDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContestDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContestDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> cabrilloName = const Value.absent(),
                Value<String?> wavelogAdifName = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<bool> builtin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContestDefinitionsCompanion(
                id: id,
                name: name,
                cabrilloName: cabrilloName,
                wavelogAdifName: wavelogAdifName,
                version: version,
                definition: definition,
                builtin: builtin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> cabrilloName = const Value.absent(),
                Value<String?> wavelogAdifName = const Value.absent(),
                required int version,
                required String definition,
                Value<bool> builtin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContestDefinitionsCompanion.insert(
                id: id,
                name: name,
                cabrilloName: cabrilloName,
                wavelogAdifName: wavelogAdifName,
                version: version,
                definition: definition,
                builtin: builtin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContestDefinitionsTable, ContestDefinitionRow>(
                    table,
                  ),
                  $$ContestDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contestSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (contestSessionsRefs) db.contestSessions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contestSessionsRefs)
                    await $_getPrefetchedData<
                      ContestDefinitionRow,
                      $ContestDefinitionsTable,
                      ContestSessionRow
                    >(
                      currentTable: table,
                      referencedTable: $$ContestDefinitionsTableReferences
                          ._contestSessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ContestDefinitionsTableReferences(
                            db,
                            table,
                            p0,
                          ).contestSessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.definitionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContestDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ContestDefinitionsTable,
      ContestDefinitionRow,
      $$ContestDefinitionsTableFilterComposer,
      $$ContestDefinitionsTableOrderingComposer,
      $$ContestDefinitionsTableAnnotationComposer,
      $$ContestDefinitionsTableCreateCompanionBuilder,
      $$ContestDefinitionsTableUpdateCompanionBuilder,
      (ContestDefinitionRow, $$ContestDefinitionsTableReferences),
      ContestDefinitionRow,
      PrefetchHooks Function({bool contestSessionsRefs})
    >;
typedef $$ContestSessionsTableCreateCompanionBuilder =
    ContestSessionsCompanion Function({
      required String originDeviceId,
      required String hlcCreated,
      required String hlcModified,
      Value<int> rev,
      Value<int?> deletedAt,
      required String id,
      required String definitionId,
      required String accountId,
      Value<String?> stationProfileId,
      required int startedAt,
      Value<int?> endedAt,
      Value<String> settings,
      Value<int?> remoteSessionId,
      Value<String> serialStrategy,
      Value<int?> serialRangeStart,
      Value<int?> serialRangeEnd,
      Value<int> rowid,
    });
typedef $$ContestSessionsTableUpdateCompanionBuilder =
    ContestSessionsCompanion Function({
      Value<String> originDeviceId,
      Value<String> hlcCreated,
      Value<String> hlcModified,
      Value<int> rev,
      Value<int?> deletedAt,
      Value<String> id,
      Value<String> definitionId,
      Value<String> accountId,
      Value<String?> stationProfileId,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<String> settings,
      Value<int?> remoteSessionId,
      Value<String> serialStrategy,
      Value<int?> serialRangeStart,
      Value<int?> serialRangeEnd,
      Value<int> rowid,
    });

final class $$ContestSessionsTableReferences
    extends
        BaseReferences<
          _$TidelineDatabase,
          $ContestSessionsTable,
          ContestSessionRow
        > {
  $$ContestSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContestDefinitionsTable _definitionIdTable(_$TidelineDatabase db) =>
      db.contestDefinitions.createAlias(
        'contest_sessions__definition_id__contest_definitions__id',
      );

  $$ContestDefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<String>('definition_id')!;

    final manager = $$ContestDefinitionsTableTableManager(
      $_db,
      $_db.contestDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$TidelineDatabase db) =>
      db.accounts.createAlias('contest_sessions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StationProfilesTable _stationProfileIdTable(_$TidelineDatabase db) =>
      db.stationProfiles.createAlias(
        'contest_sessions__station_profile_id__station_profiles__id',
      );

  $$StationProfilesTableProcessedTableManager? get stationProfileId {
    final $_column = $_itemColumn<String>('station_profile_id');
    if ($_column == null) return null;
    final manager = $$StationProfilesTableTableManager(
      $_db,
      $_db.stationProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stationProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QsosTable, List<QsoRow>> _qsosRefsTable(
    _$TidelineDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.qsos,
    aliasName: 'contest_sessions__id__qsos__contest_session_id',
  );

  $$QsosTableProcessedTableManager get qsosRefs {
    final manager = $$QsosTableTableManager($_db, $_db.qsos).filter(
      (f) => f.contestSessionId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_qsosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SerialAllocationsTable, List<SerialAllocationRow>>
  _serialAllocationsRefsTable(_$TidelineDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.serialAllocations,
        aliasName: 'contest_sessions__id__serial_allocations__session_id',
      );

  $$SerialAllocationsTableProcessedTableManager get serialAllocationsRefs {
    final manager = $$SerialAllocationsTableTableManager(
      $_db,
      $_db.serialAllocations,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _serialAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContestSessionsTableFilterComposer
    extends Composer<_$TidelineDatabase, $ContestSessionsTable> {
  $$ContestSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteSessionId => $composableBuilder(
    column: $table.remoteSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialStrategy => $composableBuilder(
    column: $table.serialStrategy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serialRangeStart => $composableBuilder(
    column: $table.serialRangeStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serialRangeEnd => $composableBuilder(
    column: $table.serialRangeEnd,
    builder: (column) => ColumnFilters(column),
  );

  $$ContestDefinitionsTableFilterComposer get definitionId {
    final $$ContestDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.contestDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.contestDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableFilterComposer get stationProfileId {
    final $$StationProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableFilterComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> qsosRefs(
    Expression<bool> Function($$QsosTableFilterComposer f) f,
  ) {
    final $$QsosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.contestSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableFilterComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serialAllocationsRefs(
    Expression<bool> Function($$SerialAllocationsTableFilterComposer f) f,
  ) {
    final $$SerialAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serialAllocations,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SerialAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.serialAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContestSessionsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ContestSessionsTable> {
  $$ContestSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteSessionId => $composableBuilder(
    column: $table.remoteSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialStrategy => $composableBuilder(
    column: $table.serialStrategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serialRangeStart => $composableBuilder(
    column: $table.serialRangeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serialRangeEnd => $composableBuilder(
    column: $table.serialRangeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContestDefinitionsTableOrderingComposer get definitionId {
    final $$ContestDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.contestDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.contestDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableOrderingComposer get stationProfileId {
    final $$StationProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContestSessionsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ContestSessionsTable> {
  $$ContestSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);

  GeneratedColumn<int> get remoteSessionId => $composableBuilder(
    column: $table.remoteSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serialStrategy => $composableBuilder(
    column: $table.serialStrategy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serialRangeStart => $composableBuilder(
    column: $table.serialRangeStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serialRangeEnd => $composableBuilder(
    column: $table.serialRangeEnd,
    builder: (column) => column,
  );

  $$ContestDefinitionsTableAnnotationComposer get definitionId {
    final $$ContestDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.definitionId,
          referencedTable: $db.contestDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContestDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.contestDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableAnnotationComposer get stationProfileId {
    final $$StationProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> qsosRefs<T extends Object>(
    Expression<T> Function($$QsosTableAnnotationComposer a) f,
  ) {
    final $$QsosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.contestSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableAnnotationComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> serialAllocationsRefs<T extends Object>(
    Expression<T> Function($$SerialAllocationsTableAnnotationComposer a) f,
  ) {
    final $$SerialAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.serialAllocations,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SerialAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.serialAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContestSessionsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ContestSessionsTable,
          ContestSessionRow,
          $$ContestSessionsTableFilterComposer,
          $$ContestSessionsTableOrderingComposer,
          $$ContestSessionsTableAnnotationComposer,
          $$ContestSessionsTableCreateCompanionBuilder,
          $$ContestSessionsTableUpdateCompanionBuilder,
          (ContestSessionRow, $$ContestSessionsTableReferences),
          ContestSessionRow,
          PrefetchHooks Function({
            bool definitionId,
            bool accountId,
            bool stationProfileId,
            bool qsosRefs,
            bool serialAllocationsRefs,
          })
        > {
  $$ContestSessionsTableTableManager(
    _$TidelineDatabase db,
    $ContestSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContestSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContestSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContestSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> originDeviceId = const Value.absent(),
                Value<String> hlcCreated = const Value.absent(),
                Value<String> hlcModified = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> stationProfileId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<int?> remoteSessionId = const Value.absent(),
                Value<String> serialStrategy = const Value.absent(),
                Value<int?> serialRangeStart = const Value.absent(),
                Value<int?> serialRangeEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContestSessionsCompanion(
                originDeviceId: originDeviceId,
                hlcCreated: hlcCreated,
                hlcModified: hlcModified,
                rev: rev,
                deletedAt: deletedAt,
                id: id,
                definitionId: definitionId,
                accountId: accountId,
                stationProfileId: stationProfileId,
                startedAt: startedAt,
                endedAt: endedAt,
                settings: settings,
                remoteSessionId: remoteSessionId,
                serialStrategy: serialStrategy,
                serialRangeStart: serialRangeStart,
                serialRangeEnd: serialRangeEnd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String originDeviceId,
                required String hlcCreated,
                required String hlcModified,
                Value<int> rev = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                required String id,
                required String definitionId,
                required String accountId,
                Value<String?> stationProfileId = const Value.absent(),
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<int?> remoteSessionId = const Value.absent(),
                Value<String> serialStrategy = const Value.absent(),
                Value<int?> serialRangeStart = const Value.absent(),
                Value<int?> serialRangeEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContestSessionsCompanion.insert(
                originDeviceId: originDeviceId,
                hlcCreated: hlcCreated,
                hlcModified: hlcModified,
                rev: rev,
                deletedAt: deletedAt,
                id: id,
                definitionId: definitionId,
                accountId: accountId,
                stationProfileId: stationProfileId,
                startedAt: startedAt,
                endedAt: endedAt,
                settings: settings,
                remoteSessionId: remoteSessionId,
                serialStrategy: serialStrategy,
                serialRangeStart: serialRangeStart,
                serialRangeEnd: serialRangeEnd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContestSessionsTable, ContestSessionRow>(table),
                  $$ContestSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                definitionId = false,
                accountId = false,
                stationProfileId = false,
                qsosRefs = false,
                serialAllocationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (qsosRefs) db.qsos,
                    if (serialAllocationsRefs) db.serialAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (definitionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.definitionId,
                            referencedTable: $$ContestSessionsTableReferences
                                ._definitionIdTable(db),
                            referencedColumn: $$ContestSessionsTableReferences
                                ._definitionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$ContestSessionsTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$ContestSessionsTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (stationProfileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.stationProfileId,
                            referencedTable: $$ContestSessionsTableReferences
                                ._stationProfileIdTable(db),
                            referencedColumn: $$ContestSessionsTableReferences
                                ._stationProfileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (qsosRefs)
                        await $_getPrefetchedData<
                          ContestSessionRow,
                          $ContestSessionsTable,
                          QsoRow
                        >(
                          currentTable: table,
                          referencedTable: $$ContestSessionsTableReferences
                              ._qsosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContestSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).qsosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contestSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serialAllocationsRefs)
                        await $_getPrefetchedData<
                          ContestSessionRow,
                          $ContestSessionsTable,
                          SerialAllocationRow
                        >(
                          currentTable: table,
                          referencedTable: $$ContestSessionsTableReferences
                              ._serialAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContestSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).serialAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContestSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ContestSessionsTable,
      ContestSessionRow,
      $$ContestSessionsTableFilterComposer,
      $$ContestSessionsTableOrderingComposer,
      $$ContestSessionsTableAnnotationComposer,
      $$ContestSessionsTableCreateCompanionBuilder,
      $$ContestSessionsTableUpdateCompanionBuilder,
      (ContestSessionRow, $$ContestSessionsTableReferences),
      ContestSessionRow,
      PrefetchHooks Function({
        bool definitionId,
        bool accountId,
        bool stationProfileId,
        bool qsosRefs,
        bool serialAllocationsRefs,
      })
    >;
typedef $$ActivationsTableCreateCompanionBuilder =
    ActivationsCompanion Function({
      required String originDeviceId,
      required String hlcCreated,
      required String hlcModified,
      Value<int> rev,
      Value<int?> deletedAt,
      required String id,
      required String accountId,
      required String program,
      required String reference,
      Value<String?> myGridsquare,
      Value<String?> stationProfileId,
      required int startedAt,
      Value<int?> endedAt,
      Value<int> rowid,
    });
typedef $$ActivationsTableUpdateCompanionBuilder =
    ActivationsCompanion Function({
      Value<String> originDeviceId,
      Value<String> hlcCreated,
      Value<String> hlcModified,
      Value<int> rev,
      Value<int?> deletedAt,
      Value<String> id,
      Value<String> accountId,
      Value<String> program,
      Value<String> reference,
      Value<String?> myGridsquare,
      Value<String?> stationProfileId,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<int> rowid,
    });

final class $$ActivationsTableReferences
    extends
        BaseReferences<_$TidelineDatabase, $ActivationsTable, ActivationRow> {
  $$ActivationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$TidelineDatabase db) =>
      db.accounts.createAlias('activations__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StationProfilesTable _stationProfileIdTable(_$TidelineDatabase db) =>
      db.stationProfiles.createAlias(
        'activations__station_profile_id__station_profiles__id',
      );

  $$StationProfilesTableProcessedTableManager? get stationProfileId {
    final $_column = $_itemColumn<String>('station_profile_id');
    if ($_column == null) return null;
    final manager = $$StationProfilesTableTableManager(
      $_db,
      $_db.stationProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stationProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QsosTable, List<QsoRow>> _qsosRefsTable(
    _$TidelineDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.qsos,
    aliasName: 'activations__id__qsos__activation_id',
  );

  $$QsosTableProcessedTableManager get qsosRefs {
    final manager = $$QsosTableTableManager(
      $_db,
      $_db.qsos,
    ).filter((f) => f.activationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_qsosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivationsTableFilterComposer
    extends Composer<_$TidelineDatabase, $ActivationsTable> {
  $$ActivationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myGridsquare => $composableBuilder(
    column: $table.myGridsquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableFilterComposer get stationProfileId {
    final $$StationProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableFilterComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> qsosRefs(
    Expression<bool> Function($$QsosTableFilterComposer f) f,
  ) {
    final $$QsosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.activationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableFilterComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivationsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ActivationsTable> {
  $$ActivationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myGridsquare => $composableBuilder(
    column: $table.myGridsquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableOrderingComposer get stationProfileId {
    final $$StationProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivationsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ActivationsTable> {
  $$ActivationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get program =>
      $composableBuilder(column: $table.program, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get myGridsquare => $composableBuilder(
    column: $table.myGridsquare,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableAnnotationComposer get stationProfileId {
    final $$StationProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> qsosRefs<T extends Object>(
    Expression<T> Function($$QsosTableAnnotationComposer a) f,
  ) {
    final $$QsosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.activationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableAnnotationComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivationsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ActivationsTable,
          ActivationRow,
          $$ActivationsTableFilterComposer,
          $$ActivationsTableOrderingComposer,
          $$ActivationsTableAnnotationComposer,
          $$ActivationsTableCreateCompanionBuilder,
          $$ActivationsTableUpdateCompanionBuilder,
          (ActivationRow, $$ActivationsTableReferences),
          ActivationRow,
          PrefetchHooks Function({
            bool accountId,
            bool stationProfileId,
            bool qsosRefs,
          })
        > {
  $$ActivationsTableTableManager(_$TidelineDatabase db, $ActivationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> originDeviceId = const Value.absent(),
                Value<String> hlcCreated = const Value.absent(),
                Value<String> hlcModified = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> program = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String?> myGridsquare = const Value.absent(),
                Value<String?> stationProfileId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivationsCompanion(
                originDeviceId: originDeviceId,
                hlcCreated: hlcCreated,
                hlcModified: hlcModified,
                rev: rev,
                deletedAt: deletedAt,
                id: id,
                accountId: accountId,
                program: program,
                reference: reference,
                myGridsquare: myGridsquare,
                stationProfileId: stationProfileId,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String originDeviceId,
                required String hlcCreated,
                required String hlcModified,
                Value<int> rev = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                required String id,
                required String accountId,
                required String program,
                required String reference,
                Value<String?> myGridsquare = const Value.absent(),
                Value<String?> stationProfileId = const Value.absent(),
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivationsCompanion.insert(
                originDeviceId: originDeviceId,
                hlcCreated: hlcCreated,
                hlcModified: hlcModified,
                rev: rev,
                deletedAt: deletedAt,
                id: id,
                accountId: accountId,
                program: program,
                reference: reference,
                myGridsquare: myGridsquare,
                stationProfileId: stationProfileId,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivationsTable, ActivationRow>(table),
                  $$ActivationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                stationProfileId = false,
                qsosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (qsosRefs) db.qsos],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$ActivationsTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$ActivationsTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (stationProfileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.stationProfileId,
                            referencedTable: $$ActivationsTableReferences
                                ._stationProfileIdTable(db),
                            referencedColumn: $$ActivationsTableReferences
                                ._stationProfileIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (qsosRefs)
                        await $_getPrefetchedData<
                          ActivationRow,
                          $ActivationsTable,
                          QsoRow
                        >(
                          currentTable: table,
                          referencedTable: $$ActivationsTableReferences
                              ._qsosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivationsTableReferences(
                                db,
                                table,
                                p0,
                              ).qsosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ActivationsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ActivationsTable,
      ActivationRow,
      $$ActivationsTableFilterComposer,
      $$ActivationsTableOrderingComposer,
      $$ActivationsTableAnnotationComposer,
      $$ActivationsTableCreateCompanionBuilder,
      $$ActivationsTableUpdateCompanionBuilder,
      (ActivationRow, $$ActivationsTableReferences),
      ActivationRow,
      PrefetchHooks Function({
        bool accountId,
        bool stationProfileId,
        bool qsosRefs,
      })
    >;
typedef $$QsosTableCreateCompanionBuilder = QsosCompanion Function({
  required String originDeviceId,
  required String hlcCreated,
  required String hlcModified,
  Value<int> rev,
  Value<int?> deletedAt,
  required String id,
  required String accountId,
  Value<String?> stationProfileId,
  required String call,
  required int timeOn,
  Value<int?> timeOff,
  required String band,
  Value<String?> bandRx,
  required String mode,
  Value<String?> submode,
  Value<int?> freqHz,
  Value<int?> freqRxHz,
  Value<String?> rstSent,
  Value<String?> rstRcvd,
  Value<String?> name,
  Value<String?> qth,
  Value<String?> gridsquare,
  Value<int?> dxcc,
  Value<int?> cqz,
  Value<int?> ituz,
  Value<String?> state,
  Value<String?> cnty,
  Value<String?> country,
  Value<String?> cont,
  Value<String?> darcDok,
  Value<String?> iota,
  Value<String?> sotaRef,
  Value<String?> potaRef,
  Value<String?> wwffRef,
  Value<String?> sig,
  Value<String?> sigInfo,
  Value<String?> mySotaRef,
  Value<String?> myPotaRef,
  Value<String?> myWwffRef,
  Value<String?> mySig,
  Value<String?> mySigInfo,
  Value<String?> stationCallsign,
  Value<String?> operator,
  Value<String?> myGridsquare,
  Value<double?> txPwr,
  Value<String?> contestId,
  Value<int?> srx,
  Value<int?> stx,
  Value<String?> srxString,
  Value<String?> stxString,
  Value<String?> check,
  Value<String?> qsoClass,
  Value<String?> precedence,
  Value<String?> arrlSect,
  Value<String?> propMode,
  Value<String?> satName,
  Value<String?> satMode,
  Value<String?> comment,
  Value<String?> notes,
  Value<String?> qslVia,
  Value<String> adifExtra,
  Value<String?> contestSessionId,
  Value<String?> activationId,
  Value<String> source,
  Value<int> rowid,
});
typedef $$QsosTableUpdateCompanionBuilder = QsosCompanion Function({
  Value<String> originDeviceId,
  Value<String> hlcCreated,
  Value<String> hlcModified,
  Value<int> rev,
  Value<int?> deletedAt,
  Value<String> id,
  Value<String> accountId,
  Value<String?> stationProfileId,
  Value<String> call,
  Value<int> timeOn,
  Value<int?> timeOff,
  Value<String> band,
  Value<String?> bandRx,
  Value<String> mode,
  Value<String?> submode,
  Value<int?> freqHz,
  Value<int?> freqRxHz,
  Value<String?> rstSent,
  Value<String?> rstRcvd,
  Value<String?> name,
  Value<String?> qth,
  Value<String?> gridsquare,
  Value<int?> dxcc,
  Value<int?> cqz,
  Value<int?> ituz,
  Value<String?> state,
  Value<String?> cnty,
  Value<String?> country,
  Value<String?> cont,
  Value<String?> darcDok,
  Value<String?> iota,
  Value<String?> sotaRef,
  Value<String?> potaRef,
  Value<String?> wwffRef,
  Value<String?> sig,
  Value<String?> sigInfo,
  Value<String?> mySotaRef,
  Value<String?> myPotaRef,
  Value<String?> myWwffRef,
  Value<String?> mySig,
  Value<String?> mySigInfo,
  Value<String?> stationCallsign,
  Value<String?> operator,
  Value<String?> myGridsquare,
  Value<double?> txPwr,
  Value<String?> contestId,
  Value<int?> srx,
  Value<int?> stx,
  Value<String?> srxString,
  Value<String?> stxString,
  Value<String?> check,
  Value<String?> qsoClass,
  Value<String?> precedence,
  Value<String?> arrlSect,
  Value<String?> propMode,
  Value<String?> satName,
  Value<String?> satMode,
  Value<String?> comment,
  Value<String?> notes,
  Value<String?> qslVia,
  Value<String> adifExtra,
  Value<String?> contestSessionId,
  Value<String?> activationId,
  Value<String> source,
  Value<int> rowid,
});

final class $$QsosTableReferences
    extends BaseReferences<_$TidelineDatabase, $QsosTable, QsoRow> {
  $$QsosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$TidelineDatabase db) =>
      db.accounts.createAlias('qsos__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StationProfilesTable _stationProfileIdTable(_$TidelineDatabase db) =>
      db.stationProfiles.createAlias(
        'qsos__station_profile_id__station_profiles__id',
      );

  $$StationProfilesTableProcessedTableManager? get stationProfileId {
    final $_column = $_itemColumn<String>('station_profile_id');
    if ($_column == null) return null;
    final manager = $$StationProfilesTableTableManager(
      $_db,
      $_db.stationProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stationProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContestSessionsTable _contestSessionIdTable(_$TidelineDatabase db) =>
      db.contestSessions.createAlias(
        'qsos__contest_session_id__contest_sessions__id',
      );

  $$ContestSessionsTableProcessedTableManager? get contestSessionId {
    final $_column = $_itemColumn<String>('contest_session_id');
    if ($_column == null) return null;
    final manager = $$ContestSessionsTableTableManager(
      $_db,
      $_db.contestSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contestSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActivationsTable _activationIdTable(_$TidelineDatabase db) =>
      db.activations.createAlias('qsos__activation_id__activations__id');

  $$ActivationsTableProcessedTableManager? get activationId {
    final $_column = $_itemColumn<String>('activation_id');
    if ($_column == null) return null;
    final manager = $$ActivationsTableTableManager(
      $_db,
      $_db.activations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QsoSyncTable, List<QsoSyncRow>> _qsoSyncRefsTable(
    _$TidelineDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.qsoSync,
    aliasName: 'qsos__id__qso_sync__qso_id',
  );

  $$QsoSyncTableProcessedTableManager get qsoSyncRefs {
    final manager = $$QsoSyncTableTableManager(
      $_db,
      $_db.qsoSync,
    ).filter((f) => f.qsoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_qsoSyncRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QsosTableFilterComposer
    extends Composer<_$TidelineDatabase, $QsosTable> {
  $$QsosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get call => $composableBuilder(
    column: $table.call,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeOn => $composableBuilder(
    column: $table.timeOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeOff => $composableBuilder(
    column: $table.timeOff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get band => $composableBuilder(
    column: $table.band,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bandRx => $composableBuilder(
    column: $table.bandRx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submode => $composableBuilder(
    column: $table.submode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freqHz => $composableBuilder(
    column: $table.freqHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freqRxHz => $composableBuilder(
    column: $table.freqRxHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rstSent => $composableBuilder(
    column: $table.rstSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rstRcvd => $composableBuilder(
    column: $table.rstRcvd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qth => $composableBuilder(
    column: $table.qth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cqz => $composableBuilder(
    column: $table.cqz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ituz => $composableBuilder(
    column: $table.ituz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnty => $composableBuilder(
    column: $table.cnty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cont => $composableBuilder(
    column: $table.cont,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get darcDok => $composableBuilder(
    column: $table.darcDok,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iota => $composableBuilder(
    column: $table.iota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sotaRef => $composableBuilder(
    column: $table.sotaRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get potaRef => $composableBuilder(
    column: $table.potaRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wwffRef => $composableBuilder(
    column: $table.wwffRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sigInfo => $composableBuilder(
    column: $table.sigInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mySotaRef => $composableBuilder(
    column: $table.mySotaRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myPotaRef => $composableBuilder(
    column: $table.myPotaRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myWwffRef => $composableBuilder(
    column: $table.myWwffRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mySig => $composableBuilder(
    column: $table.mySig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mySigInfo => $composableBuilder(
    column: $table.mySigInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stationCallsign => $composableBuilder(
    column: $table.stationCallsign,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operator => $composableBuilder(
    column: $table.operator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myGridsquare => $composableBuilder(
    column: $table.myGridsquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get txPwr => $composableBuilder(
    column: $table.txPwr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contestId => $composableBuilder(
    column: $table.contestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get srx => $composableBuilder(
    column: $table.srx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stx => $composableBuilder(
    column: $table.stx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get srxString => $composableBuilder(
    column: $table.srxString,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stxString => $composableBuilder(
    column: $table.stxString,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get check => $composableBuilder(
    column: $table.check,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qsoClass => $composableBuilder(
    column: $table.qsoClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get precedence => $composableBuilder(
    column: $table.precedence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrlSect => $composableBuilder(
    column: $table.arrlSect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propMode => $composableBuilder(
    column: $table.propMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get satName => $composableBuilder(
    column: $table.satName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get satMode => $composableBuilder(
    column: $table.satMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qslVia => $composableBuilder(
    column: $table.qslVia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adifExtra => $composableBuilder(
    column: $table.adifExtra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableFilterComposer get stationProfileId {
    final $$StationProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableFilterComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContestSessionsTableFilterComposer get contestSessionId {
    final $$ContestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contestSessionId,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivationsTableFilterComposer get activationId {
    final $$ActivationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activationId,
      referencedTable: $db.activations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivationsTableFilterComposer(
            $db: $db,
            $table: $db.activations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> qsoSyncRefs(
    Expression<bool> Function($$QsoSyncTableFilterComposer f) f,
  ) {
    final $$QsoSyncTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsoSync,
      getReferencedColumn: (t) => t.qsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsoSyncTableFilterComposer(
            $db: $db,
            $table: $db.qsoSync,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QsosTableOrderingComposer
    extends Composer<_$TidelineDatabase, $QsosTable> {
  $$QsosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get call => $composableBuilder(
    column: $table.call,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeOn => $composableBuilder(
    column: $table.timeOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeOff => $composableBuilder(
    column: $table.timeOff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get band => $composableBuilder(
    column: $table.band,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bandRx => $composableBuilder(
    column: $table.bandRx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submode => $composableBuilder(
    column: $table.submode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freqHz => $composableBuilder(
    column: $table.freqHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freqRxHz => $composableBuilder(
    column: $table.freqRxHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rstSent => $composableBuilder(
    column: $table.rstSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rstRcvd => $composableBuilder(
    column: $table.rstRcvd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qth => $composableBuilder(
    column: $table.qth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cqz => $composableBuilder(
    column: $table.cqz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ituz => $composableBuilder(
    column: $table.ituz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnty => $composableBuilder(
    column: $table.cnty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cont => $composableBuilder(
    column: $table.cont,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get darcDok => $composableBuilder(
    column: $table.darcDok,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iota => $composableBuilder(
    column: $table.iota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sotaRef => $composableBuilder(
    column: $table.sotaRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get potaRef => $composableBuilder(
    column: $table.potaRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wwffRef => $composableBuilder(
    column: $table.wwffRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sigInfo => $composableBuilder(
    column: $table.sigInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mySotaRef => $composableBuilder(
    column: $table.mySotaRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myPotaRef => $composableBuilder(
    column: $table.myPotaRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myWwffRef => $composableBuilder(
    column: $table.myWwffRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mySig => $composableBuilder(
    column: $table.mySig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mySigInfo => $composableBuilder(
    column: $table.mySigInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stationCallsign => $composableBuilder(
    column: $table.stationCallsign,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operator => $composableBuilder(
    column: $table.operator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myGridsquare => $composableBuilder(
    column: $table.myGridsquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get txPwr => $composableBuilder(
    column: $table.txPwr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contestId => $composableBuilder(
    column: $table.contestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get srx => $composableBuilder(
    column: $table.srx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stx => $composableBuilder(
    column: $table.stx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get srxString => $composableBuilder(
    column: $table.srxString,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stxString => $composableBuilder(
    column: $table.stxString,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get check => $composableBuilder(
    column: $table.check,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qsoClass => $composableBuilder(
    column: $table.qsoClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get precedence => $composableBuilder(
    column: $table.precedence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrlSect => $composableBuilder(
    column: $table.arrlSect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propMode => $composableBuilder(
    column: $table.propMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get satName => $composableBuilder(
    column: $table.satName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get satMode => $composableBuilder(
    column: $table.satMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qslVia => $composableBuilder(
    column: $table.qslVia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adifExtra => $composableBuilder(
    column: $table.adifExtra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableOrderingComposer get stationProfileId {
    final $$StationProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContestSessionsTableOrderingComposer get contestSessionId {
    final $$ContestSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contestSessionId,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivationsTableOrderingComposer get activationId {
    final $$ActivationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activationId,
      referencedTable: $db.activations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivationsTableOrderingComposer(
            $db: $db,
            $table: $db.activations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QsosTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $QsosTable> {
  $$QsosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcCreated => $composableBuilder(
    column: $table.hlcCreated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcModified => $composableBuilder(
    column: $table.hlcModified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get call =>
      $composableBuilder(column: $table.call, builder: (column) => column);

  GeneratedColumn<int> get timeOn =>
      $composableBuilder(column: $table.timeOn, builder: (column) => column);

  GeneratedColumn<int> get timeOff =>
      $composableBuilder(column: $table.timeOff, builder: (column) => column);

  GeneratedColumn<String> get band =>
      $composableBuilder(column: $table.band, builder: (column) => column);

  GeneratedColumn<String> get bandRx =>
      $composableBuilder(column: $table.bandRx, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get submode =>
      $composableBuilder(column: $table.submode, builder: (column) => column);

  GeneratedColumn<int> get freqHz =>
      $composableBuilder(column: $table.freqHz, builder: (column) => column);

  GeneratedColumn<int> get freqRxHz =>
      $composableBuilder(column: $table.freqRxHz, builder: (column) => column);

  GeneratedColumn<String> get rstSent =>
      $composableBuilder(column: $table.rstSent, builder: (column) => column);

  GeneratedColumn<String> get rstRcvd =>
      $composableBuilder(column: $table.rstRcvd, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get qth =>
      $composableBuilder(column: $table.qth, builder: (column) => column);

  GeneratedColumn<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dxcc =>
      $composableBuilder(column: $table.dxcc, builder: (column) => column);

  GeneratedColumn<int> get cqz =>
      $composableBuilder(column: $table.cqz, builder: (column) => column);

  GeneratedColumn<int> get ituz =>
      $composableBuilder(column: $table.ituz, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get cnty =>
      $composableBuilder(column: $table.cnty, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get cont =>
      $composableBuilder(column: $table.cont, builder: (column) => column);

  GeneratedColumn<String> get darcDok =>
      $composableBuilder(column: $table.darcDok, builder: (column) => column);

  GeneratedColumn<String> get iota =>
      $composableBuilder(column: $table.iota, builder: (column) => column);

  GeneratedColumn<String> get sotaRef =>
      $composableBuilder(column: $table.sotaRef, builder: (column) => column);

  GeneratedColumn<String> get potaRef =>
      $composableBuilder(column: $table.potaRef, builder: (column) => column);

  GeneratedColumn<String> get wwffRef =>
      $composableBuilder(column: $table.wwffRef, builder: (column) => column);

  GeneratedColumn<String> get sig =>
      $composableBuilder(column: $table.sig, builder: (column) => column);

  GeneratedColumn<String> get sigInfo =>
      $composableBuilder(column: $table.sigInfo, builder: (column) => column);

  GeneratedColumn<String> get mySotaRef =>
      $composableBuilder(column: $table.mySotaRef, builder: (column) => column);

  GeneratedColumn<String> get myPotaRef =>
      $composableBuilder(column: $table.myPotaRef, builder: (column) => column);

  GeneratedColumn<String> get myWwffRef =>
      $composableBuilder(column: $table.myWwffRef, builder: (column) => column);

  GeneratedColumn<String> get mySig =>
      $composableBuilder(column: $table.mySig, builder: (column) => column);

  GeneratedColumn<String> get mySigInfo =>
      $composableBuilder(column: $table.mySigInfo, builder: (column) => column);

  GeneratedColumn<String> get stationCallsign => $composableBuilder(
    column: $table.stationCallsign,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operator =>
      $composableBuilder(column: $table.operator, builder: (column) => column);

  GeneratedColumn<String> get myGridsquare => $composableBuilder(
    column: $table.myGridsquare,
    builder: (column) => column,
  );

  GeneratedColumn<double> get txPwr =>
      $composableBuilder(column: $table.txPwr, builder: (column) => column);

  GeneratedColumn<String> get contestId =>
      $composableBuilder(column: $table.contestId, builder: (column) => column);

  GeneratedColumn<int> get srx =>
      $composableBuilder(column: $table.srx, builder: (column) => column);

  GeneratedColumn<int> get stx =>
      $composableBuilder(column: $table.stx, builder: (column) => column);

  GeneratedColumn<String> get srxString =>
      $composableBuilder(column: $table.srxString, builder: (column) => column);

  GeneratedColumn<String> get stxString =>
      $composableBuilder(column: $table.stxString, builder: (column) => column);

  GeneratedColumn<String> get check =>
      $composableBuilder(column: $table.check, builder: (column) => column);

  GeneratedColumn<String> get qsoClass =>
      $composableBuilder(column: $table.qsoClass, builder: (column) => column);

  GeneratedColumn<String> get precedence => $composableBuilder(
    column: $table.precedence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arrlSect =>
      $composableBuilder(column: $table.arrlSect, builder: (column) => column);

  GeneratedColumn<String> get propMode =>
      $composableBuilder(column: $table.propMode, builder: (column) => column);

  GeneratedColumn<String> get satName =>
      $composableBuilder(column: $table.satName, builder: (column) => column);

  GeneratedColumn<String> get satMode =>
      $composableBuilder(column: $table.satMode, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get qslVia =>
      $composableBuilder(column: $table.qslVia, builder: (column) => column);

  GeneratedColumn<String> get adifExtra =>
      $composableBuilder(column: $table.adifExtra, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationProfilesTableAnnotationComposer get stationProfileId {
    final $$StationProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationProfileId,
      referencedTable: $db.stationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.stationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContestSessionsTableAnnotationComposer get contestSessionId {
    final $$ContestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contestSessionId,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivationsTableAnnotationComposer get activationId {
    final $$ActivationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activationId,
      referencedTable: $db.activations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivationsTableAnnotationComposer(
            $db: $db,
            $table: $db.activations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> qsoSyncRefs<T extends Object>(
    Expression<T> Function($$QsoSyncTableAnnotationComposer a) f,
  ) {
    final $$QsoSyncTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.qsoSync,
      getReferencedColumn: (t) => t.qsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsoSyncTableAnnotationComposer(
            $db: $db,
            $table: $db.qsoSync,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QsosTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $QsosTable,
          QsoRow,
          $$QsosTableFilterComposer,
          $$QsosTableOrderingComposer,
          $$QsosTableAnnotationComposer,
          $$QsosTableCreateCompanionBuilder,
          $$QsosTableUpdateCompanionBuilder,
          (QsoRow, $$QsosTableReferences),
          QsoRow,
          PrefetchHooks Function({
            bool accountId,
            bool stationProfileId,
            bool contestSessionId,
            bool activationId,
            bool qsoSyncRefs,
          })
        > {
  $$QsosTableTableManager(_$TidelineDatabase db, $QsosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QsosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QsosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QsosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> originDeviceId = const Value.absent(),
                Value<String> hlcCreated = const Value.absent(),
                Value<String> hlcModified = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> stationProfileId = const Value.absent(),
                Value<String> call = const Value.absent(),
                Value<int> timeOn = const Value.absent(),
                Value<int?> timeOff = const Value.absent(),
                Value<String> band = const Value.absent(),
                Value<String?> bandRx = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> submode = const Value.absent(),
                Value<int?> freqHz = const Value.absent(),
                Value<int?> freqRxHz = const Value.absent(),
                Value<String?> rstSent = const Value.absent(),
                Value<String?> rstRcvd = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> qth = const Value.absent(),
                Value<String?> gridsquare = const Value.absent(),
                Value<int?> dxcc = const Value.absent(),
                Value<int?> cqz = const Value.absent(),
                Value<int?> ituz = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> cnty = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> cont = const Value.absent(),
                Value<String?> darcDok = const Value.absent(),
                Value<String?> iota = const Value.absent(),
                Value<String?> sotaRef = const Value.absent(),
                Value<String?> potaRef = const Value.absent(),
                Value<String?> wwffRef = const Value.absent(),
                Value<String?> sig = const Value.absent(),
                Value<String?> sigInfo = const Value.absent(),
                Value<String?> mySotaRef = const Value.absent(),
                Value<String?> myPotaRef = const Value.absent(),
                Value<String?> myWwffRef = const Value.absent(),
                Value<String?> mySig = const Value.absent(),
                Value<String?> mySigInfo = const Value.absent(),
                Value<String?> stationCallsign = const Value.absent(),
                Value<String?> operator = const Value.absent(),
                Value<String?> myGridsquare = const Value.absent(),
                Value<double?> txPwr = const Value.absent(),
                Value<String?> contestId = const Value.absent(),
                Value<int?> srx = const Value.absent(),
                Value<int?> stx = const Value.absent(),
                Value<String?> srxString = const Value.absent(),
                Value<String?> stxString = const Value.absent(),
                Value<String?> check = const Value.absent(),
                Value<String?> qsoClass = const Value.absent(),
                Value<String?> precedence = const Value.absent(),
                Value<String?> arrlSect = const Value.absent(),
                Value<String?> propMode = const Value.absent(),
                Value<String?> satName = const Value.absent(),
                Value<String?> satMode = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> qslVia = const Value.absent(),
                Value<String> adifExtra = const Value.absent(),
                Value<String?> contestSessionId = const Value.absent(),
                Value<String?> activationId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QsosCompanion(
                originDeviceId: originDeviceId,
                hlcCreated: hlcCreated,
                hlcModified: hlcModified,
                rev: rev,
                deletedAt: deletedAt,
                id: id,
                accountId: accountId,
                stationProfileId: stationProfileId,
                call: call,
                timeOn: timeOn,
                timeOff: timeOff,
                band: band,
                bandRx: bandRx,
                mode: mode,
                submode: submode,
                freqHz: freqHz,
                freqRxHz: freqRxHz,
                rstSent: rstSent,
                rstRcvd: rstRcvd,
                name: name,
                qth: qth,
                gridsquare: gridsquare,
                dxcc: dxcc,
                cqz: cqz,
                ituz: ituz,
                state: state,
                cnty: cnty,
                country: country,
                cont: cont,
                darcDok: darcDok,
                iota: iota,
                sotaRef: sotaRef,
                potaRef: potaRef,
                wwffRef: wwffRef,
                sig: sig,
                sigInfo: sigInfo,
                mySotaRef: mySotaRef,
                myPotaRef: myPotaRef,
                myWwffRef: myWwffRef,
                mySig: mySig,
                mySigInfo: mySigInfo,
                stationCallsign: stationCallsign,
                operator: operator,
                myGridsquare: myGridsquare,
                txPwr: txPwr,
                contestId: contestId,
                srx: srx,
                stx: stx,
                srxString: srxString,
                stxString: stxString,
                check: check,
                qsoClass: qsoClass,
                precedence: precedence,
                arrlSect: arrlSect,
                propMode: propMode,
                satName: satName,
                satMode: satMode,
                comment: comment,
                notes: notes,
                qslVia: qslVia,
                adifExtra: adifExtra,
                contestSessionId: contestSessionId,
                activationId: activationId,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String originDeviceId,
                required String hlcCreated,
                required String hlcModified,
                Value<int> rev = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                required String id,
                required String accountId,
                Value<String?> stationProfileId = const Value.absent(),
                required String call,
                required int timeOn,
                Value<int?> timeOff = const Value.absent(),
                required String band,
                Value<String?> bandRx = const Value.absent(),
                required String mode,
                Value<String?> submode = const Value.absent(),
                Value<int?> freqHz = const Value.absent(),
                Value<int?> freqRxHz = const Value.absent(),
                Value<String?> rstSent = const Value.absent(),
                Value<String?> rstRcvd = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> qth = const Value.absent(),
                Value<String?> gridsquare = const Value.absent(),
                Value<int?> dxcc = const Value.absent(),
                Value<int?> cqz = const Value.absent(),
                Value<int?> ituz = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> cnty = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> cont = const Value.absent(),
                Value<String?> darcDok = const Value.absent(),
                Value<String?> iota = const Value.absent(),
                Value<String?> sotaRef = const Value.absent(),
                Value<String?> potaRef = const Value.absent(),
                Value<String?> wwffRef = const Value.absent(),
                Value<String?> sig = const Value.absent(),
                Value<String?> sigInfo = const Value.absent(),
                Value<String?> mySotaRef = const Value.absent(),
                Value<String?> myPotaRef = const Value.absent(),
                Value<String?> myWwffRef = const Value.absent(),
                Value<String?> mySig = const Value.absent(),
                Value<String?> mySigInfo = const Value.absent(),
                Value<String?> stationCallsign = const Value.absent(),
                Value<String?> operator = const Value.absent(),
                Value<String?> myGridsquare = const Value.absent(),
                Value<double?> txPwr = const Value.absent(),
                Value<String?> contestId = const Value.absent(),
                Value<int?> srx = const Value.absent(),
                Value<int?> stx = const Value.absent(),
                Value<String?> srxString = const Value.absent(),
                Value<String?> stxString = const Value.absent(),
                Value<String?> check = const Value.absent(),
                Value<String?> qsoClass = const Value.absent(),
                Value<String?> precedence = const Value.absent(),
                Value<String?> arrlSect = const Value.absent(),
                Value<String?> propMode = const Value.absent(),
                Value<String?> satName = const Value.absent(),
                Value<String?> satMode = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> qslVia = const Value.absent(),
                Value<String> adifExtra = const Value.absent(),
                Value<String?> contestSessionId = const Value.absent(),
                Value<String?> activationId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QsosCompanion.insert(
                originDeviceId: originDeviceId,
                hlcCreated: hlcCreated,
                hlcModified: hlcModified,
                rev: rev,
                deletedAt: deletedAt,
                id: id,
                accountId: accountId,
                stationProfileId: stationProfileId,
                call: call,
                timeOn: timeOn,
                timeOff: timeOff,
                band: band,
                bandRx: bandRx,
                mode: mode,
                submode: submode,
                freqHz: freqHz,
                freqRxHz: freqRxHz,
                rstSent: rstSent,
                rstRcvd: rstRcvd,
                name: name,
                qth: qth,
                gridsquare: gridsquare,
                dxcc: dxcc,
                cqz: cqz,
                ituz: ituz,
                state: state,
                cnty: cnty,
                country: country,
                cont: cont,
                darcDok: darcDok,
                iota: iota,
                sotaRef: sotaRef,
                potaRef: potaRef,
                wwffRef: wwffRef,
                sig: sig,
                sigInfo: sigInfo,
                mySotaRef: mySotaRef,
                myPotaRef: myPotaRef,
                myWwffRef: myWwffRef,
                mySig: mySig,
                mySigInfo: mySigInfo,
                stationCallsign: stationCallsign,
                operator: operator,
                myGridsquare: myGridsquare,
                txPwr: txPwr,
                contestId: contestId,
                srx: srx,
                stx: stx,
                srxString: srxString,
                stxString: stxString,
                check: check,
                qsoClass: qsoClass,
                precedence: precedence,
                arrlSect: arrlSect,
                propMode: propMode,
                satName: satName,
                satMode: satMode,
                comment: comment,
                notes: notes,
                qslVia: qslVia,
                adifExtra: adifExtra,
                contestSessionId: contestSessionId,
                activationId: activationId,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QsosTable, QsoRow>(table),
                  $$QsosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                stationProfileId = false,
                contestSessionId = false,
                activationId = false,
                qsoSyncRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (qsoSyncRefs) db.qsoSync],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$QsosTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$QsosTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (stationProfileId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.stationProfileId,
                            referencedTable: $$QsosTableReferences
                                ._stationProfileIdTable(db),
                            referencedColumn: $$QsosTableReferences
                                ._stationProfileIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (contestSessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contestSessionId,
                            referencedTable: $$QsosTableReferences
                                ._contestSessionIdTable(db),
                            referencedColumn: $$QsosTableReferences
                                ._contestSessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (activationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.activationId,
                            referencedTable: $$QsosTableReferences
                                ._activationIdTable(db),
                            referencedColumn: $$QsosTableReferences
                                ._activationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (qsoSyncRefs)
                        await $_getPrefetchedData<
                          QsoRow,
                          $QsosTable,
                          QsoSyncRow
                        >(
                          currentTable: table,
                          referencedTable: $$QsosTableReferences
                              ._qsoSyncRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QsosTableReferences(db, table, p0).qsoSyncRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.qsoId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QsosTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $QsosTable,
      QsoRow,
      $$QsosTableFilterComposer,
      $$QsosTableOrderingComposer,
      $$QsosTableAnnotationComposer,
      $$QsosTableCreateCompanionBuilder,
      $$QsosTableUpdateCompanionBuilder,
      (QsoRow, $$QsosTableReferences),
      QsoRow,
      PrefetchHooks Function({
        bool accountId,
        bool stationProfileId,
        bool contestSessionId,
        bool activationId,
        bool qsoSyncRefs,
      })
    >;
typedef $$QsoSyncTableCreateCompanionBuilder = QsoSyncCompanion Function({
  required String qsoId,
  required String accountId,
  required String state,
  Value<String> operation,
  Value<int?> remoteQsoId,
  Value<int> attempts,
  Value<int?> nextAttemptAt,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorKey,
  Value<String?> serverMessage,
  Value<int?> syncedRev,
  Value<String?> syncedHash,
  Value<int> rowid,
});
typedef $$QsoSyncTableUpdateCompanionBuilder = QsoSyncCompanion Function({
  Value<String> qsoId,
  Value<String> accountId,
  Value<String> state,
  Value<String> operation,
  Value<int?> remoteQsoId,
  Value<int> attempts,
  Value<int?> nextAttemptAt,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorKey,
  Value<String?> serverMessage,
  Value<int?> syncedRev,
  Value<String?> syncedHash,
  Value<int> rowid,
});

final class $$QsoSyncTableReferences
    extends BaseReferences<_$TidelineDatabase, $QsoSyncTable, QsoSyncRow> {
  $$QsoSyncTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QsosTable _qsoIdTable(_$TidelineDatabase db) =>
      db.qsos.createAlias('qso_sync__qso_id__qsos__id');

  $$QsosTableProcessedTableManager get qsoId {
    final $_column = $_itemColumn<String>('qso_id')!;

    final manager = $$QsosTableTableManager(
      $_db,
      $_db.qsos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_qsoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$TidelineDatabase db) =>
      db.accounts.createAlias('qso_sync__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QsoSyncTableFilterComposer
    extends Composer<_$TidelineDatabase, $QsoSyncTable> {
  $$QsoSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteQsoId => $composableBuilder(
    column: $table.remoteQsoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorKey => $composableBuilder(
    column: $table.lastErrorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverMessage => $composableBuilder(
    column: $table.serverMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedRev => $composableBuilder(
    column: $table.syncedRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedHash => $composableBuilder(
    column: $table.syncedHash,
    builder: (column) => ColumnFilters(column),
  );

  $$QsosTableFilterComposer get qsoId {
    final $$QsosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.qsoId,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableFilterComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QsoSyncTableOrderingComposer
    extends Composer<_$TidelineDatabase, $QsoSyncTable> {
  $$QsoSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteQsoId => $composableBuilder(
    column: $table.remoteQsoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorKey => $composableBuilder(
    column: $table.lastErrorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverMessage => $composableBuilder(
    column: $table.serverMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedRev => $composableBuilder(
    column: $table.syncedRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedHash => $composableBuilder(
    column: $table.syncedHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$QsosTableOrderingComposer get qsoId {
    final $$QsosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.qsoId,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableOrderingComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QsoSyncTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $QsoSyncTable> {
  $$QsoSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get remoteQsoId => $composableBuilder(
    column: $table.remoteQsoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorKey => $composableBuilder(
    column: $table.lastErrorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverMessage => $composableBuilder(
    column: $table.serverMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedRev =>
      $composableBuilder(column: $table.syncedRev, builder: (column) => column);

  GeneratedColumn<String> get syncedHash => $composableBuilder(
    column: $table.syncedHash,
    builder: (column) => column,
  );

  $$QsosTableAnnotationComposer get qsoId {
    final $$QsosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.qsoId,
      referencedTable: $db.qsos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QsosTableAnnotationComposer(
            $db: $db,
            $table: $db.qsos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QsoSyncTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $QsoSyncTable,
          QsoSyncRow,
          $$QsoSyncTableFilterComposer,
          $$QsoSyncTableOrderingComposer,
          $$QsoSyncTableAnnotationComposer,
          $$QsoSyncTableCreateCompanionBuilder,
          $$QsoSyncTableUpdateCompanionBuilder,
          (QsoSyncRow, $$QsoSyncTableReferences),
          QsoSyncRow,
          PrefetchHooks Function({bool qsoId, bool accountId})
        > {
  $$QsoSyncTableTableManager(_$TidelineDatabase db, $QsoSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QsoSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QsoSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QsoSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> qsoId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int?> remoteQsoId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorKey = const Value.absent(),
                Value<String?> serverMessage = const Value.absent(),
                Value<int?> syncedRev = const Value.absent(),
                Value<String?> syncedHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QsoSyncCompanion(
                qsoId: qsoId,
                accountId: accountId,
                state: state,
                operation: operation,
                remoteQsoId: remoteQsoId,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                lastErrorKey: lastErrorKey,
                serverMessage: serverMessage,
                syncedRev: syncedRev,
                syncedHash: syncedHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String qsoId,
                required String accountId,
                required String state,
                Value<String> operation = const Value.absent(),
                Value<int?> remoteQsoId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorKey = const Value.absent(),
                Value<String?> serverMessage = const Value.absent(),
                Value<int?> syncedRev = const Value.absent(),
                Value<String?> syncedHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QsoSyncCompanion.insert(
                qsoId: qsoId,
                accountId: accountId,
                state: state,
                operation: operation,
                remoteQsoId: remoteQsoId,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                lastErrorKey: lastErrorKey,
                serverMessage: serverMessage,
                syncedRev: syncedRev,
                syncedHash: syncedHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QsoSyncTable, QsoSyncRow>(table),
                  $$QsoSyncTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({qsoId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (qsoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.qsoId,
                        referencedTable: $$QsoSyncTableReferences._qsoIdTable(
                          db,
                        ),
                        referencedColumn: $$QsoSyncTableReferences
                            ._qsoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$QsoSyncTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$QsoSyncTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QsoSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $QsoSyncTable,
      QsoSyncRow,
      $$QsoSyncTableFilterComposer,
      $$QsoSyncTableOrderingComposer,
      $$QsoSyncTableAnnotationComposer,
      $$QsoSyncTableCreateCompanionBuilder,
      $$QsoSyncTableUpdateCompanionBuilder,
      (QsoSyncRow, $$QsoSyncTableReferences),
      QsoSyncRow,
      PrefetchHooks Function({bool qsoId, bool accountId})
    >;
typedef $$SyncJournalTableCreateCompanionBuilder =
    SyncJournalCompanion Function({
      Value<int> id,
      required String accountId,
      Value<String?> qsoId,
      required int at,
      required String event,
      Value<String> detail,
    });
typedef $$SyncJournalTableUpdateCompanionBuilder =
    SyncJournalCompanion Function({
      Value<int> id,
      Value<String> accountId,
      Value<String?> qsoId,
      Value<int> at,
      Value<String> event,
      Value<String> detail,
    });

final class $$SyncJournalTableReferences
    extends
        BaseReferences<_$TidelineDatabase, $SyncJournalTable, SyncJournalRow> {
  $$SyncJournalTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$TidelineDatabase db) =>
      db.accounts.createAlias('sync_journal__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncJournalTableFilterComposer
    extends Composer<_$TidelineDatabase, $SyncJournalTable> {
  $$SyncJournalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qsoId => $composableBuilder(
    column: $table.qsoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncJournalTableOrderingComposer
    extends Composer<_$TidelineDatabase, $SyncJournalTable> {
  $$SyncJournalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qsoId => $composableBuilder(
    column: $table.qsoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncJournalTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $SyncJournalTable> {
  $$SyncJournalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get qsoId =>
      $composableBuilder(column: $table.qsoId, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get event =>
      $composableBuilder(column: $table.event, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncJournalTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $SyncJournalTable,
          SyncJournalRow,
          $$SyncJournalTableFilterComposer,
          $$SyncJournalTableOrderingComposer,
          $$SyncJournalTableAnnotationComposer,
          $$SyncJournalTableCreateCompanionBuilder,
          $$SyncJournalTableUpdateCompanionBuilder,
          (SyncJournalRow, $$SyncJournalTableReferences),
          SyncJournalRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$SyncJournalTableTableManager(_$TidelineDatabase db, $SyncJournalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncJournalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncJournalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncJournalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> qsoId = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<String> event = const Value.absent(),
                Value<String> detail = const Value.absent(),
              }) => SyncJournalCompanion(
                id: id,
                accountId: accountId,
                qsoId: qsoId,
                at: at,
                event: event,
                detail: detail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String accountId,
                Value<String?> qsoId = const Value.absent(),
                required int at,
                required String event,
                Value<String> detail = const Value.absent(),
              }) => SyncJournalCompanion.insert(
                id: id,
                accountId: accountId,
                qsoId: qsoId,
                at: at,
                event: event,
                detail: detail,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncJournalTable, SyncJournalRow>(table),
                  $$SyncJournalTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$SyncJournalTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$SyncJournalTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncJournalTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $SyncJournalTable,
      SyncJournalRow,
      $$SyncJournalTableFilterComposer,
      $$SyncJournalTableOrderingComposer,
      $$SyncJournalTableAnnotationComposer,
      $$SyncJournalTableCreateCompanionBuilder,
      $$SyncJournalTableUpdateCompanionBuilder,
      (SyncJournalRow, $$SyncJournalTableReferences),
      SyncJournalRow,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$SerialAllocationsTableCreateCompanionBuilder =
    SerialAllocationsCompanion Function({
      required String sessionId,
      required int serial,
      Value<String?> qsoId,
      required int allocatedAt,
      Value<int> rowid,
    });
typedef $$SerialAllocationsTableUpdateCompanionBuilder =
    SerialAllocationsCompanion Function({
      Value<String> sessionId,
      Value<int> serial,
      Value<String?> qsoId,
      Value<int> allocatedAt,
      Value<int> rowid,
    });

final class $$SerialAllocationsTableReferences
    extends
        BaseReferences<
          _$TidelineDatabase,
          $SerialAllocationsTable,
          SerialAllocationRow
        > {
  $$SerialAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContestSessionsTable _sessionIdTable(_$TidelineDatabase db) => db
      .contestSessions
      .createAlias('serial_allocations__session_id__contest_sessions__id');

  $$ContestSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$ContestSessionsTableTableManager(
      $_db,
      $_db.contestSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SerialAllocationsTableFilterComposer
    extends Composer<_$TidelineDatabase, $SerialAllocationsTable> {
  $$SerialAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qsoId => $composableBuilder(
    column: $table.qsoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allocatedAt => $composableBuilder(
    column: $table.allocatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ContestSessionsTableFilterComposer get sessionId {
    final $$ContestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SerialAllocationsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $SerialAllocationsTable> {
  $$SerialAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qsoId => $composableBuilder(
    column: $table.qsoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allocatedAt => $composableBuilder(
    column: $table.allocatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContestSessionsTableOrderingComposer get sessionId {
    final $$ContestSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SerialAllocationsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $SerialAllocationsTable> {
  $$SerialAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<String> get qsoId =>
      $composableBuilder(column: $table.qsoId, builder: (column) => column);

  GeneratedColumn<int> get allocatedAt => $composableBuilder(
    column: $table.allocatedAt,
    builder: (column) => column,
  );

  $$ContestSessionsTableAnnotationComposer get sessionId {
    final $$ContestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.contestSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contestSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SerialAllocationsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $SerialAllocationsTable,
          SerialAllocationRow,
          $$SerialAllocationsTableFilterComposer,
          $$SerialAllocationsTableOrderingComposer,
          $$SerialAllocationsTableAnnotationComposer,
          $$SerialAllocationsTableCreateCompanionBuilder,
          $$SerialAllocationsTableUpdateCompanionBuilder,
          (SerialAllocationRow, $$SerialAllocationsTableReferences),
          SerialAllocationRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SerialAllocationsTableTableManager(
    _$TidelineDatabase db,
    $SerialAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SerialAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SerialAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SerialAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<int> serial = const Value.absent(),
                Value<String?> qsoId = const Value.absent(),
                Value<int> allocatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SerialAllocationsCompanion(
                sessionId: sessionId,
                serial: serial,
                qsoId: qsoId,
                allocatedAt: allocatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required int serial,
                Value<String?> qsoId = const Value.absent(),
                required int allocatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SerialAllocationsCompanion.insert(
                sessionId: sessionId,
                serial: serial,
                qsoId: qsoId,
                allocatedAt: allocatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SerialAllocationsTable, SerialAllocationRow>(
                    table,
                  ),
                  $$SerialAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SerialAllocationsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SerialAllocationsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SerialAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $SerialAllocationsTable,
      SerialAllocationRow,
      $$SerialAllocationsTableFilterComposer,
      $$SerialAllocationsTableOrderingComposer,
      $$SerialAllocationsTableAnnotationComposer,
      $$SerialAllocationsTableCreateCompanionBuilder,
      $$SerialAllocationsTableUpdateCompanionBuilder,
      (SerialAllocationRow, $$SerialAllocationsTableReferences),
      SerialAllocationRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ProgramRulesTableCreateCompanionBuilder =
    ProgramRulesCompanion Function({
      required String program,
      required int version,
      required String rules,
      Value<int> rowid,
    });
typedef $$ProgramRulesTableUpdateCompanionBuilder =
    ProgramRulesCompanion Function({
      Value<String> program,
      Value<int> version,
      Value<String> rules,
      Value<int> rowid,
    });

class $$ProgramRulesTableFilterComposer
    extends Composer<_$TidelineDatabase, $ProgramRulesTable> {
  $$ProgramRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgramRulesTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ProgramRulesTable> {
  $$ProgramRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgramRulesTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ProgramRulesTable> {
  $$ProgramRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get program =>
      $composableBuilder(column: $table.program, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get rules =>
      $composableBuilder(column: $table.rules, builder: (column) => column);
}

class $$ProgramRulesTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ProgramRulesTable,
          ProgramRuleRow,
          $$ProgramRulesTableFilterComposer,
          $$ProgramRulesTableOrderingComposer,
          $$ProgramRulesTableAnnotationComposer,
          $$ProgramRulesTableCreateCompanionBuilder,
          $$ProgramRulesTableUpdateCompanionBuilder,
          (
            ProgramRuleRow,
            BaseReferences<
              _$TidelineDatabase,
              $ProgramRulesTable,
              ProgramRuleRow
            >,
          ),
          ProgramRuleRow,
          PrefetchHooks Function()
        > {
  $$ProgramRulesTableTableManager(
    _$TidelineDatabase db,
    $ProgramRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> program = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> rules = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramRulesCompanion(
                program: program,
                version: version,
                rules: rules,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String program,
                required int version,
                required String rules,
                Value<int> rowid = const Value.absent(),
              }) => ProgramRulesCompanion.insert(
                program: program,
                version: version,
                rules: rules,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgramRulesTable, ProgramRuleRow>(table),
                  BaseReferences<
                    _$TidelineDatabase,
                    $ProgramRulesTable,
                    ProgramRuleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgramRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ProgramRulesTable,
      ProgramRuleRow,
      $$ProgramRulesTableFilterComposer,
      $$ProgramRulesTableOrderingComposer,
      $$ProgramRulesTableAnnotationComposer,
      $$ProgramRulesTableCreateCompanionBuilder,
      $$ProgramRulesTableUpdateCompanionBuilder,
      (
        ProgramRuleRow,
        BaseReferences<_$TidelineDatabase, $ProgramRulesTable, ProgramRuleRow>,
      ),
      ProgramRuleRow,
      PrefetchHooks Function()
    >;
typedef $$ReferencePacksTableCreateCompanionBuilder =
    ReferencePacksCompanion Function({
      required String id,
      required String kind,
      required String version,
      required String sourceUrl,
      required String sha256,
      required int fetchedAt,
      Value<String?> regionFilter,
      Value<String?> licenceNote,
      Value<int> rowid,
    });
typedef $$ReferencePacksTableUpdateCompanionBuilder =
    ReferencePacksCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> version,
      Value<String> sourceUrl,
      Value<String> sha256,
      Value<int> fetchedAt,
      Value<String?> regionFilter,
      Value<String?> licenceNote,
      Value<int> rowid,
    });

class $$ReferencePacksTableFilterComposer
    extends Composer<_$TidelineDatabase, $ReferencePacksTable> {
  $$ReferencePacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionFilter => $composableBuilder(
    column: $table.regionFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenceNote => $composableBuilder(
    column: $table.licenceNote,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReferencePacksTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ReferencePacksTable> {
  $$ReferencePacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionFilter => $composableBuilder(
    column: $table.regionFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenceNote => $composableBuilder(
    column: $table.licenceNote,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReferencePacksTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ReferencePacksTable> {
  $$ReferencePacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get regionFilter => $composableBuilder(
    column: $table.regionFilter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenceNote => $composableBuilder(
    column: $table.licenceNote,
    builder: (column) => column,
  );
}

class $$ReferencePacksTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ReferencePacksTable,
          ReferencePackRow,
          $$ReferencePacksTableFilterComposer,
          $$ReferencePacksTableOrderingComposer,
          $$ReferencePacksTableAnnotationComposer,
          $$ReferencePacksTableCreateCompanionBuilder,
          $$ReferencePacksTableUpdateCompanionBuilder,
          (
            ReferencePackRow,
            BaseReferences<
              _$TidelineDatabase,
              $ReferencePacksTable,
              ReferencePackRow
            >,
          ),
          ReferencePackRow,
          PrefetchHooks Function()
        > {
  $$ReferencePacksTableTableManager(
    _$TidelineDatabase db,
    $ReferencePacksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferencePacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferencePacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferencePacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<String?> regionFilter = const Value.absent(),
                Value<String?> licenceNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferencePacksCompanion(
                id: id,
                kind: kind,
                version: version,
                sourceUrl: sourceUrl,
                sha256: sha256,
                fetchedAt: fetchedAt,
                regionFilter: regionFilter,
                licenceNote: licenceNote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String version,
                required String sourceUrl,
                required String sha256,
                required int fetchedAt,
                Value<String?> regionFilter = const Value.absent(),
                Value<String?> licenceNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferencePacksCompanion.insert(
                id: id,
                kind: kind,
                version: version,
                sourceUrl: sourceUrl,
                sha256: sha256,
                fetchedAt: fetchedAt,
                regionFilter: regionFilter,
                licenceNote: licenceNote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReferencePacksTable, ReferencePackRow>(table),
                  BaseReferences<
                    _$TidelineDatabase,
                    $ReferencePacksTable,
                    ReferencePackRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReferencePacksTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ReferencePacksTable,
      ReferencePackRow,
      $$ReferencePacksTableFilterComposer,
      $$ReferencePacksTableOrderingComposer,
      $$ReferencePacksTableAnnotationComposer,
      $$ReferencePacksTableCreateCompanionBuilder,
      $$ReferencePacksTableUpdateCompanionBuilder,
      (
        ReferencePackRow,
        BaseReferences<
          _$TidelineDatabase,
          $ReferencePacksTable,
          ReferencePackRow
        >,
      ),
      ReferencePackRow,
      PrefetchHooks Function()
    >;
typedef $$DxccEntitiesTableCreateCompanionBuilder =
    DxccEntitiesCompanion Function({
      Value<int> dxcc,
      required String name,
      required String prefix,
      required int cqz,
      required int ituz,
      required String cont,
      required double lat,
      required double lon,
      Value<bool> deleted,
    });
typedef $$DxccEntitiesTableUpdateCompanionBuilder =
    DxccEntitiesCompanion Function({
      Value<int> dxcc,
      Value<String> name,
      Value<String> prefix,
      Value<int> cqz,
      Value<int> ituz,
      Value<String> cont,
      Value<double> lat,
      Value<double> lon,
      Value<bool> deleted,
    });

final class $$DxccEntitiesTableReferences
    extends
        BaseReferences<_$TidelineDatabase, $DxccEntitiesTable, DxccEntityRow> {
  $$DxccEntitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DxccPrefixesTable, List<DxccPrefixRow>>
  _dxccPrefixesRefsTable(_$TidelineDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dxccPrefixes,
        aliasName: 'dxcc_entities__dxcc__dxcc_prefixes__dxcc',
      );

  $$DxccPrefixesTableProcessedTableManager get dxccPrefixesRefs {
    final manager = $$DxccPrefixesTableTableManager(
      $_db,
      $_db.dxccPrefixes,
    ).filter((f) => f.dxcc.dxcc.sqlEquals($_itemColumn<int>('dxcc')!));

    final cache = $_typedResult.readTableOrNull(_dxccPrefixesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DxccEntitiesTableFilterComposer
    extends Composer<_$TidelineDatabase, $DxccEntitiesTable> {
  $$DxccEntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prefix => $composableBuilder(
    column: $table.prefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cqz => $composableBuilder(
    column: $table.cqz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ituz => $composableBuilder(
    column: $table.ituz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cont => $composableBuilder(
    column: $table.cont,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dxccPrefixesRefs(
    Expression<bool> Function($$DxccPrefixesTableFilterComposer f) f,
  ) {
    final $$DxccPrefixesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dxcc,
      referencedTable: $db.dxccPrefixes,
      getReferencedColumn: (t) => t.dxcc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DxccPrefixesTableFilterComposer(
            $db: $db,
            $table: $db.dxccPrefixes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DxccEntitiesTableOrderingComposer
    extends Composer<_$TidelineDatabase, $DxccEntitiesTable> {
  $$DxccEntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prefix => $composableBuilder(
    column: $table.prefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cqz => $composableBuilder(
    column: $table.cqz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ituz => $composableBuilder(
    column: $table.ituz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cont => $composableBuilder(
    column: $table.cont,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DxccEntitiesTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $DxccEntitiesTable> {
  $$DxccEntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dxcc =>
      $composableBuilder(column: $table.dxcc, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get prefix =>
      $composableBuilder(column: $table.prefix, builder: (column) => column);

  GeneratedColumn<int> get cqz =>
      $composableBuilder(column: $table.cqz, builder: (column) => column);

  GeneratedColumn<int> get ituz =>
      $composableBuilder(column: $table.ituz, builder: (column) => column);

  GeneratedColumn<String> get cont =>
      $composableBuilder(column: $table.cont, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> dxccPrefixesRefs<T extends Object>(
    Expression<T> Function($$DxccPrefixesTableAnnotationComposer a) f,
  ) {
    final $$DxccPrefixesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dxcc,
      referencedTable: $db.dxccPrefixes,
      getReferencedColumn: (t) => t.dxcc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DxccPrefixesTableAnnotationComposer(
            $db: $db,
            $table: $db.dxccPrefixes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DxccEntitiesTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $DxccEntitiesTable,
          DxccEntityRow,
          $$DxccEntitiesTableFilterComposer,
          $$DxccEntitiesTableOrderingComposer,
          $$DxccEntitiesTableAnnotationComposer,
          $$DxccEntitiesTableCreateCompanionBuilder,
          $$DxccEntitiesTableUpdateCompanionBuilder,
          (DxccEntityRow, $$DxccEntitiesTableReferences),
          DxccEntityRow,
          PrefetchHooks Function({bool dxccPrefixesRefs})
        > {
  $$DxccEntitiesTableTableManager(
    _$TidelineDatabase db,
    $DxccEntitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DxccEntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DxccEntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DxccEntitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dxcc = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> prefix = const Value.absent(),
                Value<int> cqz = const Value.absent(),
                Value<int> ituz = const Value.absent(),
                Value<String> cont = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
              }) => DxccEntitiesCompanion(
                dxcc: dxcc,
                name: name,
                prefix: prefix,
                cqz: cqz,
                ituz: ituz,
                cont: cont,
                lat: lat,
                lon: lon,
                deleted: deleted,
              ),
          createCompanionCallback:
              ({
                Value<int> dxcc = const Value.absent(),
                required String name,
                required String prefix,
                required int cqz,
                required int ituz,
                required String cont,
                required double lat,
                required double lon,
                Value<bool> deleted = const Value.absent(),
              }) => DxccEntitiesCompanion.insert(
                dxcc: dxcc,
                name: name,
                prefix: prefix,
                cqz: cqz,
                ituz: ituz,
                cont: cont,
                lat: lat,
                lon: lon,
                deleted: deleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DxccEntitiesTable, DxccEntityRow>(table),
                  $$DxccEntitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dxccPrefixesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dxccPrefixesRefs) db.dxccPrefixes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dxccPrefixesRefs)
                    await $_getPrefetchedData<
                      DxccEntityRow,
                      $DxccEntitiesTable,
                      DxccPrefixRow
                    >(
                      currentTable: table,
                      referencedTable: $$DxccEntitiesTableReferences
                          ._dxccPrefixesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DxccEntitiesTableReferences(
                            db,
                            table,
                            p0,
                          ).dxccPrefixesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dxcc == item.dxcc),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DxccEntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $DxccEntitiesTable,
      DxccEntityRow,
      $$DxccEntitiesTableFilterComposer,
      $$DxccEntitiesTableOrderingComposer,
      $$DxccEntitiesTableAnnotationComposer,
      $$DxccEntitiesTableCreateCompanionBuilder,
      $$DxccEntitiesTableUpdateCompanionBuilder,
      (DxccEntityRow, $$DxccEntitiesTableReferences),
      DxccEntityRow,
      PrefetchHooks Function({bool dxccPrefixesRefs})
    >;
typedef $$DxccPrefixesTableCreateCompanionBuilder =
    DxccPrefixesCompanion Function({
      required String prefixOrCall,
      required bool exact,
      required int dxcc,
      Value<int?> cqzOverride,
      Value<int?> ituzOverride,
      Value<int> rowid,
    });
typedef $$DxccPrefixesTableUpdateCompanionBuilder =
    DxccPrefixesCompanion Function({
      Value<String> prefixOrCall,
      Value<bool> exact,
      Value<int> dxcc,
      Value<int?> cqzOverride,
      Value<int?> ituzOverride,
      Value<int> rowid,
    });

final class $$DxccPrefixesTableReferences
    extends
        BaseReferences<_$TidelineDatabase, $DxccPrefixesTable, DxccPrefixRow> {
  $$DxccPrefixesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DxccEntitiesTable _dxccTable(_$TidelineDatabase db) =>
      db.dxccEntities.createAlias('dxcc_prefixes__dxcc__dxcc_entities__dxcc');

  $$DxccEntitiesTableProcessedTableManager get dxcc {
    final $_column = $_itemColumn<int>('dxcc')!;

    final manager = $$DxccEntitiesTableTableManager(
      $_db,
      $_db.dxccEntities,
    ).filter((f) => f.dxcc.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dxccTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DxccPrefixesTableFilterComposer
    extends Composer<_$TidelineDatabase, $DxccPrefixesTable> {
  $$DxccPrefixesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prefixOrCall => $composableBuilder(
    column: $table.prefixOrCall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exact => $composableBuilder(
    column: $table.exact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cqzOverride => $composableBuilder(
    column: $table.cqzOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ituzOverride => $composableBuilder(
    column: $table.ituzOverride,
    builder: (column) => ColumnFilters(column),
  );

  $$DxccEntitiesTableFilterComposer get dxcc {
    final $$DxccEntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dxcc,
      referencedTable: $db.dxccEntities,
      getReferencedColumn: (t) => t.dxcc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DxccEntitiesTableFilterComposer(
            $db: $db,
            $table: $db.dxccEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DxccPrefixesTableOrderingComposer
    extends Composer<_$TidelineDatabase, $DxccPrefixesTable> {
  $$DxccPrefixesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prefixOrCall => $composableBuilder(
    column: $table.prefixOrCall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exact => $composableBuilder(
    column: $table.exact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cqzOverride => $composableBuilder(
    column: $table.cqzOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ituzOverride => $composableBuilder(
    column: $table.ituzOverride,
    builder: (column) => ColumnOrderings(column),
  );

  $$DxccEntitiesTableOrderingComposer get dxcc {
    final $$DxccEntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dxcc,
      referencedTable: $db.dxccEntities,
      getReferencedColumn: (t) => t.dxcc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DxccEntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.dxccEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DxccPrefixesTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $DxccPrefixesTable> {
  $$DxccPrefixesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prefixOrCall => $composableBuilder(
    column: $table.prefixOrCall,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get exact =>
      $composableBuilder(column: $table.exact, builder: (column) => column);

  GeneratedColumn<int> get cqzOverride => $composableBuilder(
    column: $table.cqzOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ituzOverride => $composableBuilder(
    column: $table.ituzOverride,
    builder: (column) => column,
  );

  $$DxccEntitiesTableAnnotationComposer get dxcc {
    final $$DxccEntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dxcc,
      referencedTable: $db.dxccEntities,
      getReferencedColumn: (t) => t.dxcc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DxccEntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.dxccEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DxccPrefixesTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $DxccPrefixesTable,
          DxccPrefixRow,
          $$DxccPrefixesTableFilterComposer,
          $$DxccPrefixesTableOrderingComposer,
          $$DxccPrefixesTableAnnotationComposer,
          $$DxccPrefixesTableCreateCompanionBuilder,
          $$DxccPrefixesTableUpdateCompanionBuilder,
          (DxccPrefixRow, $$DxccPrefixesTableReferences),
          DxccPrefixRow,
          PrefetchHooks Function({bool dxcc})
        > {
  $$DxccPrefixesTableTableManager(
    _$TidelineDatabase db,
    $DxccPrefixesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DxccPrefixesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DxccPrefixesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DxccPrefixesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> prefixOrCall = const Value.absent(),
                Value<bool> exact = const Value.absent(),
                Value<int> dxcc = const Value.absent(),
                Value<int?> cqzOverride = const Value.absent(),
                Value<int?> ituzOverride = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DxccPrefixesCompanion(
                prefixOrCall: prefixOrCall,
                exact: exact,
                dxcc: dxcc,
                cqzOverride: cqzOverride,
                ituzOverride: ituzOverride,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String prefixOrCall,
                required bool exact,
                required int dxcc,
                Value<int?> cqzOverride = const Value.absent(),
                Value<int?> ituzOverride = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DxccPrefixesCompanion.insert(
                prefixOrCall: prefixOrCall,
                exact: exact,
                dxcc: dxcc,
                cqzOverride: cqzOverride,
                ituzOverride: ituzOverride,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DxccPrefixesTable, DxccPrefixRow>(table),
                  $$DxccPrefixesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dxcc = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dxcc) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.dxcc,
                        referencedTable: $$DxccPrefixesTableReferences
                            ._dxccTable(db),
                        referencedColumn: $$DxccPrefixesTableReferences
                            ._dxccTable(db)
                            .dxcc,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DxccPrefixesTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $DxccPrefixesTable,
      DxccPrefixRow,
      $$DxccPrefixesTableFilterComposer,
      $$DxccPrefixesTableOrderingComposer,
      $$DxccPrefixesTableAnnotationComposer,
      $$DxccPrefixesTableCreateCompanionBuilder,
      $$DxccPrefixesTableUpdateCompanionBuilder,
      (DxccPrefixRow, $$DxccPrefixesTableReferences),
      DxccPrefixRow,
      PrefetchHooks Function({bool dxcc})
    >;
typedef $$ProgramReferencesTableCreateCompanionBuilder =
    ProgramReferencesCompanion Function({
      required String program,
      required String ref,
      required String name,
      Value<String?> region,
      Value<double?> lat,
      Value<double?> lon,
      Value<int?> validFrom,
      Value<int?> validTo,
      Value<int> rowid,
    });
typedef $$ProgramReferencesTableUpdateCompanionBuilder =
    ProgramReferencesCompanion Function({
      Value<String> program,
      Value<String> ref,
      Value<String> name,
      Value<String?> region,
      Value<double?> lat,
      Value<double?> lon,
      Value<int?> validFrom,
      Value<int?> validTo,
      Value<int> rowid,
    });

class $$ProgramReferencesTableFilterComposer
    extends Composer<_$TidelineDatabase, $ProgramReferencesTable> {
  $$ProgramReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validTo => $composableBuilder(
    column: $table.validTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgramReferencesTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ProgramReferencesTable> {
  $$ProgramReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validTo => $composableBuilder(
    column: $table.validTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgramReferencesTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ProgramReferencesTable> {
  $$ProgramReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get program =>
      $composableBuilder(column: $table.program, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<int> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => column);

  GeneratedColumn<int> get validTo =>
      $composableBuilder(column: $table.validTo, builder: (column) => column);
}

class $$ProgramReferencesTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ProgramReferencesTable,
          ProgramReferenceRow,
          $$ProgramReferencesTableFilterComposer,
          $$ProgramReferencesTableOrderingComposer,
          $$ProgramReferencesTableAnnotationComposer,
          $$ProgramReferencesTableCreateCompanionBuilder,
          $$ProgramReferencesTableUpdateCompanionBuilder,
          (
            ProgramReferenceRow,
            BaseReferences<
              _$TidelineDatabase,
              $ProgramReferencesTable,
              ProgramReferenceRow
            >,
          ),
          ProgramReferenceRow,
          PrefetchHooks Function()
        > {
  $$ProgramReferencesTableTableManager(
    _$TidelineDatabase db,
    $ProgramReferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramReferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> program = const Value.absent(),
                Value<String> ref = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<int?> validFrom = const Value.absent(),
                Value<int?> validTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramReferencesCompanion(
                program: program,
                ref: ref,
                name: name,
                region: region,
                lat: lat,
                lon: lon,
                validFrom: validFrom,
                validTo: validTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String program,
                required String ref,
                required String name,
                Value<String?> region = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<int?> validFrom = const Value.absent(),
                Value<int?> validTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgramReferencesCompanion.insert(
                program: program,
                ref: ref,
                name: name,
                region: region,
                lat: lat,
                lon: lon,
                validFrom: validFrom,
                validTo: validTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgramReferencesTable, ProgramReferenceRow>(
                    table,
                  ),
                  BaseReferences<
                    _$TidelineDatabase,
                    $ProgramReferencesTable,
                    ProgramReferenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgramReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ProgramReferencesTable,
      ProgramReferenceRow,
      $$ProgramReferencesTableFilterComposer,
      $$ProgramReferencesTableOrderingComposer,
      $$ProgramReferencesTableAnnotationComposer,
      $$ProgramReferencesTableCreateCompanionBuilder,
      $$ProgramReferencesTableUpdateCompanionBuilder,
      (
        ProgramReferenceRow,
        BaseReferences<
          _$TidelineDatabase,
          $ProgramReferencesTable,
          ProgramReferenceRow
        >,
      ),
      ProgramReferenceRow,
      PrefetchHooks Function()
    >;
typedef $$ScpCallsTableCreateCompanionBuilder = ScpCallsCompanion Function({
  required String call,
  Value<int> rowid,
});
typedef $$ScpCallsTableUpdateCompanionBuilder = ScpCallsCompanion Function({
  Value<String> call,
  Value<int> rowid,
});

class $$ScpCallsTableFilterComposer
    extends Composer<_$TidelineDatabase, $ScpCallsTable> {
  $$ScpCallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get call => $composableBuilder(
    column: $table.call,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScpCallsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ScpCallsTable> {
  $$ScpCallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get call => $composableBuilder(
    column: $table.call,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScpCallsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ScpCallsTable> {
  $$ScpCallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get call =>
      $composableBuilder(column: $table.call, builder: (column) => column);
}

class $$ScpCallsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ScpCallsTable,
          ScpCallRow,
          $$ScpCallsTableFilterComposer,
          $$ScpCallsTableOrderingComposer,
          $$ScpCallsTableAnnotationComposer,
          $$ScpCallsTableCreateCompanionBuilder,
          $$ScpCallsTableUpdateCompanionBuilder,
          (
            ScpCallRow,
            BaseReferences<_$TidelineDatabase, $ScpCallsTable, ScpCallRow>,
          ),
          ScpCallRow,
          PrefetchHooks Function()
        > {
  $$ScpCallsTableTableManager(_$TidelineDatabase db, $ScpCallsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScpCallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScpCallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScpCallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> call = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ScpCallsCompanion(call: call, rowid: rowid),
          createCompanionCallback: ({
            required String call,
            Value<int> rowid = const Value.absent(),
          }) => ScpCallsCompanion.insert(call: call, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScpCallsTable, ScpCallRow>(table),
                  BaseReferences<
                    _$TidelineDatabase,
                    $ScpCallsTable,
                    ScpCallRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScpCallsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ScpCallsTable,
      ScpCallRow,
      $$ScpCallsTableFilterComposer,
      $$ScpCallsTableOrderingComposer,
      $$ScpCallsTableAnnotationComposer,
      $$ScpCallsTableCreateCompanionBuilder,
      $$ScpCallsTableUpdateCompanionBuilder,
      (
        ScpCallRow,
        BaseReferences<_$TidelineDatabase, $ScpCallsTable, ScpCallRow>,
      ),
      ScpCallRow,
      PrefetchHooks Function()
    >;
typedef $$WorkedBeforeTableCreateCompanionBuilder =
    WorkedBeforeCompanion Function({
      required String accountId,
      required String call,
      required String band,
      required String mode,
      Value<int?> dxcc,
      Value<String?> gridsquare,
      required int firstTime,
      required String source,
      Value<int> rowid,
    });
typedef $$WorkedBeforeTableUpdateCompanionBuilder =
    WorkedBeforeCompanion Function({
      Value<String> accountId,
      Value<String> call,
      Value<String> band,
      Value<String> mode,
      Value<int?> dxcc,
      Value<String?> gridsquare,
      Value<int> firstTime,
      Value<String> source,
      Value<int> rowid,
    });

final class $$WorkedBeforeTableReferences
    extends
        BaseReferences<
          _$TidelineDatabase,
          $WorkedBeforeTable,
          WorkedBeforeRow
        > {
  $$WorkedBeforeTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$TidelineDatabase db) =>
      db.accounts.createAlias('worked_before__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkedBeforeTableFilterComposer
    extends Composer<_$TidelineDatabase, $WorkedBeforeTable> {
  $$WorkedBeforeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get call => $composableBuilder(
    column: $table.call,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get band => $composableBuilder(
    column: $table.band,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstTime => $composableBuilder(
    column: $table.firstTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkedBeforeTableOrderingComposer
    extends Composer<_$TidelineDatabase, $WorkedBeforeTable> {
  $$WorkedBeforeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get call => $composableBuilder(
    column: $table.call,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get band => $composableBuilder(
    column: $table.band,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dxcc => $composableBuilder(
    column: $table.dxcc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstTime => $composableBuilder(
    column: $table.firstTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkedBeforeTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $WorkedBeforeTable> {
  $$WorkedBeforeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get call =>
      $composableBuilder(column: $table.call, builder: (column) => column);

  GeneratedColumn<String> get band =>
      $composableBuilder(column: $table.band, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get dxcc =>
      $composableBuilder(column: $table.dxcc, builder: (column) => column);

  GeneratedColumn<String> get gridsquare => $composableBuilder(
    column: $table.gridsquare,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstTime =>
      $composableBuilder(column: $table.firstTime, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkedBeforeTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $WorkedBeforeTable,
          WorkedBeforeRow,
          $$WorkedBeforeTableFilterComposer,
          $$WorkedBeforeTableOrderingComposer,
          $$WorkedBeforeTableAnnotationComposer,
          $$WorkedBeforeTableCreateCompanionBuilder,
          $$WorkedBeforeTableUpdateCompanionBuilder,
          (WorkedBeforeRow, $$WorkedBeforeTableReferences),
          WorkedBeforeRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$WorkedBeforeTableTableManager(
    _$TidelineDatabase db,
    $WorkedBeforeTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkedBeforeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkedBeforeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkedBeforeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> call = const Value.absent(),
                Value<String> band = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int?> dxcc = const Value.absent(),
                Value<String?> gridsquare = const Value.absent(),
                Value<int> firstTime = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkedBeforeCompanion(
                accountId: accountId,
                call: call,
                band: band,
                mode: mode,
                dxcc: dxcc,
                gridsquare: gridsquare,
                firstTime: firstTime,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String call,
                required String band,
                required String mode,
                Value<int?> dxcc = const Value.absent(),
                Value<String?> gridsquare = const Value.absent(),
                required int firstTime,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => WorkedBeforeCompanion.insert(
                accountId: accountId,
                call: call,
                band: band,
                mode: mode,
                dxcc: dxcc,
                gridsquare: gridsquare,
                firstTime: firstTime,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkedBeforeTable, WorkedBeforeRow>(table),
                  $$WorkedBeforeTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$WorkedBeforeTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$WorkedBeforeTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkedBeforeTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $WorkedBeforeTable,
      WorkedBeforeRow,
      $$WorkedBeforeTableFilterComposer,
      $$WorkedBeforeTableOrderingComposer,
      $$WorkedBeforeTableAnnotationComposer,
      $$WorkedBeforeTableCreateCompanionBuilder,
      $$WorkedBeforeTableUpdateCompanionBuilder,
      (WorkedBeforeRow, $$WorkedBeforeTableReferences),
      WorkedBeforeRow,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String name,
  required String publicKey,
  required int pairedAt,
  Value<int?> revokedAt,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> publicKey,
  Value<int> pairedAt,
  Value<int?> revokedAt,
  Value<int> rowid,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$TidelineDatabase, $DevicesTable, DeviceRow> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PeerCursorsTable, List<PeerCursorRow>>
  _peerCursorsRefsTable(_$TidelineDatabase db) => MultiTypedResultKey.fromTable(
    db.peerCursors,
    aliasName: 'devices__id__peer_cursors__device_id',
  );

  $$PeerCursorsTableProcessedTableManager get peerCursorsRefs {
    final manager = $$PeerCursorsTableTableManager(
      $_db,
      $_db.peerCursors,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_peerCursorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$TidelineDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> peerCursorsRefs(
    Expression<bool> Function($$PeerCursorsTableFilterComposer f) f,
  ) {
    final $$PeerCursorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.peerCursors,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeerCursorsTableFilterComposer(
            $db: $db,
            $table: $db.peerCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$TidelineDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<int> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<int> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  Expression<T> peerCursorsRefs<T extends Object>(
    Expression<T> Function($$PeerCursorsTableAnnotationComposer a) f,
  ) {
    final $$PeerCursorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.peerCursors,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeerCursorsTableAnnotationComposer(
            $db: $db,
            $table: $db.peerCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $DevicesTable,
          DeviceRow,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (DeviceRow, $$DevicesTableReferences),
          DeviceRow,
          PrefetchHooks Function({bool peerCursorsRefs})
        > {
  $$DevicesTableTableManager(_$TidelineDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<int> pairedAt = const Value.absent(),
                Value<int?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                name: name,
                publicKey: publicKey,
                pairedAt: pairedAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String publicKey,
                required int pairedAt,
                Value<int?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                name: name,
                publicKey: publicKey,
                pairedAt: pairedAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, DeviceRow>(table),
                  $$DevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({peerCursorsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (peerCursorsRefs) db.peerCursors],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (peerCursorsRefs)
                    await $_getPrefetchedData<
                      DeviceRow,
                      $DevicesTable,
                      PeerCursorRow
                    >(
                      currentTable: table,
                      referencedTable: $$DevicesTableReferences
                          ._peerCursorsRefsTable(db),
                      managerFromTypedResult: (p0) => $$DevicesTableReferences(
                        db,
                        table,
                        p0,
                      ).peerCursorsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deviceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $DevicesTable,
      DeviceRow,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (DeviceRow, $$DevicesTableReferences),
      DeviceRow,
      PrefetchHooks Function({bool peerCursorsRefs})
    >;
typedef $$PeerCursorsTableCreateCompanionBuilder =
    PeerCursorsCompanion Function({
      required String deviceId,
      required String lastHlc,
      Value<int> rowid,
    });
typedef $$PeerCursorsTableUpdateCompanionBuilder =
    PeerCursorsCompanion Function({
      Value<String> deviceId,
      Value<String> lastHlc,
      Value<int> rowid,
    });

final class $$PeerCursorsTableReferences
    extends
        BaseReferences<_$TidelineDatabase, $PeerCursorsTable, PeerCursorRow> {
  $$PeerCursorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$TidelineDatabase db) =>
      db.devices.createAlias('peer_cursors__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PeerCursorsTableFilterComposer
    extends Composer<_$TidelineDatabase, $PeerCursorsTable> {
  $$PeerCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastHlc => $composableBuilder(
    column: $table.lastHlc,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeerCursorsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $PeerCursorsTable> {
  $$PeerCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastHlc => $composableBuilder(
    column: $table.lastHlc,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeerCursorsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $PeerCursorsTable> {
  $$PeerCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastHlc =>
      $composableBuilder(column: $table.lastHlc, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeerCursorsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $PeerCursorsTable,
          PeerCursorRow,
          $$PeerCursorsTableFilterComposer,
          $$PeerCursorsTableOrderingComposer,
          $$PeerCursorsTableAnnotationComposer,
          $$PeerCursorsTableCreateCompanionBuilder,
          $$PeerCursorsTableUpdateCompanionBuilder,
          (PeerCursorRow, $$PeerCursorsTableReferences),
          PeerCursorRow,
          PrefetchHooks Function({bool deviceId})
        > {
  $$PeerCursorsTableTableManager(_$TidelineDatabase db, $PeerCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeerCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeerCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeerCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> lastHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeerCursorsCompanion(
                deviceId: deviceId,
                lastHlc: lastHlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String lastHlc,
                Value<int> rowid = const Value.absent(),
              }) => PeerCursorsCompanion.insert(
                deviceId: deviceId,
                lastHlc: lastHlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeerCursorsTable, PeerCursorRow>(table),
                  $$PeerCursorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$PeerCursorsTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$PeerCursorsTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PeerCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $PeerCursorsTable,
      PeerCursorRow,
      $$PeerCursorsTableFilterComposer,
      $$PeerCursorsTableOrderingComposer,
      $$PeerCursorsTableAnnotationComposer,
      $$PeerCursorsTableCreateCompanionBuilder,
      $$PeerCursorsTableUpdateCompanionBuilder,
      (PeerCursorRow, $$PeerCursorsTableReferences),
      PeerCursorRow,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$TidelineDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$TidelineDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$TidelineDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<
                    _$TidelineDatabase,
                    $SettingsTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$TidelineDatabase, $SettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$ShortcutBindingsTableCreateCompanionBuilder =
    ShortcutBindingsCompanion Function({
      required String commandId,
      required String platform,
      required String binding,
      Value<int> rowid,
    });
typedef $$ShortcutBindingsTableUpdateCompanionBuilder =
    ShortcutBindingsCompanion Function({
      Value<String> commandId,
      Value<String> platform,
      Value<String> binding,
      Value<int> rowid,
    });

class $$ShortcutBindingsTableFilterComposer
    extends Composer<_$TidelineDatabase, $ShortcutBindingsTable> {
  $$ShortcutBindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get binding => $composableBuilder(
    column: $table.binding,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShortcutBindingsTableOrderingComposer
    extends Composer<_$TidelineDatabase, $ShortcutBindingsTable> {
  $$ShortcutBindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get binding => $composableBuilder(
    column: $table.binding,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShortcutBindingsTableAnnotationComposer
    extends Composer<_$TidelineDatabase, $ShortcutBindingsTable> {
  $$ShortcutBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get binding =>
      $composableBuilder(column: $table.binding, builder: (column) => column);
}

class $$ShortcutBindingsTableTableManager
    extends
        RootTableManager<
          _$TidelineDatabase,
          $ShortcutBindingsTable,
          ShortcutBindingRow,
          $$ShortcutBindingsTableFilterComposer,
          $$ShortcutBindingsTableOrderingComposer,
          $$ShortcutBindingsTableAnnotationComposer,
          $$ShortcutBindingsTableCreateCompanionBuilder,
          $$ShortcutBindingsTableUpdateCompanionBuilder,
          (
            ShortcutBindingRow,
            BaseReferences<
              _$TidelineDatabase,
              $ShortcutBindingsTable,
              ShortcutBindingRow
            >,
          ),
          ShortcutBindingRow,
          PrefetchHooks Function()
        > {
  $$ShortcutBindingsTableTableManager(
    _$TidelineDatabase db,
    $ShortcutBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShortcutBindingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShortcutBindingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShortcutBindingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> commandId = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> binding = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShortcutBindingsCompanion(
                commandId: commandId,
                platform: platform,
                binding: binding,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String commandId,
                required String platform,
                required String binding,
                Value<int> rowid = const Value.absent(),
              }) => ShortcutBindingsCompanion.insert(
                commandId: commandId,
                platform: platform,
                binding: binding,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShortcutBindingsTable, ShortcutBindingRow>(
                    table,
                  ),
                  BaseReferences<
                    _$TidelineDatabase,
                    $ShortcutBindingsTable,
                    ShortcutBindingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShortcutBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$TidelineDatabase,
      $ShortcutBindingsTable,
      ShortcutBindingRow,
      $$ShortcutBindingsTableFilterComposer,
      $$ShortcutBindingsTableOrderingComposer,
      $$ShortcutBindingsTableAnnotationComposer,
      $$ShortcutBindingsTableCreateCompanionBuilder,
      $$ShortcutBindingsTableUpdateCompanionBuilder,
      (
        ShortcutBindingRow,
        BaseReferences<
          _$TidelineDatabase,
          $ShortcutBindingsTable,
          ShortcutBindingRow
        >,
      ),
      ShortcutBindingRow,
      PrefetchHooks Function()
    >;

class $TidelineDatabaseManager {
  final _$TidelineDatabase _db;
  $TidelineDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$StationProfilesTableTableManager get stationProfiles =>
      $$StationProfilesTableTableManager(_db, _db.stationProfiles);
  $$ContestDefinitionsTableTableManager get contestDefinitions =>
      $$ContestDefinitionsTableTableManager(_db, _db.contestDefinitions);
  $$ContestSessionsTableTableManager get contestSessions =>
      $$ContestSessionsTableTableManager(_db, _db.contestSessions);
  $$ActivationsTableTableManager get activations =>
      $$ActivationsTableTableManager(_db, _db.activations);
  $$QsosTableTableManager get qsos => $$QsosTableTableManager(_db, _db.qsos);
  $$QsoSyncTableTableManager get qsoSync =>
      $$QsoSyncTableTableManager(_db, _db.qsoSync);
  $$SyncJournalTableTableManager get syncJournal =>
      $$SyncJournalTableTableManager(_db, _db.syncJournal);
  $$SerialAllocationsTableTableManager get serialAllocations =>
      $$SerialAllocationsTableTableManager(_db, _db.serialAllocations);
  $$ProgramRulesTableTableManager get programRules =>
      $$ProgramRulesTableTableManager(_db, _db.programRules);
  $$ReferencePacksTableTableManager get referencePacks =>
      $$ReferencePacksTableTableManager(_db, _db.referencePacks);
  $$DxccEntitiesTableTableManager get dxccEntities =>
      $$DxccEntitiesTableTableManager(_db, _db.dxccEntities);
  $$DxccPrefixesTableTableManager get dxccPrefixes =>
      $$DxccPrefixesTableTableManager(_db, _db.dxccPrefixes);
  $$ProgramReferencesTableTableManager get programReferences =>
      $$ProgramReferencesTableTableManager(_db, _db.programReferences);
  $$ScpCallsTableTableManager get scpCalls =>
      $$ScpCallsTableTableManager(_db, _db.scpCalls);
  $$WorkedBeforeTableTableManager get workedBefore =>
      $$WorkedBeforeTableTableManager(_db, _db.workedBefore);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$PeerCursorsTableTableManager get peerCursors =>
      $$PeerCursorsTableTableManager(_db, _db.peerCursors);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ShortcutBindingsTableTableManager get shortcutBindings =>
      $$ShortcutBindingsTableTableManager(_db, _db.shortcutBindings);
}
