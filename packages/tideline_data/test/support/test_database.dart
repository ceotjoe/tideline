import 'dart:io';

import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';

const testKey =
    '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

/// Opens a fresh encrypted database in a temporary directory that is
/// removed after the test. (Encrypted databases cannot live in memory.)
Future<TidelineDatabase> openTestDatabase() async {
  final dir = await Directory.systemTemp.createTemp('tideline_test_');
  final db = TidelineDatabase(
    openEncryptedExecutor(File('${dir.path}/t.db'), hexKey: testKey),
  );
  addTearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  return db;
}
