import 'dart:math';

import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

const potaCsv = '''
"reference","name","active","entityId","locationDesc","latitude","longitude","grid"
"US-0001","Acadia National Park","1","291","US-ME","44.31","-68.2034","FN54vh"
"US-0002","Retired Park","0","6","US-AK","59.0908","-156.463","BO19sc"
"BAD","Not a reference","1","1","US-AK","1","2","AA00aa"
"DE-0123","Nowhere","1","1","DE-BY","","","JN58"
"US-0004","Off the map","1","1","US-AK","95","200","JN58"
''';

const sotaCsv = '''
SOTA Summits List (Date=03/10/2026)
SummitCode,AssociationName,RegionName,SummitName,AltM,AltFt,GridRef1,GridRef2,Longitude,Latitude,Points,BonusPoints,ValidFrom,ValidTo,ActivationCount,ActivationDate,ActivationCall
3B8/MU-001,Mauritius,Mauritius,"Piton de la Petite Rivière Noire (Black River Peak)",828,2716,57.40771,-20.40882,57.40771,-20.40882,10,0,01/08/2026,31/12/2099,0,,
G/LD-001,England,Lake District,Scafell Pike,978,3209,-3.2,54.4,-3.21165,54.45444,10,3,01/05/2023,30/04/2024,5,01/06/2023,M0ABC
xx,short,row
''';

const wwffCsv = '''
reference,status,name,program,dxcc,state,county,continent,iota,iaruLocator,latitude,longitude,IUCNcat,validFrom,validTo,notes,lastMod,changeLog,reviewFlag,specialFlags,website,country,region,dxccEnum,qsoCount,lastAct
DLFF-0001,active,"Nationalpark, Bayerischer Wald",DLFF,DL,BY,-,EU,-,JN68,48.9,13.4,n/a,0000-00-00,0000-00-00,-,"x","y",0,,-,Germany,-,230,5,
DLFF-0003,national,National list,DLFF,DL,BY,-,EU,-,JN68,48.9,13.4,n/a,0000-00-00,0000-00-00,-,"x","y",0,,-,Germany,-,230,5,
DLFF-0002,deleted,Old,DLFF,DL,BY,-,EU,-,JN68,48.9,13.4,n/a,2020-01-01,2022-12-31,-,"x","y",0,,-,Germany,-,230,5,
''';

Future<(List<ProgramReference>, ReferencePackParser)> run(
  ReferenceProgram program,
  String text,
) async {
  final parser = ReferencePackParser(program);
  final list = await parser.parse(Stream.value(text)).toList();
  return (list, parser);
}

void main() {
  fuzz();
  group('POTA', () {
    test('parses rows, skips invalid ones and counts them', () async {
      final (list, parser) = await run(ReferenceProgram.pota, potaCsv);
      expect(list.map((r) => r.reference), [
        'US-0001',
        'US-0002',
        'DE-0123',
        'US-0004',
      ]);
      expect(parser.rowCount, 5);
      expect(parser.skipped, 1);
      final acadia = list.first;
      expect(acadia.name, 'Acadia National Park');
      expect(acadia.region, 'US-ME');
      expect(acadia.latitude, 44.31);
      expect(acadia.longitude, -68.2034);
      expect(acadia.active, isTrue);
      expect(list[1].active, isFalse);
      expect(list[2].latitude, isNull);
      // Coordinates outside the valid range are dropped, not trusted.
      expect(list[3].latitude, isNull);
      expect(list[3].longitude, isNull);
    });
  });

  group('SOTA', () {
    test(
      'reads the title date and swaps longitude/latitude correctly',
      () async {
        final (list, parser) = await run(ReferenceProgram.sota, sotaCsv);
        expect(parser.sourceDate, DateTime.utc(2026, 10, 3));
        expect(list.map((r) => r.reference), ['3B8/MU-001', 'G/LD-001']);
        expect(parser.skipped, 1);
        final scafell = list[1];
        expect(scafell.name, 'Scafell Pike');
        expect(scafell.region, 'Lake District');
        expect(scafell.latitude, 54.45444);
        expect(scafell.longitude, -3.21165);
        expect(scafell.validFrom, DateTime.utc(2023, 5));
        expect(scafell.validTo, DateTime.utc(2024, 4, 30));
        expect(scafell.isValidOn(DateTime.utc(2023, 12, 1, 15)), isTrue);
        expect(scafell.isValidOn(DateTime.utc(2024, 5)), isFalse);
      },
    );
  });

  group('WWFF', () {
    test('parses quoted commas, status and unset dates', () async {
      final (list, _) = await run(ReferenceProgram.wwff, wwffCsv);
      expect(list.length, 3);
      expect(list[1].active, isTrue, reason: 'national entries are usable');
      expect(list[0].name, 'Nationalpark, Bayerischer Wald');
      expect(list[0].region, 'Germany');
      expect(list[0].active, isTrue);
      expect(list[0].validFrom, isNull);
      expect(list[0].validTo, isNull);
      expect(list[2].active, isFalse);
      expect(list[2].validTo, DateTime.utc(2022, 12, 31));
    });
  });

  group('rejection', () {
    test('a file of the wrong programme is refused', () async {
      expect(
        run(ReferenceProgram.sota, potaCsv),
        throwsA(isA<ReferencePackFormatException>()),
      );
      expect(
        run(ReferenceProgram.pota, wwffCsv),
        throwsA(isA<ReferencePackFormatException>()),
      );
    });

    test('empty, HTML and binary-looking input is refused', () async {
      for (final text in [
        '',
        '<html><body>Blocked</body></html>\n',
        '\u0000\u0001\n',
      ]) {
        expect(
          run(ReferenceProgram.pota, text),
          throwsA(isA<ReferencePackFormatException>()),
          reason: text,
        );
      }
    });

    test('the row cap is enforced', () async {
      final parser = ReferencePackParser(ReferenceProgram.pota, maxRows: 2);
      expect(
        parser.parse(Stream.value(potaCsv)).toList(),
        throwsA(isA<ReferencePackFormatException>()),
      );
    });

    test('malformed CSV surfaces as a pack format error', () async {
      expect(
        run(ReferenceProgram.pota, '"reference","name\n'),
        throwsA(isA<ReferencePackFormatException>()),
      );
    });

    test('reference shapes', () {
      expect(ReferenceProgram.pota.isValidReference('US-0001'), isTrue);
      expect(ReferenceProgram.pota.isValidReference('us-0001'), isFalse);
      expect(ReferenceProgram.sota.isValidReference('W7W/LC-001'), isTrue);
      expect(ReferenceProgram.sota.isValidReference('G/LD-1'), isFalse);
      expect(ReferenceProgram.wwff.isValidReference('KFF-1234'), isTrue);
      expect(ReferenceProgram.wwff.isValidReference('KFF-12'), isFalse);
      expect(ReferenceProgram.wwff.myAdifField, 'MY_WWFF_REF');
      expect(ReferenceProgram.tryParse('POTA'), ReferenceProgram.pota);
      expect(ReferenceProgram.tryParse('XYZ'), isNull);
    });
  });
}

void fuzz() {
  test(
    'fuzz: mutated files parse or throw ReferencePackFormatException',
    () async {
      final random = Random(4);
      for (final program in ReferenceProgram.values) {
        final base = switch (program) {
          ReferenceProgram.pota => potaCsv,
          ReferenceProgram.sota => sotaCsv,
          ReferenceProgram.wwff => wwffCsv,
        };
        for (var i = 0; i < 300; i++) {
          final chars = base.split('');
          for (var m = 0; m < 1 + random.nextInt(6); m++) {
            final at = random.nextInt(chars.length);
            switch (random.nextInt(3)) {
              case 0:
                chars[at] = '"';
              case 1:
                chars[at] = String.fromCharCode(random.nextInt(0x250));
              default:
                chars.removeAt(at);
            }
          }
          try {
            await ReferencePackParser(program)
                .parse(Stream.value(chars.join()))
                .toList();
          } on ReferencePackFormatException {
            // Expected for broken input.
          }
        }
      }
    },
  );
}
