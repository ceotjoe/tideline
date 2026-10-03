import 'package:flutter/widgets.dart';

/// Tracks whether the on-screen keyboard is showing.
///
/// Read from the view, not from `MediaQuery`: the scaffolds above consume the
/// inset when they resize their bodies, so `MediaQuery.viewInsets` is zero in
/// a screen's own build. Mix in after [WidgetsBindingObserver].
mixin KeyboardAware<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  /// Whether the on-screen keyboard is showing.
  bool get keyboardUp => _keyboardUp;
  bool _keyboardUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final up = View.of(context).viewInsets.bottom > 0;
    if (up != _keyboardUp) setState(() => _keyboardUp = up);
  }
}
