import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

void main() {
  group('newUuidV4', () {
    test('produces canonical version-4 UUIDs', () {
      for (var i = 0; i < 1000; i++) {
        final id = newUuidV4();
        expect(isUuid(id), isTrue, reason: id);
        expect(id[14], '4');
        expect('89ab'.contains(id[19]), isTrue);
      }
    });

    test('does not repeat', () {
      final ids = {for (var i = 0; i < 10000; i++) newUuidV4()};
      expect(ids, hasLength(10000));
    });
  });

  test('isUuid rejects malformed values', () {
    expect(isUuid(''), isFalse);
    expect(isUuid('not-a-uuid'), isFalse);
    expect(isUuid('6F9619FF-8B86-D011-B42D-00C04FC964FF'), isFalse);
  });
}
