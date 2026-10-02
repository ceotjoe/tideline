import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/services/contest_definition_import.dart';
import 'package:tideline/src/services/scp_download.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The localised message for a failed MASTER.SCP download or import.
String scpFailureText(AppLocalizations l10n, ScpException e) =>
    switch (e.failure) {
      ScpFailure.insecureUrl => l10n.scpErrorInsecureUrl,
      ScpFailure.invalidUrl => l10n.scpErrorInvalidUrl,
      ScpFailure.network => l10n.scpErrorNetwork,
      ScpFailure.timeout => l10n.scpErrorTimeout,
      ScpFailure.certificate => l10n.scpErrorCertificate,
      ScpFailure.tooLarge => l10n.scpErrorTooLarge,
      ScpFailure.httpStatus => l10n.scpErrorStatus(e.statusCode ?? 0),
      ScpFailure.invalidFile => l10n.scpErrorInvalidFile,
    };

/// Why the parser rejected a contest definition, in the user's language.
String contestDefinitionErrorText(
  AppLocalizations l10n,
  ContestDefinitionError error,
) => switch (error) {
  ContestDefinitionError.tooLarge => l10n.contestDefErrorTooLarge,
  ContestDefinitionError.malformedJson => l10n.contestDefErrorMalformedJson,
  ContestDefinitionError.wrongType => l10n.contestDefErrorWrongType,
  ContestDefinitionError.unknownKey => l10n.contestDefErrorUnknownKey,
  ContestDefinitionError.missingKey => l10n.contestDefErrorMissingKey,
  ContestDefinitionError.unsupportedSchema =>
    l10n.contestDefErrorUnsupportedSchema,
  ContestDefinitionError.invalidId => l10n.contestDefErrorInvalidId,
  ContestDefinitionError.outOfRange => l10n.contestDefErrorOutOfRange,
  ContestDefinitionError.tooLong => l10n.contestDefErrorTooLong,
  ContestDefinitionError.invalidCharacters =>
    l10n.contestDefErrorInvalidCharacters,
  ContestDefinitionError.tooManyElements => l10n.contestDefErrorTooManyElements,
  ContestDefinitionError.tooFewElements => l10n.contestDefErrorTooFewElements,
  ContestDefinitionError.unknownBand => l10n.contestDefErrorUnknownBand,
  ContestDefinitionError.unknownValue => l10n.contestDefErrorUnknownValue,
  ContestDefinitionError.lastRuleHasWhen => l10n.contestDefErrorLastRuleHasWhen,
  ContestDefinitionError.variantPredicateNotMine =>
    l10n.contestDefErrorVariantPredicateNotMine,
  ContestDefinitionError.elementPredicateNotTheirs =>
    l10n.contestDefErrorElementPredicateNotTheirs,
  ContestDefinitionError.elementWhenNotAllowed =>
    l10n.contestDefErrorElementWhenNotAllowed,
  ContestDefinitionError.multipleSerials => l10n.contestDefErrorMultipleSerials,
  ContestDefinitionError.duplicateField => l10n.contestDefErrorDuplicateField,
  ContestDefinitionError.duplicateId => l10n.contestDefErrorDuplicateId,
  ContestDefinitionError.invalidPlaceholder =>
    l10n.contestDefErrorInvalidPlaceholder,
  ContestDefinitionError.invalidValue => l10n.contestDefErrorInvalidValue,
  ContestDefinitionError.defaultNotAllowed =>
    l10n.contestDefErrorDefaultNotAllowed,
  ContestDefinitionError.invalidMultiplierSource =>
    l10n.contestDefErrorInvalidMultiplierSource,
  ContestDefinitionError.emptyPredicate => l10n.contestDefErrorEmptyPredicate,
  ContestDefinitionError.invalidCombination =>
    l10n.contestDefErrorInvalidCombination,
  ContestDefinitionError.duplicateValue => l10n.contestDefErrorDuplicateValue,
};

/// The localised reason a definition was not imported, and the JSON path of
/// the problem (technical detail, never the rejected value) if there is one.
({String message, String? path}) definitionProblemText(
  AppLocalizations l10n,
  DefinitionImportResult result,
) => switch (result.problem) {
  DefinitionProblem.fileTooLarge => (
    message: l10n.contestDefFileTooLarge,
    path: null,
  ),
  DefinitionProblem.unreadable => (
    message: l10n.contestDefUnreadable,
    path: null,
  ),
  DefinitionProblem.notText => (message: l10n.contestDefNotText, path: null),
  DefinitionProblem.idClash => (message: l10n.contestDefIdClash, path: null),
  DefinitionProblem.invalid || null => (
    message: result.error == null
        ? l10n.contestDefUnreadable
        : contestDefinitionErrorText(l10n, result.error!.reason),
    path: result.error?.path,
  ),
};

/// The localised outcome of deleting a definition.
String deleteResultText(
  AppLocalizations l10n,
  ContestDeleteResult result,
  String name,
) => switch (result) {
  ContestDeleteResult.deleted => l10n.contestDefDeleted(name),
  ContestDeleteResult.notFound => l10n.contestDefNotFound,
  ContestDeleteResult.builtin => l10n.contestDefBuiltinNoDelete,
  ContestDeleteResult.inUse => l10n.contestDefInUse,
};
