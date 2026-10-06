import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/sync_scheduler.dart';

Future<void> _elapse(WidgetTester tester, int seconds) =>
    tester.pump(Duration(seconds: seconds));

void main() {
  testWidgets('a burst of automatic triggers starts one run', (tester) async {
    var runs = 0;
    final s = SyncScheduler(run: () => runs++)
      ..requestAutomatic()
      ..requestAutomatic();
    await _elapse(tester, 3);
    s.requestAutomatic();
    await _elapse(tester, 4);
    expect(runs, 0, reason: 'each trigger restarts the quiet time');
    await _elapse(tester, 2);
    expect(runs, 1);
    await _elapse(tester, 60);
    expect(runs, 1);
  });

  testWidgets('a retry waits for Retry-After plus the slack', (tester) async {
    var runs = 0;
    final s = SyncScheduler(run: () => runs++)
      ..scheduleRetry(const Duration(seconds: 30));
    await _elapse(tester, 30);
    expect(runs, 0);
    await _elapse(tester, 1);
    expect(runs, 1);
    expect(s.hasPendingRetry, isFalse);
  });

  testWidgets('a newer retry replaces the older one', (tester) async {
    var runs = 0;
    SyncScheduler(run: () => runs++)
      ..scheduleRetry(const Duration(seconds: 10))
      ..scheduleRetry(const Duration(seconds: 60));
    await _elapse(tester, 30);
    expect(runs, 0);
    await _elapse(tester, 31);
    expect(runs, 1);
  });

  testWidgets('leaving the foreground drops the retry and blocks new ones', (
    tester,
  ) async {
    var runs = 0;
    final s = SyncScheduler(run: () => runs++)
      ..scheduleRetry(const Duration(seconds: 5))
      ..setForeground(false);
    expect(s.hasPendingRetry, isFalse);
    s.scheduleRetry(const Duration(seconds: 5));
    await _elapse(tester, 300);
    expect(runs, 0);
    s
      ..setForeground(true)
      ..scheduleRetry(const Duration(seconds: 5));
    await _elapse(tester, 6);
    expect(runs, 1);
  });

  testWidgets('cancelRetry and dispose stop the timers', (tester) async {
    var runs = 0;
    final s = SyncScheduler(run: () => runs++)
      ..scheduleRetry(const Duration(seconds: 5))
      ..cancelRetry()
      ..requestAutomatic()
      ..dispose();
    await _elapse(tester, 300);
    expect(runs, 0);
    expect(s.hasPendingRun, isFalse);
  });
}
