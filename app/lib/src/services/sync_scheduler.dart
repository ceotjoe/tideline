import 'dart:async';

/// Decides *when* the automatic sync triggers actually start a run
/// (ADR 0033). It owns two timers and nothing else:
///
/// - a debounce that folds a burst of foreground and connectivity events
///   (a Wi-Fi/cellular handover fires several) into one run, and
/// - a retry after the server's 429 `Retry-After`, which only ever fires
///   while the app is in the foreground, so nothing is promised on iOS.
///
/// Logging a QSO and a manual "Sync now" do not use it; they run at once.
class SyncScheduler {
  /// Creates a scheduler that calls [run] when a timer fires.
  new({
    required this.run,
    this.debounce = const Duration(seconds: 5),
    this.retrySlack = const Duration(seconds: 1),
  });

  /// Starts a sync run.
  final void Function() run;

  /// Quiet time after the last automatic trigger before a run starts.
  final Duration debounce;

  /// Added to the server's `Retry-After` so the retry lands after it.
  final Duration retrySlack;

  Timer? _debounce;
  Timer? _retry;
  bool _foreground = true;

  /// Whether a debounced run is waiting.
  bool get hasPendingRun => _debounce != null;

  /// Whether a rate-limit retry is waiting.
  bool get hasPendingRetry => _retry != null;

  /// An automatic trigger (app resumed, connectivity changed).
  void requestAutomatic() {
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      _debounce = null;
      run();
    });
  }

  /// The server asked us to wait [after]; run again then, if the app is
  /// still in the foreground. Replaces an earlier retry.
  void scheduleRetry(Duration after) {
    _retry?.cancel();
    _retry = null;
    if (!_foreground) return;
    _retry = Timer(after + retrySlack, () {
      _retry = null;
      run();
    });
  }

  /// Drops a waiting retry: a run is starting anyway.
  void cancelRetry() {
    _retry?.cancel();
    _retry = null;
  }

  /// Tells the scheduler whether the app is in the foreground. Leaving it
  /// drops the retry; the resume trigger covers the way back.
  // ignore: avoid_positional_boolean_parameters
  void setForeground(bool value) {
    _foreground = value;
    if (!value) cancelRetry();
  }

  /// Stops all timers.
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
    cancelRetry();
  }
}
