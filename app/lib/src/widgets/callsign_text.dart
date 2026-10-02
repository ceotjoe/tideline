import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tideline/src/design/tokens/metrics.dart';

/// A callsign that screen readers read letter by letter ("D O 1 H O Z")
/// instead of trying to pronounce it as a word.
///
/// iOS: `SpellOutStringAttribute`. Other platforms: a label with the
/// characters separated by spaces, which TalkBack and Narrator read one by
/// one.
class CallsignText extends StatelessWidget {
  /// Creates the text for [callsign].
  const new(this.callsign, {this.style, super.key});

  /// The callsign.
  final String callsign;

  /// Text style; defaults to the callsign type style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final isApple =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
    final label = isApple
        ? AttributedString(
            callsign,
            attributes: [
              SpellOutStringAttribute(
                range: TextRange(start: 0, end: callsign.length),
              ),
            ],
          )
        : AttributedString(callsign.split('').join(' '));
    return Semantics(
      attributedLabel: label,
      excludeSemantics: true,
      child: Text(
        callsign,
        style:
            style ??
            TidelineType.callsign.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }
}
