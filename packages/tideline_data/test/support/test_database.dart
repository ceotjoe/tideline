import 'dart:io';

import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';

/// Opens a fresh database in a temporary directory that is removed after the
/// test.
Future<TidelineDatabase> openTestDatabase() async {
  final dir = await Directory.systemTemp.createTemp('tideline_test_');
  final db = TidelineDatabase(openDatabaseExecutor(File('${dir.path}/t.db')));
  addTearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  return db;
}
