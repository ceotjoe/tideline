import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

Future<List<List<String>>> rows(Iterable<String> chunks) =>
    csvRows(Stream.fromIterable(chunks)).toList();

void main() {
  group('csvRows', () {
    test('plain and quoted fields', () async {
      expect(await rows(['a,"b,c",d\n1,2,3\n']), [
        ['a', 'b,c', 'd'],
        ['1', '2', '3'],
      ]);
    });

    test('escaped quotes and line breaks inside quotes', () async {
      expect(await rows(['"say ""hi""","x\ny"\n']), [
        ['say "hi"', 'x\ny'],
      ]);
    });

    test('empty fields, CRLF, blank lines, no final newline', () async {
      expect(await rows(['a,,c\r\n\r\n,\r\nz']), [
        ['a', '', 'c'],
        ['', ''],
        ['z'],
      ]);
    });

    test('chunks may end anywhere, even inside an escaped quote', () async {
      const text = 'a,"x""y",c\r\n"q",2\n';
      final expected = await rows([text]);
      for (var cut = 1; cut < text.length; cut++) {
        expect(
          await rows([text.substring(0, cut), text.substring(cut)]),
          expected,
          reason: 'cut at $cut',
        );
      }
      expect(await rows(text.split('')), expected);
    });

    test('rejects an unclosed quote, a stray quote and huge input', () {
      expect(rows(['"abc']), throwsA(isA<CsvFormatException>()));
      expect(rows(['ab"c\n']), throwsA(isA<CsvFormatException>()));
      expect(
        csvRows(Stream.value('${'x' * 100}\n'), maxFieldLength: 50).toList(),
        throwsA(isA<CsvFormatException>()),
      );
      expect(
        csvRows(Stream.value('a,b,c\n'), maxColumns: 2).toList(),
        throwsA(isA<CsvFormatException>()),
      );
    });
  });
}
