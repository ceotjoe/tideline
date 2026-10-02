import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A user definition is at most 256 KiB, checked before the file is read.
const int maxDefinitionBytes = ContestDefinition.maxInputBytes;

/// Why a definition file was not imported.
enum DefinitionProblem {
  /// The file is larger than [maxDefinitionBytes].
  fileTooLarge,

  /// The file could not be read.
  unreadable,

  /// The file is not valid UTF-8.
  notText,

  /// The id belongs to a bundled definition.
  idClash,

  /// The parser rejected the definition; see [DefinitionImportResult.error].
  invalid,
}

/// The outcome of importing one definition file.
class DefinitionImportResult {
  /// A definition was stored.
  const new imported(this.definition, {required this.replaced})
    : problem = null,
      error = null;

  /// Nothing was stored. [error] is set for [DefinitionProblem.invalid].
  const new rejected(this.problem, {this.error})
    : definition = null,
      replaced = false;

  /// What was stored, or null.
  final ContestDefinition? definition;

  /// Whether an earlier user definition with the same id was replaced.
  final bool replaced;

  /// Why nothing was stored, or null.
  final DefinitionProblem? problem;

  /// The parser's finding (reason and JSON path, never the rejected value).
  final ContestDefinitionException? error;
}

/// Imports and deletes user contest definitions.
///
/// The file is untrusted. It is size-capped before it is read, decoded as
/// strict UTF-8 and handed to [ContestDefinitionRepository], which parses it
/// with the strict definition parser (no code, unknown keys rejected).
class ContestDefinitionImporter {
  /// Creates the importer.
  const new(this._ref);

  final Ref _ref;

  /// Lets the user pick a `.json` file and imports it. Returns null when the
  /// picker was cancelled.
  Future<DefinitionImportResult?> pickAndImport() async {
    final Uint8List? bytes;
    try {
      bytes = await _ref.read(dataTransferProvider).pickFile(const [
        'json',
      ], maxBytes: maxDefinitionBytes);
    } on ImportTooLargeException {
      return const DefinitionImportResult.rejected(
        DefinitionProblem.fileTooLarge,
      );
    } on Object {
      return const DefinitionImportResult.rejected(
        DefinitionProblem.unreadable,
      );
    }
    if (bytes == null) return null;
    return await importBytes(bytes);
  }

  /// Imports the definition in [bytes].
  Future<DefinitionImportResult> importBytes(Uint8List bytes) async {
    if (bytes.length > maxDefinitionBytes) {
      return const DefinitionImportResult.rejected(
        DefinitionProblem.fileTooLarge,
      );
    }
    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      return const DefinitionImportResult.rejected(DefinitionProblem.notText);
    }
    final result = await _ref
        .read(contestDefinitionRepositoryProvider)
        .importUserDefinition(text);
    return switch (result) {
      ContestImported(:final definition, :final replaced) =>
        DefinitionImportResult.imported(definition, replaced: replaced),
      ContestImportRejected(error: ContestImportError.idClashesWithBuiltin) =>
        const DefinitionImportResult.rejected(DefinitionProblem.idClash),
      ContestImportRejected(:final exception) =>
        DefinitionImportResult.rejected(
          DefinitionProblem.invalid,
          error: exception,
        ),
    };
  }

  /// Deletes the user definition [id] (never a bundled one, never one that a
  /// session uses).
  Future<ContestDeleteResult> delete(String id) =>
      _ref.read(contestDefinitionRepositoryProvider).delete(id);
}

/// The definition importer.
final contestDefinitionImporterProvider = Provider<ContestDefinitionImporter>(
  ContestDefinitionImporter.new,
);
