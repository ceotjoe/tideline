import 'package:flutter/material.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/design/tokens/metrics.dart';

/// Builds Flutter's [ThemeData] from Tideline's tokens.
///
/// Material widgets are restyled so that nothing looks like the stock
/// template; colours come only from [TidelineColors].
ThemeData buildTidelineTheme({
  required TidelineThemeVariant variant,
  TidelineDensity density = TidelineDensity.comfortable,
  TextSpacing textSpacing = TextSpacing.normal,
  String? fontFamily,
}) {
  final colors = TidelineColors.forVariant(variant);
  final metrics = TidelineMetrics(density: density);
  final scheme = ColorScheme(
    brightness: variant.brightness,
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    secondary: colors.primary,
    onSecondary: colors.onPrimary,
    error: colors.error,
    onError: colors.background,
    surface: colors.surface,
    onSurface: colors.text,
    onSurfaceVariant: colors.textSecondary,
    surfaceContainerHighest: colors.surfaceVariant,
    outline: colors.outline,
    outlineVariant: colors.outline,
  );

  TextStyle t(TextStyle s) =>
      textSpacing.apply(s.copyWith(color: colors.text, fontFamily: fontFamily));
  final textTheme = TextTheme(
    displayLarge: t(TidelineType.display),
    headlineMedium: t(TidelineType.title),
    titleLarge: t(TidelineType.title),
    titleMedium: t(TidelineType.heading),
    bodyLarge: t(TidelineType.body),
    bodyMedium: t(TidelineType.body),
    labelLarge: t(TidelineType.label),
    bodySmall: textSpacing.apply(
      TidelineType.caption.copyWith(
        color: colors.textSecondary,
        fontFamily: fontFamily,
      ),
    ),
  );

  final minTarget = Size.square(metrics.minTouchTarget);
  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(TidelineMetrics.radiusMd),
  );
  final focusSide = BorderSide(color: colors.focus, width: 3);

  return ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: scheme,
    brightness: variant.brightness,
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.background,
    focusColor: colors.focus.withValues(alpha: 0.24),
    textTheme: textTheme,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    extensions: [colors, metrics],
    dividerTheme: DividerThemeData(color: colors.outline, thickness: 1),
    iconTheme: IconThemeData(color: colors.text, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(TidelineMetrics.radiusLg),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(minTarget),
        shape: const WidgetStatePropertyAll(buttonShape),
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        side: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.focused) ? focusSide : null,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(minTarget),
        shape: const WidgetStatePropertyAll(buttonShape),
        foregroundColor: WidgetStatePropertyAll(colors.primary),
        side: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.focused)
              ? focusSide
              : BorderSide(color: colors.outline),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(minTarget),
        shape: const WidgetStatePropertyAll(buttonShape),
        foregroundColor: WidgetStatePropertyAll(colors.primary),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(minTarget),
        foregroundColor: WidgetStatePropertyAll(colors.text),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceVariant,
      labelStyle: TextStyle(color: colors.textSecondary),
      hintStyle: TextStyle(color: colors.textSecondary),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(TidelineMetrics.radiusSm),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
        borderSide: focusSide,
      ),
      errorStyle: TextStyle(color: colors.error),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.background,
      indicatorColor: colors.surfaceVariant,
      selectedIconTheme: IconThemeData(color: colors.primary),
      unselectedIconTheme: IconThemeData(color: colors.textSecondary),
      selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        color: colors.primary,
      ),
      unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        color: colors.textSecondary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.surfaceVariant,
      height: metrics.minTouchTarget + 32,
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelLarge?.copyWith(color: colors.text),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? colors.primary
              : colors.textSecondary,
        ),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.text,
        borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
      ),
      textStyle: TextStyle(color: colors.background),
    ),
  );
}

/// Convenient access to the design tokens.
extension TidelineThemeContext on BuildContext {
  /// Semantic colours of the active theme.
  TidelineColors get colors => Theme.of(this).extension<TidelineColors>()!;

  /// Spacing, radius and motion tokens of the active theme.
  TidelineMetrics get metrics => Theme.of(this).extension<TidelineMetrics>()!;
}
