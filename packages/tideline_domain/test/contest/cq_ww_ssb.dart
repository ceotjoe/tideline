/// The CQ WW SSB example from docs/architecture/contest-definitions.md.
const String cqWwSsbJson = '''
{
  "schema": 1,
  "id": "cq-ww-ssb",
  "version": 1,
  "name": "CQ World Wide DX Contest (SSB)",
  "cabrillo": "CQ-WW-SSB",
  "adif": "CQ-WW-SSB",
  "modes": ["PHONE"],
  "bands": ["160m", "80m", "40m", "20m", "15m", "10m"],
  "exchange": {
    "sent": [
      { "kind": "rst" },
      { "kind": "cqZone", "default": "{MY_CQ_ZONE}" }
    ],
    "rcvd": [
      { "kind": "rst" },
      { "kind": "cqZone" }
    ]
  },
  "dupe": { "per": ["band", "modeCategory"] },
  "points": [
    { "when": { "sameDxcc": true }, "points": 0 },
    { "when": { "sameContinent": false }, "points": 3 },
    { "when": { "myContinent": "NA", "theirContinent": "NA" }, "points": 2 },
    { "points": 1 }
  ],
  "multipliers": [
    { "id": "zone", "source": "rcvd:cqZone", "per": "band" },
    { "id": "country", "source": "dxcc", "per": "band" }
  ],
  "score": "pointsTimesMultipliers"
}
''';

/// A WAG-like definition with a variant for DL stations.
const String variantJson = '''
{
  "schema": 1,
  "id": "wag-test",
  "version": 2,
  "name": "Worked All Germany (test)",
  "adif": "DARC-WAEDC-SSB",
  "modes": ["CW", "PHONE"],
  "bands": ["80m", "40m", "20m"],
  "exchange": {
    "sent": [{ "kind": "rst" }, { "kind": "serial" }],
    "rcvd": [{ "kind": "rst" }, { "kind": "serial" }, { "kind": "dok", "optional": true }],
    "variants": [
      {
        "when": { "myDxcc": 230 },
        "sent": [{ "kind": "rst" }, { "kind": "serial" }, { "kind": "dok", "default": "{MY_DOK}" }]
      }
    ]
  },
  "dupe": { "per": ["band", "mode"] },
  "points": [
    { "when": { "theirContinent": ["EU"] }, "points": 3 },
    { "points": 5 }
  ],
  "multipliers": [
    { "id": "dok", "source": "rcvd:dok", "per": "contest", "when": { "theirDxcc": 230 } }
  ],
  "score": "pointsTimesMultipliers"
}
''';

/// A WAG-like definition using the extended rule language: received
/// elements keyed on the other station, negated lists, zone predicates and
/// the DOK district multiplier.
const String elementWhenJson = '''
{
  "schema": 1,
  "id": "alt-test",
  "version": 1,
  "name": "Alternatives (test)",
  "modes": ["CW", "PHONE"],
  "bands": ["80m", "40m", "20m"],
  "exchange": {
    "sent": [{ "kind": "rst" }, { "kind": "dok", "default": "{MY_DOK}" }],
    "rcvd": [{ "kind": "rst" }],
    "variants": [
      {
        "when": { "myDxcc": 230, "myContinentNot": "AF" },
        "rcvd": [
          { "kind": "rst" },
          { "kind": "serial", "when": { "theirDxccNot": 230 } },
          { "kind": "dok", "when": { "theirDxcc": 230 } }
        ]
      }
    ]
  },
  "dupe": { "per": ["band", "mode"] },
  "points": [
    { "when": { "sameCqZone": true, "myDxccNot": [1, 291] }, "points": 1 },
    { "when": { "sameItuZone": false, "theirContinentNot": ["AF"] }, "points": 2 },
    { "points": 3 }
  ],
  "multipliers": [
    { "id": "district", "source": "dokDistrict", "per": "bandMode" }
  ],
  "score": "pointsTimesMultipliers"
}
''';
