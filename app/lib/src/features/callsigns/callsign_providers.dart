import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show FutureProviderFamily, StreamProviderFamily;
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';

/// The offline callsign directory (derived from the QSO history).
final callsignDirectoryRepositoryProvider =
    Provider<CallsignDirectoryRepository>(
      (ref) => CallsignDirectoryRepository(ref.watch(databaseProvider)),
    );

/// The user's callsign notes (local only).
final callsignNoteRepositoryProvider = Provider<CallsignNoteRepository>(
  (ref) => CallsignNoteRepository(
    ref.watch(databaseProvider),
    ref.watch(hlcClockProvider),
  ),
);

/// What the history of all accounts knows about a call. Refreshes after every
/// change of the log, so it is current right after a QSO is saved.
final FutureProviderFamily<CallsignInfo?, String> callsignInfoProvider =
    FutureProvider.autoDispose.family<CallsignInfo?, String>((ref, call) async {
      ref.watch(logProvider);
      return await ref.watch(callsignDirectoryRepositoryProvider).lookup(call);
    });

/// The note about a call, or null.
final StreamProviderFamily<String?, String> callsignNoteProvider =
    StreamProvider.autoDispose.family<String?, String>(
      (ref, call) => ref.watch(callsignNoteRepositoryProvider).watch(call),
    );

/// The calls that have a note.
final StreamProvider<Set<String>> callsignNoteCallsProvider =
    StreamProvider.autoDispose<Set<String>>(
      (ref) => ref.watch(callsignNoteRepositoryProvider).watchCalls(),
    );

/// How many stations the active account's directory holds.
final StreamProvider<int> callsignDirectoryCountProvider =
    StreamProvider.autoDispose<int>((ref) {
      final account = ref.watch(activeAccountProvider);
      if (account == null) return Stream.value(0);
      return ref
          .watch(callsignDirectoryRepositoryProvider)
          .watchCount(account.id);
    });

/// Stations matching a query (call prefix, name or place), newest first.
final FutureProviderFamily<List<CallsignInfo>, String> callsignSearchProvider =
    FutureProvider.autoDispose.family<List<CallsignInfo>, String>((
      ref,
      query,
    ) async {
      ref
        ..watch(logProvider)
        ..watch(callsignDirectoryCountProvider);
      return await ref.watch(callsignDirectoryRepositoryProvider).search(query);
    });
