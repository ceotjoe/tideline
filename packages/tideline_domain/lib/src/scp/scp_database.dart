import 'package:meta/meta.dart';

/// Thrown when parsing a MASTER.SCP file fails.
@immutable
final class ScpFormatException implements Exception {
  const new _(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'ScpFormatException: $message';
}

/// A callsign database parsed from MASTER.SCP format.
///
/// Provides efficient lookup and partial matching of amateur radio callsigns.
@immutable
final class ScpDatabase {
  const new _({
    required this._calls,
    required this._callSet,
    required this._bigramIndex,
  });

  /// Parses a MASTER.SCP formatted string into a [ScpDatabase].
  ///
  /// Format:
  /// - One callsign per line
  /// - Lines starting with `#` are comments and ignored
  /// - Blank lines are ignored
  /// - Whitespace is trimmed from each line
  /// - Callsigns are converted to uppercase
  /// - Only callsigns matching `[A-Z0-9/]{3,15}` are accepted; others are skipped
  ///
  /// Constraints:
  /// - Input must not exceed 8 MiB in size
  /// - At most 200,000 unique callsigns are stored
  /// - Duplicate callsigns are deduplicated
  ///
  /// Throws [ScpFormatException] if the input exceeds 8 MiB.
  factory parse(String text) {
    // Check size limit: 8 MiB = 8388608 bytes
    const maxBytes = 8388608;
    if (text.length > maxBytes) {
      throw ScpFormatException._(
        'Input exceeds 8 MiB limit (${text.length} bytes)',
      );
    }

    final callSet = <String>{};

    for (final line in text.split('\n')) {
      // Trim and skip blank lines and comments
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      // Uppercase and validate format
      final call = trimmed.toUpperCase();
      if (!_callsignPattern.hasMatch(call) ||
          call.startsWith('/') ||
          call.endsWith('/') ||
          call.contains('//')) {
        continue;
      }

      // Add to set (deduplicated)
      callSet.add(call);

      // Stop if we've hit the cap
      if (callSet.length >= 200000) break;
    }

    // Sort the calls for the main list
    final sortedCalls = callSet.toList()..sort();

    // Build bigram index for partial matching
    final bigramIndex = _buildBigramIndex(sortedCalls);

    return ScpDatabase._(
      calls: sortedCalls,
      callSet: callSet,
      bigramIndex: bigramIndex,
    );
  }

  static final RegExp _callsignPattern = RegExp(
    r'^(?=.*[A-Z])[A-Z0-9/]{3,15}$',
  );

  final List<String> _calls;
  final Set<String> _callSet;
  final Map<String, List<String>> _bigramIndex;

  /// Finds calls containing [fragment] anywhere (case-insensitive).
  ///
  /// Returns up to [limit] results (default 30). Fragment must be at least
  /// 2 characters; shorter fragments return an empty list.
  ///
  /// Results are sorted with prefix matches first, then alphabetically.
  ///
  /// Optimized for speed: typically under 5 ms per query on a typical machine
  /// for databases of 50,000 callsigns.
  List<String> partial(String fragment, {int limit = 30}) {
    if (fragment.length < 2 || limit <= 0) return [];
    final upper = fragment.toUpperCase();
    final prefixMatches = <String>[];
    final otherMatches = <String>[];
    // Candidates are already sorted, so both lists stay alphabetical.
    for (final call in _candidates(upper)) {
      if (call.startsWith(upper)) {
        prefixMatches.add(call);
        if (prefixMatches.length >= limit) break;
      } else if (otherMatches.length < limit && call.contains(upper)) {
        otherMatches.add(call);
      }
    }
    return [...prefixMatches, ...otherMatches].take(limit).toList();
  }

  /// Finds calls at edit distance exactly 1 from [call].
  ///
  /// Edit distance covers one substitution, insertion, or deletion.
  /// The input call itself is excluded from results.
  ///
  /// Returns up to [limit] results (default 10), sorted alphabetically.
  List<String> nPlusOne(String call, {int limit = 10}) {
    final upperCall = call.toUpperCase();
    final results = <String>[];

    // Generate all possible single-edit variants
    final variants = _generateVariants(upperCall);

    // Check which variants exist in our database
    for (final variant in variants) {
      if (variant != upperCall && _callSet.contains(variant)) {
        results.add(variant);
        if (results.length >= limit) break;
      }
    }

    results.sort();
    return results;
  }

  /// Whether this database contains [call] (case-insensitive).
  bool contains(String call) => _callSet.contains(call.toUpperCase());

  /// The number of unique callsigns in this database.
  int get length => _calls.length;

  /// All calls in this database, in sorted order.
  Iterable<String> get calls => _calls;

  // Helper: build bigram index for fast filtering
  static Map<String, List<String>> _buildBigramIndex(List<String> calls) {
    final index = <String, List<String>>{};
    for (final call in calls) {
      // Extract bigrams from the call
      for (var i = 0; i < call.length - 1; i++) {
        final bigram = call.substring(i, i + 2);
        index.putIfAbsent(bigram, () => []).add(call);
      }
    }
    return index;
  }

  // Every call containing [fragment] contains each of its bigrams, so the
  // shortest posting list is a complete, sorted candidate list.
  List<String> _candidates(String fragment) {
    List<String>? best;
    for (var i = 0; i < fragment.length - 1; i++) {
      final postings = _bigramIndex[fragment.substring(i, i + 2)];
      if (postings == null) return const [];
      if (best == null || postings.length < best.length) best = postings;
    }
    return best ?? const [];
  }

  // Helper: generate all single-edit variants
  static Set<String> _generateVariants(String call) {
    final variants = <String>{};
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/';

    // Deletions: remove one character
    for (var i = 0; i < call.length; i++) {
      variants.add(call.substring(0, i) + call.substring(i + 1));
    }

    // Substitutions: replace one character
    for (var i = 0; i < call.length; i++) {
      for (final ch in chars.split('')) {
        if (ch != call[i]) {
          variants.add(call.substring(0, i) + ch + call.substring(i + 1));
        }
      }
    }

    // Insertions: add one character
    for (var i = 0; i <= call.length; i++) {
      for (final ch in chars.split('')) {
        variants.add(call.substring(0, i) + ch + call.substring(i));
      }
    }

    return variants;
  }
}

/// Parser for MASTER.SCP format files.
///
/// Provides a static [parse] method to convert MASTER.SCP formatted strings
/// into [ScpDatabase] instances. Consider using [ScpDatabase.parse] directly
/// instead for cleaner code.
@immutable
final class ScpParser {
  const new _();

  /// Parses a MASTER.SCP formatted string.
  ///
  /// Equivalent to [ScpDatabase.parse]. Consider using [ScpDatabase.parse]
  /// directly instead.
  static ScpDatabase parse(String text) => ScpDatabase.parse(text);
}
