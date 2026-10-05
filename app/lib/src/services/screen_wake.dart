import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen from switching off while a screen asks for it.
///
/// Counts the askers: the log and Fast Log Entry can be open at once, and the
/// screen may switch off only when the last one has let go (ADR 0029).
class ScreenWake {
  /// Creates the service. [apply] switches the platform lock on or off.
  new({Future<void> Function({required bool on})? apply})
    : _apply = apply ?? _platform;

  final Future<void> Function({required bool on}) _apply;
  int _holders = 0;

  /// How many screens hold the lock right now.
  @visibleForTesting
  int get holders => _holders;

  /// A screen wants the display kept on.
  Future<void> acquire() async {
    _holders++;
    if (_holders == 1) await _set(on: true);
  }

  /// The screen no longer needs it.
  Future<void> release() async {
    if (_holders == 0) return;
    _holders--;
    if (_holders == 0) await _set(on: false);
  }

  Future<void> _set({required bool on}) async {
    try {
      await _apply(on: on);
    } on Object {
      // A platform without the feature: the screen simply times out as usual.
    }
  }

  static Future<void> _platform({required bool on}) =>
      WakelockPlus.toggle(enable: on);
}

/// The screen-wake service.
final screenWakeProvider = Provider<ScreenWake>((ref) => ScreenWake());

/// Keeps the display on while it is in the tree and the setting is on.
class KeepScreenOn extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The screen.
  final Widget child;

  @override
  ConsumerState<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState extends ConsumerState<KeepScreenOn> {
  bool _held = false;
  late final ScreenWake _wake = ref.read(screenWakeProvider);

  void _follow(bool wanted) {
    if (wanted == _held) return;
    _held = wanted;
    unawaited(wanted ? _wake.acquire() : _wake.release());
  }

  @override
  void dispose() {
    _follow(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    // After the frame: acquiring is a platform call, not part of building.
    final wanted = settings.keepScreenOn;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _follow(wanted);
    });
    return widget.child;
  }
}
