import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/design/contrast.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';

void main() {
  group('contrastRatio', () {
    test('matches known WCAG values', () {
      expect(
        contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
      expect(
        contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
        closeTo(4.48, 0.01),
      );
      expect(
        contrastRatio(const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)),
        1,
      );
    });
  });

  for (final variant in TidelineThemeVariant.values) {
    group('theme ${variant.name}', () {
      final colors = TidelineColors.forVariant(variant);
      // Sunlight targets WCAG AAA (7:1) for text; others AA.
      final textBoost = variant == TidelineThemeVariant.sunlight ? 7 / 4.5 : 1;

      for (final pair in colors.contrastPairs) {
        final required = pair.minRatio >= 4.5
            ? pair.minRatio * textBoost
            : pair.minRatio;
        test('${pair.name} ≥ ${required.toStringAsFixed(1)}:1', () {
          final ratio = contrastRatio(pair.foreground, pair.background);
          expect(
            ratio,
            greaterThanOrEqualTo(required),
            reason: '${pair.name} is ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }

  test('status colours differ in light and dark themes', () {
    // Colour is never the only cue, but distinct statuses still help.
    for (final colors in [TidelineColors.light, TidelineColors.dark]) {
      final fills = {
        colors.synced.background,
        colors.pending.background,
        colors.conflict.background,
        colors.rejected.background,
      };
      expect(fills, hasLength(4));
    }
  });
}
