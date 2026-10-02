import 'dart:math';

import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

void main() {
  final machine = SyncMachine(random: Random(1));
  const now = 1000000;

  SyncStatus st(
    SyncState state, {
    SyncOperation op = SyncOperation.create,
    int? remote,
    int attempts = 0,
  }) => SyncStatus(
    state: state,
    operation: op,
    remoteQsoId: remote,
    attempts: attempts,
  );

  SyncStatus? apply(SyncStatus s, SyncEvent e) => machine.apply(s, e, now);

  group('happy path', () {
    test('draft → queued → uploading → synced', () {
      var s = SyncMachine.initial(complete: false);
      expect(s.state, SyncState.local);
      s = apply(s, const QsoCompleted())!;
      expect(s.state, SyncState.queued);
      expect(s.isDue(now), isTrue);
      s = apply(s, const RequestStarted())!;
      expect(s.state, SyncState.uploading);
      s = apply(s, const RequestSucceeded(remoteQsoId: 42))!;
      expect(s, const SyncStatus(state: SyncState.synced, remoteQsoId: 42));
    });
  });

  group('never duplicate, never lose (ADR 0008)', () {
    test('uncertain outcome is verified before any retry', () {
      final s = apply(
        st(SyncState.uploading),
        const OutcomeUncertain(SyncProblem.serverError),
      )!;
      expect(s.state, SyncState.verifying);
      expect(
        () => apply(s, const RequestStarted()),
        throwsA(isA<InvalidSyncTransition>()),
      );
    });

    test('server-side duplicate → verifying → synced with the found id', () {
      var s = apply(
        st(SyncState.uploading),
        const OutcomeUncertain(
          SyncProblem.invalidData,
          serverMessage: 'Duplicate',
        ),
      )!;
      s = apply(s, const ReconcileFound(7))!;
      expect(s.state, SyncState.synced);
      expect(s.remoteQsoId, 7);
      expect(s.problem, isNull);
    });

    test('not found after verification → queued with backoff', () {
      final s = apply(
        st(SyncState.verifying, attempts: 2),
        const ReconcileNotFound(),
      )!;
      expect(s.state, SyncState.queued);
      expect(s.attempts, 3);
      expect(s.isDue(now), isFalse);
      expect(s.isDue(s.nextAttemptAt!), isTrue);
    });

    test('a killed app turns in-flight uploads into verifications', () {
      expect(
        apply(st(SyncState.uploading), const AppRestarted())!.state,
        SyncState.verifying,
      );
      for (final other in SyncState.values.where(
        (x) => x != SyncState.uploading,
      )) {
        expect(apply(st(other), const AppRestarted())!.state, other);
      }
    });
  });

  group('retries', () {
    test('Retry-After is honoured exactly', () {
      final s = apply(
        st(SyncState.uploading),
        const TransientFailure(
          SyncProblem.rateLimited,
          retryAfter: Duration(seconds: 30),
        ),
      )!;
      expect(s.nextAttemptAt, now + 30000);
      expect(s.problem, SyncProblem.rateLimited);
    });

    test('backoff grows exponentially with jitter and is capped', () {
      final m = SyncMachine(random: Random(3));
      final d1 = m.backoff(1).inSeconds;
      final d5 = m.backoff(5).inSeconds;
      expect(d1, inInclusiveRange(24, 36));
      expect(d5, inInclusiveRange(384, 576));
      expect(
        m.backoff(30),
        lessThanOrEqualTo(const Duration(hours: 6, minutes: 72)),
      );
    });
  });

  group('rejections and blocking', () {
    test('rejected QSOs wait for a fix, then queue again', () {
      var s = apply(
        st(SyncState.uploading),
        const Rejected(SyncProblem.invalidData, serverMessage: 'Bad band'),
      )!;
      expect(s.state, SyncState.rejected);
      expect(s.serverMessage, 'Bad band');
      s = apply(s, const LocalEdit(changesReadOnlyFields: false))!;
      expect(s.state, SyncState.queued);
      expect(s.problem, isNull);
    });

    test('a revoked token blocks only waiting work', () {
      for (final state in [
        SyncState.queued,
        SyncState.uploading,
        SyncState.verifying,
      ]) {
        expect(
          apply(
            st(state),
            const AccountBlocked(SyncProblem.tokenExpired),
          )!.state,
          SyncState.blocked,
        );
      }
      for (final state in [
        SyncState.local,
        SyncState.synced,
        SyncState.conflict,
        SyncState.rejected,
      ]) {
        expect(
          apply(
            st(state),
            const AccountBlocked(SyncProblem.tokenInvalid),
          )!.state,
          state,
        );
      }
    });

    test('unblocking verifies creates that may have reached the server', () {
      expect(
        apply(st(SyncState.blocked), const AccountUnblocked())!.state,
        SyncState.verifying,
      );
      expect(
        apply(
          st(SyncState.blocked, op: SyncOperation.patch, remote: 5),
          const AccountUnblocked(),
        )!.state,
        SyncState.queued,
      );
    });
  });

  group('edits and deletes after sync (ADR 0016)', () {
    test('patchable edit → queued patch', () {
      final s = apply(
        st(SyncState.synced, remote: 9),
        const LocalEdit(changesReadOnlyFields: false),
      )!;
      expect(
        (s.state, s.operation, s.remoteQsoId),
        (SyncState.queued, SyncOperation.patch, 9),
      );
    });

    test('read-only edit → conflict; user decides', () {
      final c = apply(
        st(SyncState.synced, remote: 9),
        const LocalEdit(changesReadOnlyFields: true),
      )!;
      expect(c.state, SyncState.conflict);
      expect(c.problem, SyncProblem.readOnlyFieldsChanged);

      final replace = apply(c, const ConflictResolved(replaceOnServer: true))!;
      expect(
        (replace.state, replace.operation),
        (SyncState.queued, SyncOperation.replace),
      );
      final keep = apply(c, const ConflictResolved(replaceOnServer: false))!;
      expect(keep.state, SyncState.synced);
      expect(keep.remoteQsoId, 9);
    });

    test('deleting a QSO that never reached the server needs no sync', () {
      for (final state in [
        SyncState.local,
        SyncState.queued,
        SyncState.rejected,
      ]) {
        expect(
          apply(st(state), const LocalDelete(canDeleteOnServer: true)),
          isNull,
        );
      }
    });

    test('deleting a synced QSO queues a server delete if permitted', () {
      final s = apply(
        st(SyncState.synced, remote: 3),
        const LocalDelete(canDeleteOnServer: true),
      )!;
      expect((s.state, s.operation), (SyncState.queued, SyncOperation.delete));
      expect(
        apply(
          st(SyncState.synced, remote: 3),
          const LocalDelete(canDeleteOnServer: false),
        ),
        isNull,
      );
      // After the server confirms, the sync row goes away.
      final started = apply(s, const RequestStarted())!;
      expect(apply(started, const RequestSucceeded()), isNull);
    });

    test('deleting during an upload waits for the outcome', () {
      expect(
        apply(
          st(SyncState.uploading),
          const LocalDelete(canDeleteOnServer: true),
        )!.state,
        SyncState.uploading,
      );
    });
  });

  test('impossible transitions are bugs and throw', () {
    final cases = <(SyncState, SyncEvent)>[
      (SyncState.queued, const RequestSucceeded(remoteQsoId: 1)),
      (SyncState.synced, const RequestStarted()),
      (SyncState.queued, const ReconcileFound(1)),
      (SyncState.local, const Rejected(SyncProblem.invalidData)),
      (SyncState.synced, const ConflictResolved(replaceOnServer: true)),
      (SyncState.synced, const QsoCompleted()),
    ];
    for (final (state, event) in cases) {
      expect(
        () => apply(st(state), event),
        throwsA(isA<InvalidSyncTransition>()),
        reason: '${state.name} + ${event.runtimeType}',
      );
    }
  });

  test('pending states drive the tide gauge', () {
    expect(
      SyncState.values.where((s) => s.isPending),
      isNot(contains(SyncState.synced)),
    );
  });
}
