import 'dart:ui';

/// Raw "Low Tide" palette. Widgets never use these directly: they use the
/// semantic `TidelineColors` of the active theme, whose pairs are
/// contrast-tested. See docs/design/design-system.md.
abstract final class Palette {
  // Sand: warm, calm surfaces.
  static const sand50 = Color(0xFFFFFCF6);
  static const sand100 = Color(0xFFF6F1E7);
  static const sand200 = Color(0xFFEDE4D3);

  // Seafoam: the signature accent.
  static const seafoam100 = Color(0xFFE3F0EC);
  static const seafoam300 = Color(0xFF9FD3C7);
  static const seafoam400 = Color(0xFF7FD1C3);
  static const seafoam700 = Color(0xFF1F6F68);
  static const seafoam900 = Color(0xFF08302B);

  // Deep sea: ink and dark surfaces.
  static const sea950 = Color(0xFF0F1E22);
  static const sea900 = Color(0xFF12343B);
  static const sea850 = Color(0xFF16292E);
  static const sea800 = Color(0xFF1E383D);
  static const sea600 = Color(0xFF3E5C61);
  static const sea400 = Color(0xFF6F8A8B);
  static const sea300 = Color(0xFFA9C2C0);
  static const sea50 = Color(0xFFE8F1EF);

  // Status hues (colour-blind-safe set: green/blue/amber/red differ in
  // lightness as well as hue, and are always paired with icon + text).
  static const kelp800 = Color(0xFF1D5B3A);
  static const kelp100 = Color(0xFFDDEFE6);
  static const kelp300 = Color(0xFF9BE0B9);
  static const kelp900 = Color(0xFF173A2A);
  static const harbour800 = Color(0xFF1E4A72);
  static const harbour100 = Color(0xFFE4EEF6);
  static const harbour300 = Color(0xFFA8CDF2);
  static const harbour900 = Color(0xFF172E45);
  static const amber800 = Color(0xFF7A4A00);
  static const amber100 = Color(0xFFFBEBD3);
  static const amber300 = Color(0xFFF4C77A);
  static const amber900 = Color(0xFF3D2C10);
  static const coral800 = Color(0xFF8E2A1E);
  static const coral700 = Color(0xFFA3271B);
  static const coral100 = Color(0xFFF8E1DE);
  static const coral300 = Color(0xFFF5ADA2);
  static const coral200 = Color(0xFFFFB4A9);
  static const coral900 = Color(0xFF44201B);

  // Focus.
  static const focusLight = Color(0xFF1A4F8B);
  static const focusDark = Color(0xFF8CC4FF);

  // Night red: a single hue to preserve dark adaptation.
  static const night0 = Color(0xFF000000);
  static const night50 = Color(0xFF0D0000);
  static const night100 = Color(0xFF140000);
  static const nightRed = Color(0xFFFF4433);
  static const nightRedDim = Color(0xFFF0301F);
  static const nightRedLine = Color(0xFFCC2214);
  static const nightRedBright = Color(0xFFFF6655);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}
