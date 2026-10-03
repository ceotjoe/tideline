import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A real reference of each programme, shown as an example. Data, not text
/// in a language.
String exampleReference(ReferenceProgram program) => switch (program) {
  ReferenceProgram.sota => 'G/LD-001',
  ReferenceProgram.pota => 'US-0001',
  ReferenceProgram.wwff => 'DLFF-0001',
};

/// The label of the field where the operator types the reference.
String referenceFieldLabel(AppLocalizations l10n, ReferenceProgram program) =>
    switch (program) {
      ReferenceProgram.sota => l10n.activationReferenceLabelSota,
      ReferenceProgram.pota => l10n.activationReferenceLabelPota,
      ReferenceProgram.wwff => l10n.activationReferenceLabelWwff,
    };

/// The label of the entry form field for the other station's reference.
String theirReferenceFieldLabel(
  AppLocalizations l10n,
  ReferenceProgram program,
) => switch (program) {
  ReferenceProgram.sota => l10n.activationTheirReferenceSota,
  ReferenceProgram.pota => l10n.activationTheirReferencePota,
  ReferenceProgram.wwff => l10n.activationTheirReferenceWwff,
};

/// The progress line of an activation: either what is missing, or that it
/// is valid. The text equivalent of the progress bar.
String progressText(AppLocalizations l10n, ActivationProgress p) => p.isValid
    ? l10n.activationProgressValid(p.counted, p.required)
    : l10n.activationProgress(p.counted, p.required, p.remaining);
