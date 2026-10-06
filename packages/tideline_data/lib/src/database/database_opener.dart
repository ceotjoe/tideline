import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Opens [file] as a plain SQLite database on a background isolate.
///
/// Tideline adds no encryption of its own (ADR 0034); at-rest protection is
/// the operating system's.
QueryExecutor openDatabaseExecutor(File file) =>
    NativeDatabase.createInBackground(file);

const List<int> _sqliteHeader = [
  0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, // "SQLite f"
  0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00, // "ormat 3\0"
];

/// Whether [file] is a database file that plain SQLite can open.
///
/// An empty or missing file counts as readable (SQLite creates it).
bool isReadableDatabase(File file) {
  if (!file.existsSync()) return true;
  final raf = file.openSync();
  try {
    final head = raf.readSync(_sqliteHeader.length);
    if (head.isEmpty) return true;
    if (head.length < _sqliteHeader.length) return false;
    for (var i = 0; i < _sqliteHeader.length; i++) {
      if (head[i] != _sqliteHeader[i]) return false;
    }
    return true;
  } finally {
    raf.closeSync();
  }
}

/// Renames a database that plain SQLite cannot read (one that Tideline 0.5.x
/// encrypted) and its journal files out of the way, so the app can start with
/// an empty log. Nothing is deleted.
///
/// Returns the new path of the database file, or `null` if [file] was
/// readable and left alone.
Future<String?> moveUnreadableDatabaseAside(
  File file, {
  required DateTime now,
}) async {
  if (isReadableDatabase(file)) return null;
  final stamp = now.toUtc().millisecondsSinceEpoch;
  final target = '${file.path}.unreadable-$stamp';
  await file.rename(target);
  for (final suffix in const ['-wal', '-shm', '-journal']) {
    final sidecar = File('${file.path}$suffix');
    if (sidecar.existsSync()) await sidecar.rename('$target$suffix');
  }
  return target;
}
