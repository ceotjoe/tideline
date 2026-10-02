import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/app_version.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Result of an ADIF import.
@immutable
class ImportSummary {
  /// Creates a summary.
  const new({
    required this.imported,
    required this.duplicates,
    required this.rejected,
    required this.warnings,
  });

  /// QSOs added to the log (they sync like any other QSO).
  final int imported;

  /// Records already in the log (same call, minute, band, mode, station).
  final int duplicates;

  /// Records that could not become QSOs.
  final int rejected;

  /// Recoverable format problems found in the file.
  final int warnings;
}

/// Files larger than this are refused (defence against hostile input).
const int maxImportBytes = 64 * 1024 * 1024;

/// Thrown when an import file is too large.
class ImportTooLargeException implements Exception {
  /// Creates the exception.
  const new();
}

/// ADIF import/export and encrypted backups.
class DataTransfer {
  /// Creates the service.
  new(this._ref);

  final Ref _ref;

  /// Parses [bytes] off the UI thread and adds the QSOs to [account] with
  /// station [stationProfileId].
  Future<ImportSummary> importAdif(
    Uint8List bytes, {
    required Account account,
    required String? stationProfileId,
  }) async {
    if (bytes.length > maxImportBytes) throw const ImportTooLargeException();
    final doc = await Isolate.run(() => const AdiParser().parse(bytes));
    final repo = _ref.read(qsoRepositoryProvider);
    final existing = {
      for (final q in await _ref.read(logProvider.future))
        (q.qso.dupeKey, q.qso.stationProfileId),
    };
    final toImport = <Qso>[];
    var duplicates = 0;
    var rejected = 0;
    for (final record in doc.records) {
      final result = AdifQsoMapping.fromRecord(
        record,
        id: newUuidV4(),
        accountId: account.id,
        stationProfileId: stationProfileId,
      );
      switch (result) {
        case AdifRejected():
          rejected++;
        case AdifImported(:final qso):
          if (existing.add((qso.dupeKey, qso.stationProfileId))) {
            toImport.add(qso);
          } else {
            duplicates++;
          }
      }
    }
    await repo.importAll(toImport);
    return ImportSummary(
      imported: toImport.length,
      duplicates: duplicates,
      rejected: rejected,
      warnings: doc.warnings.length,
    );
  }

  /// The log of [account] as an ADIF file.
  Future<Uint8List> exportAdif(Account account) async {
    final log = await _ref
        .read(qsoRepositoryProvider)
        .watchLog(account.id, limit: 1 << 30)
        .first;
    final records = [
      for (final q in log.reversed) AdifQsoMapping.toRecord(q.qso),
    ];
    const writer = AdiWriter(programVersion: appVersion);
    return Uint8List.fromList(
      utf8.encode(writer.document(records, createdUtc: DateTime.now().toUtc())),
    );
  }

  /// An encrypted backup of everything (tokens excluded).
  Future<Uint8List> createBackup(String passphrase) => BackupService(
    _ref.read(databaseProvider),
    _ref.read(qsoRepositoryProvider),
  ).create(passphrase, nowMillis: DateTime.now().millisecondsSinceEpoch);

  /// Restores a backup.
  Future<RestoreReport> restoreBackup(Uint8List file, String passphrase) =>
      BackupService(
        _ref.read(databaseProvider),
        _ref.read(qsoRepositoryProvider),
      ).restore(
        file,
        passphrase,
        nowMillis: DateTime.now().millisecondsSinceEpoch,
      );

  /// Lets the user pick a file; returns its bytes, or null if cancelled.
  Future<Uint8List?> pickFile(List<String> extensions) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if (file == null) return null;
    return await file.xFile.readAsBytes();
  }

  /// Lets the user choose where to save [bytes]; false if cancelled.
  Future<bool> saveFile(String name, Uint8List bytes, String mime) async =>
      await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: mime) !=
      null;
}

/// The data-transfer service.
final dataTransferProvider = Provider<DataTransfer>(DataTransfer.new);
