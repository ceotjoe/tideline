# 0017. ADIF import and export

- Status: accepted
- Date: 2026-10-02

## Context
- ADIF 3.1.7 defines two formats.
  - ADI is tag-based and defined as ASCII; international text is only allowed in the XML format ADX.
  - Real ADI files from other loggers contain UTF-8 anyway. Their lengths count bytes in PHP-based loggers such as
    Wavelog and Cloudlog, and characters in others. Legacy Windows tools write Latin-1.
- Imported files are untrusted input (threat T4).

## Decision
- **Format:** ADI import and export in the MVP. ADX follows in a later milestone.
- **Import is tolerant but strict about structure.** For each value the parser tries, in this order:
  1. the length counted in bytes, as valid UTF-8 ending at a tag or whitespace;
  2. the length counted in characters, ending at a tag or whitespace;
  3. the byte interpretation without a boundary;
  4. Latin-1, with a warning.
- **Malformed input never throws.** Bad tags, truncated fields, duplicate fields and a missing `<EOR>` become warnings
  that are shown to the user. Only the size limits throw: 500,000 records and 64 KiB per field. The parser is
  fuzz-tested.
- **Headerless files:** a UTF-8 byte-order mark and leading whitespace are skipped. A file without `<EOH>` before its
  first `<EOR>` is treated as headerless.
- **Mapping to QSOs:**
  - Required fields: CALL, QSO_DATE and TIME_ON, BAND or an in-band FREQ, and a MODE from the 3.1.7 enumeration.
  - Submodes and import-only modes are mapped to their parent mode, as the spec requires.
  - Every other field, including `APP_*` and user-defined fields, is kept verbatim.
  - TIME_OFF without QSO_DATE_OFF that lies before TIME_ON rolls over to the next day.
- **Export:** UTF-8 with byte lengths (what Wavelog reads), upper-case field names, empty values omitted, and a
  header with ADIF_VER 3.1.7, PROGRAMID, PROGRAMVERSION and CREATED_TIMESTAMP.

## Consequences
- Files from common loggers import without manual fixes, and export → import is lossless (tested).
- A file that is both malformed and ambiguous may still decode a field differently than its author intended. The
  warnings list makes this visible.
