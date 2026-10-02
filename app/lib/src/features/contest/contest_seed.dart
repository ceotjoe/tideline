import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tideline_data/tideline_data.dart';

/// Folder of the bundled definitions (ADR 0018).
const bundledContestFolder = 'assets/contests/';

/// Loads every `*.json` file of [bundledContestFolder] into [repository]
/// as built-in definitions.
///
/// Never throws: a failure is passed to [report] (default: the debug log)
/// as a short message without personal data, and the result is null.
Future<ContestSeedReport?> seedBundledContests({
  required AssetBundle bundle,
  required ContestDefinitionRepository repository,
  void Function(String message) report = _debugReport,
}) async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final paths =
        manifest
            .listAssets()
            .where(
              (p) => p.startsWith(bundledContestFolder) && p.endsWith('.json'),
            )
            .toList()
          ..sort();
    final jsons = [for (final path in paths) await bundle.loadString(path)];
    final result = await repository.seedBuiltins(jsons);
    for (final e in result.invalid) {
      report('Contest definition rejected: ${e.reason.name} at ${e.path}');
    }
    for (final id in result.conflicts) {
      report('Contest definition $id clashes with an imported one');
    }
    return result;
  } on Object catch (error) {
    report('Seeding contest definitions failed: ${error.runtimeType}');
    return null;
  }
}

void _debugReport(String message) => debugPrint(message);
