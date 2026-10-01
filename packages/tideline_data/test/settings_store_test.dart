import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';

import 'support/test_database.dart';

void main() {
  test('writes, overwrites and removes values', () async {
    final store = SettingsStore(await openTestDatabase());
    await store.write('theme', 'dark');
    await store.write('theme', 'nightRed');
    await store.write('locale', 'de');
    expect(await store.readAll(), {'theme': 'nightRed', 'locale': 'de'});
    await store.write('locale', null);
    expect(await store.readAll(), {'theme': 'nightRed'});
  });

  test('watchAll emits changes', () async {
    final store = SettingsStore(await openTestDatabase());
    final expectation = expectLater(
      store.watchAll(),
      emitsThrough({'density': 'glove'}),
    );
    await store.write('density', 'glove');
    await expectation;
  });

  test('shortcut overrides can be set and reset', () async {
    final store = ShortcutBindingStore(await openTestDatabase());
    await store.put((commandId: 'log.save', platform: 'all', binding: 'F5'));
    expect(await store.watchAll().first, [
      (commandId: 'log.save', platform: 'all', binding: 'F5'),
    ]);
    await store.reset('log.save', 'all');
    expect(await store.watchAll().first, isEmpty);
  });
}
