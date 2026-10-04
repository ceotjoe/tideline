import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/layout/size_class.dart';

/// Gives phones a way to close the on-screen keyboard.
///
/// An iOS number pad has no Done key, and the keyboard covers the bottom
/// navigation. While the keyboard is up in a compact window, the app lives in
/// the space above it, with a "Hide keyboard" bar between the two. The
/// navigation bar is replaced by that bar ([KeyboardDock.isDocked]), so the
/// form keeps its height and the navigation is one tap away. A tap on empty
/// space also closes the keyboard.
///
/// Wider windows are left alone: tablet keyboards have their own dismiss key
/// and ADR 0020 gives their height to the entry form.
/// See docs/adr/0020-landscape-entry-strip.md.
class KeyboardDock extends StatelessWidget {
  /// Wraps [child], the whole app.
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  /// Whether the dock is showing, so the navigation bar should give way.
  static bool isDocked(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DockState>()?.docked ?? false;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final docked = inset > 0 && SizeClass.of(context) == SizeClass.compact;
    if (!docked) return _DockState(docked: false, child: child);

    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final target = context.metrics.minTouchTarget;
    void hide() => FocusManager.instance.primaryFocus?.unfocus();

    return _DockState(
      docked: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: inset),
        child: Column(
          children: [
            Expanded(
              // The inset is spent here: the scaffolds below must not shrink
              // their bodies a second time.
              child: MediaQuery.removeViewInsets(
                context: context,
                removeBottom: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: hide,
                  child: child,
                ),
              ),
            ),
            Material(
              color: colors.surfaceContainerHigh,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: target,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: hide,
                    icon: const Icon(Icons.keyboard_hide_outlined),
                    label: Text(l10n.actionHideKeyboard),
                    style: TextButton.styleFrom(
                      minimumSize: Size(target, target),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockState extends InheritedWidget {
  const new({required this.docked, required super.child});

  final bool docked;

  @override
  bool updateShouldNotify(_DockState old) => docked != old.docked;
}
