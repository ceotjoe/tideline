import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Display shortest side (dp) below which a mobile device counts as a phone.
const double phoneMaxShortestSide = 600;

/// Keeps phones in portrait; tablets and desktop windows rotate freely.
///
/// Decided by the physical display, not the window: a tablet in Split View
/// or Stage Manager has a narrow window but must still rotate. This is not a
/// layout rule; layouts stay driven by window size classes (ADR 0010).
class PhoneOrientationLock extends StatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  State<PhoneOrientationLock> createState() => _PhoneOrientationLockState();
}

class _PhoneOrientationLockState extends State<PhoneOrientationLock> {
  bool? _phone;

  static bool get _mobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_mobile) return;
    final view = View.of(context);
    final display = view.display.size / view.display.devicePixelRatio;
    final phone = display.shortestSide < phoneMaxShortestSide;
    if (phone == _phone) return;
    _phone = phone;
    unawaited(
      SystemChrome.setPreferredOrientations(
        phone ? const [DeviceOrientation.portraitUp] : const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
