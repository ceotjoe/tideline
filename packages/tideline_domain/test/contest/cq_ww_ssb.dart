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
