import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/features/contest/contest_labels.dart';
import 'package:tideline/src/widgets/upper_case_formatter.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Keyboard and input rules for one exchange kind.
class ExchangeInput {
  const new _({
    required this.keyboard,
    required this.formatters,
    this.capitalization = TextCapitalization.characters,
  });

  /// The rules for [kind]. Whitespace is never accepted: Space moves to the
  /// next field instead.
  factory of(ExchangeKind kind) {
    final noSpace = FilteringTextInputFormatter.deny(RegExp(r'\s'));
    ExchangeInput digits(int max) => ExchangeInput._(
      keyboard: TextInputType.number,
      formatters: [
        noSpace,
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(max),
      ],
    );
    ExchangeInput text(String allowed, int max) => ExchangeInput._(
      keyboard: TextInputType.text,
      formatters: [
        noSpace,
        FilteringTextInputFormatter.allow(RegExp(allowed)),
        UpperCaseFormatter(),
        LengthLimitingTextInputFormatter(max),
      ],
    );
    return switch (kind) {
      ExchangeKind.rst => digits(3),
      ExchangeKind.serial => digits(5),
      ExchangeKind.cqZone || ExchangeKind.ituZone => digits(2),
      ExchangeKind.grid => text('[A-Za-z0-9]', 6),
      ExchangeKind.state => text('[A-Za-z]', 3),
      ExchangeKind.section => text('[A-Za-z]', 4),
      ExchangeKind.dok => text('[A-Za-z0-9]', 6),
      ExchangeKind.power => text('[A-Za-z0-9]', 5),
      ExchangeKind.text => text('[A-Za-z0-9/]', 12),
      ExchangeKind.name => ExchangeInput._(
        keyboard: TextInputType.name,
        capitalization: TextCapitalization.words,
        formatters: [
          noSpace,
          FilteringTextInputFormatter.allow(RegExp(r'\p{L}', unicode: true)),
          LengthLimitingTextInputFormatter(20),
        ],
      ),
    };
  }

  /// Soft keyboard to show.
  final TextInputType keyboard;

  /// Filters applied while typing.
  final List<TextInputFormatter> formatters;

  /// Capitalisation hint for soft keyboards.
  final TextCapitalization capitalization;
}

/// A text field for one received exchange element.
///
/// Space and the keyboard's action key are reported to the caller, which
/// moves focus or logs (contest logging is keyboard-first).
class ExchangeField extends StatelessWidget {
  /// Creates the field.
  const new({
    required this.element,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    this.errorText,
    this.hintText,
    super.key,
  });

  /// What the field collects.
  final ExchangeElement element;

  /// Holds exactly what was typed.
  final TextEditingController controller;

  /// Focus of this field.
  final FocusNode focusNode;

  /// Called with the raw text on every edit.
  final ValueChanged<String> onChanged;

  /// Called when the keyboard's action key is pressed.
  final VoidCallback onSubmitted;

  /// Localised validation message.
  final String? errorText;

  /// Placeholder, for example the default report.
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final input = ExchangeInput.of(element.kind);
    final label = exchangeLabel(l10n, element);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: input.keyboard,
      textCapitalization: input.capitalization,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: input.formatters,
      decoration: InputDecoration(
        labelText: element.optional ? l10n.contestOptionalLabel(label) : label,
        hintText: hintText,
        errorText: errorText,
        errorMaxLines: 3,
      ),
      onChanged: onChanged,
      onEditingComplete: onSubmitted,
    );
  }
}

/// Handles Space as "next field" for a [FocusNode]: returns a key handler
/// for `FocusNode.onKeyEvent`.
KeyEventResult spaceMovesOn(KeyEvent event, VoidCallback next) {
  if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
    next();
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
}
