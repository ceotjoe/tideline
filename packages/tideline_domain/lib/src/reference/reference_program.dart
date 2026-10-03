/// A programme whose references (summits, parks, …) Tideline knows offline.
enum ReferenceProgram {
  /// Summits on the Air.
  sota('SOTA', 'SOTA_REF'),

  /// Parks on the Air.
  pota('POTA', 'POTA_REF'),

  /// World Wide Flora & Fauna.
  wwff('WWFF', 'WWFF_REF');

  new(this.code, this.adifField);

  /// The short name stored in `activations.program` and shown to the user.
  final String code;

  /// The ADIF field for the other station's reference. The own reference
  /// uses the same name with a `MY_` prefix.
  final String adifField;

  /// The ADIF field for the own reference.
  String get myAdifField => 'MY_$adifField';

  /// The program for a stored [code], or null if unknown.
  static ReferenceProgram? tryParse(String code) {
    for (final p in values) {
      if (p.code == code) return p;
    }
    return null;
  }

  /// Whether [reference] has the shape of a reference of this program.
  ///
  /// This checks the format only, not whether the reference exists.
  bool isValidReference(String reference) => switch (this) {
    sota => _sota.hasMatch(reference),
    pota => _pota.hasMatch(reference),
    wwff => _wwff.hasMatch(reference),
  };

  // 3B8/MU-001, G/LD-001, W7W/LC-001
  static final RegExp _sota = RegExp(r'^[A-Z0-9]{1,4}/[A-Z]{2}-\d{3}$');
  // US-0001, K-12345, DE-0123
  static final RegExp _pota = RegExp(r'^[A-Z0-9]{1,4}-\d{4,6}$');
  // DLFF-0001, 1SFF-0001, KFF-1234
  static final RegExp _wwff = RegExp(r'^[A-Z0-9]{1,4}FF-\d{4}$');
}
