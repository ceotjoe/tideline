import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/services/app_services.dart';

/// Settings key of the optional app lock.
const appLockSetting = 'security.appLock';

/// Covers the app until the user unlocks it with biometrics or the device
/// PIN, at start and whenever it returns from the background. Sync keeps
/// working underneath; the lock only protects what is shown.
class AppLock extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<AppLock> createState() => _AppLockState();
}

class _AppLockState extends ConsumerState<AppLock> {
  bool _locked = true;
  bool _authenticating = false;
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () => setState(() => _locked = true),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    _authenticating = true;
    final reason = AppLocalizations.of(context).appLockReason;
    try {
      final ok = await LocalAuthentication().authenticate(
        localizedReason: reason,
      );
      if (ok && mounted) setState(() => _locked = false);
    } on Object {
      // Not available or cancelled: stay locked; the button retries.
    } finally {
      _authenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled =
        ref.watch(settingsValuesProvider).value?[appLockSetting] == 'on';
    if (!enabled || !_locked) return widget.child;
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        ExcludeSemantics(child: widget.child),
        Positioned.fill(
          child: ColoredBox(
            color: context.colors.background,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: context.colors.primary,
                  ),
                  SizedBox(height: context.metrics.md),
                  Text(
                    l10n.appLockTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: context.metrics.lg),
                  FilledButton.icon(
                    autofocus: true,
                    onPressed: _unlock,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.appLockUnlock),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
