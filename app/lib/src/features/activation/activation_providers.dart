import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/pack_download.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Activations and the logging of their QSOs.
final activationRepositoryProvider = Provider<ActivationRepository>(
  (ref) => ActivationRepository(
    ref.watch(databaseProvider),
    ref.watch(hlcClockProvider),
    ref.watch(qsoRepositoryProvider),
  ),
);

/// The account's running activation, or null.
final activeActivationProvider = StreamProvider<Activation?>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return Stream.value(null);
  return ref.watch(activationRepositoryProvider).watchActive(account.id);
});

/// Progress of the running activation toward validity; null without one.
final activationProgressProvider = StreamProvider<ActivationProgress?>((ref) {
  final id = ref.watch(activeActivationProvider.select((a) => a.value?.id));
  if (id == null) return Stream.value(null);
  return ref.watch(activationRepositoryProvider).watchProgress(id);
});

/// A reference from the installed list: null when no list is installed or
/// it does not contain the reference.
final FutureProviderFamily<
  ProgramReference?,
  ({ReferenceProgram program, String reference})
>
activationReferenceProvider = FutureProvider.autoDispose
    .family<ProgramReference?, ({ReferenceProgram program, String reference})>((
      ref,
      key,
    ) {
      // Looked up again when the list is installed or removed.
      ref.watch(referencePackInfoProvider(key.program));
      return ref
          .watch(referencePackStoreProvider)
          .find(key.program, key.reference);
    });

/// The shortest search text that searches.
const int minReferenceSearchLength = 2;

/// References of one programme matching a search text, best first.
final FutureProviderFamily<
  List<ProgramReference>,
  ({ReferenceProgram program, String query})
>
referenceSearchProvider = FutureProvider.autoDispose
    .family<List<ProgramReference>, ({ReferenceProgram program, String query})>(
      (ref, key) {
        ref.watch(referencePackInfoProvider(key.program));
        if (key.query.trim().length < minReferenceSearchLength) {
          return const [];
        }
        return ref
            .watch(referencePackStoreProvider)
            .search(key.query, program: key.program, limit: 8);
      },
    );

/// The references of one programme nearest to a grid square, with distances.
/// Empty for an invalid grid.
final FutureProviderFamily<
  List<NearbyReference>,
  ({ReferenceProgram program, String grid})
>
nearbyReferencesProvider = FutureProvider.autoDispose
    .family<List<NearbyReference>, ({ReferenceProgram program, String grid})>((
      ref,
      key,
    ) {
      ref.watch(referencePackInfoProvider(key.program));
      final center = Maidenhead.centerOf(key.grid);
      if (center == null) return const [];
      return ref
          .watch(referencePackStoreProvider)
          .nearest(key.program, center.$1, center.$2, limit: 5);
    });

/// The rules that apply to a programme: stored ones or the defaults.
final FutureProviderFamily<ActivationRules, ReferenceProgram>
activationRulesProvider = FutureProvider.autoDispose
    .family<ActivationRules, ReferenceProgram>(
      (ref, program) =>
          ref.watch(activationRepositoryProvider).rulesFor(program),
    );
