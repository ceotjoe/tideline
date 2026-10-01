import 'package:flutter/widgets.dart';

/// Window size classes on Material 3 breakpoints.
///
/// Layouts depend on the current window width, never on the device type,
/// so Split View, Stage Manager, foldables and desktop windows all work.
/// See docs/adr/0010-adaptive-size-classes.md.
enum SizeClass {
  /// < 600 dp: phones, narrow windows. Single pane, bottom navigation.
  compact,

  /// 600–839 dp: tablets in portrait, half-screen windows. Two panes.
  medium,

  /// 840–1199 dp: tablets in landscape. Multi-pane.
  expanded,

  /// ≥ 1200 dp: large tablets and desktop windows.
  large;

  /// The class for a window [width] in logical pixels.
  factory forWidth(double width) {
    if (width < 600) return compact;
    if (width < 840) return medium;
    if (width < 1200) return expanded;
    return large;
  }

  /// The class of the window [context] is in.
  factory of(BuildContext context) =>
      SizeClass.forWidth(MediaQuery.sizeOf(context).width);

  /// Whether at least [other] (e.g. `isAtLeast(SizeClass.medium)`).
  bool isAtLeast(SizeClass other) => index >= other.index;
}
