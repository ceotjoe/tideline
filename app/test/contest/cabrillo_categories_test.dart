import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/app_version.dart';
import 'package:tideline/src/features/contest/cabrillo_categories.dart';

void main() {
  // Cabrillo 3.0 header values, copied from the WWROF specification
  // (https://wwrof.org/cabrillo/cabrillo-v3-header/).
  const spec = <String, List<String>>{
    'CATEGORY-OPERATOR': ['SINGLE-OP', 'MULTI-OP', 'CHECKLOG'],
    'CATEGORY-ASSISTED': ['ASSISTED', 'NON-ASSISTED'],
    'CATEGORY-BAND': [
      'ALL', '160M', '80M', '40M', '20M', '15M', '10M', '6M', '4M', '2M', //
      '222', '432', '902', '1.2G', '2.3G', '3.4G', '5.7G', '10G', '24G',
      '47G', '75G', '122G', '134G', '241G', 'Light', 'VHF-3-BAND',
      'VHF-FM-ONLY',
    ],
    'CATEGORY-MODE': ['CW', 'DIGI', 'FM', 'RTTY', 'SSB', 'MIXED'],
    'CATEGORY-POWER': ['HIGH', 'LOW', 'QRP'],
    'CATEGORY-STATION': [
      'DISTRIBUTED', 'FIXED', 'MOBILE', 'PORTABLE', 'ROVER', //
      'ROVER-LIMITED', 'ROVER-UNLIMITED', 'EXPEDITION', 'HQ', 'SCHOOL',
      'EXPLORER',
    ],
    'CATEGORY-TIME': ['6-HOURS', '8-HOURS', '12-HOURS', '24-HOURS'],
    'CATEGORY-TRANSMITTER': ['ONE', 'TWO', 'LIMITED', 'UNLIMITED', 'SWL'],
    'CATEGORY-OVERLAY': [
      'CLASSIC', 'ROOKIE', 'TB-WIRES', 'YOUTH', 'NOVICE-TECH', 'YL', //
    ],
  };

  test('the category dropdowns offer exactly the Cabrillo 3.0 values', () {
    expect({for (final c in CabrilloCategory.values) c.tag}, spec.keys.toSet());
    for (final c in CabrilloCategory.values) {
      expect(c.tokens, unorderedEquals(spec[c.tag]!), reason: c.tag);
    }
  });

  test('appVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([0-9.]+)',
      multiLine: true,
    ).firstMatch(pubspec)![1];
    expect(appVersion, version);
  });

  test('msix_version is the app version with a fourth part of 0', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final msix = RegExp(
      r'^\s*msix_version:\s*([0-9.]+)',
      multiLine: true,
    ).firstMatch(pubspec)![1];
    expect(msix, '$appVersion.0');
  });

  for (final platform in ['ios', 'macos']) {
    test(
      'the $platform privacy manifest declares no tracking or collection',
      () {
        final manifest = File('$platform/Runner/PrivacyInfo.xcprivacy')
            .readAsStringSync();
        expect(
          manifest,
          matches(RegExp(r'<key>NSPrivacyTracking</key>\s*<false/>')),
        );
        expect(
          manifest,
          matches(RegExp(r'<key>NSPrivacyCollectedDataTypes</key>\s*<array/>')),
        );
        // What the bundled SQLite uses: file timestamps and disk space.
        expect(manifest, contains('NSPrivacyAccessedAPICategoryFileTimestamp'));
        expect(manifest, contains('NSPrivacyAccessedAPICategoryDiskSpace'));
      },
    );
  }
}
