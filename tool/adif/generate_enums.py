#!/usr/bin/env python3
"""Generates ADIF band and mode tables for tideline_domain from the official
ADIF specification HTML (https://adif.org.uk/317/ADIF_317.htm).

Usage: python3 tool/adif/generate_enums.py path/to/ADIF_317.htm
"""
import html
import re
import sys
from decimal import Decimal

SPEC_VERSION = "3.1.7"
OUT = "packages/tideline_domain/lib/src/adif/adif_enums.g.dart"

def table_after(src, anchor):
    i = src.find(anchor)
    j = src.find("<table", i)
    k = src.find("</table>", j)
    rows = re.findall(r"<tr[^>]*>(.*?)</tr>", src[j:k], re.S | re.I)
    clean = lambda c: re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", "", c)).replace("\xa0", " ")).strip()
    return [[clean(c) for c in re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", r, re.S | re.I)] for r in rows][1:]

def hz(mhz):
    return int(Decimal(mhz) * 1_000_000)

def main(path):
    src = open(path, encoding="utf-8", errors="replace").read()
    bands = table_after(src, 'id="Band_Enumeration"')
    modes = table_after(src, 'id="Mode_Enumeration"')
    out = [
        f"// GENERATED from the ADIF {SPEC_VERSION} specification by",
        "// tool/adif/generate_enums.py. Do not edit by hand.",
        "",
        "// ignore_for_file: public_member_api_docs",
        "",
        f"const String adifSpecVersion = '{SPEC_VERSION}';",
        "",
        "/// ADIF Band enumeration: (name, lower Hz, upper Hz), ascending.",
        "const List<(String, int, int)> adifBandTable = [",
    ]
    for name, lo, hi in bands:
        out.append(f"  ('{name}', {hz(lo)}, {hz(hi)}),")
    out += ["];", "", "/// ADIF Mode enumeration: mode → its submodes.",
            "const Map<String, List<String>> adifModeTable = {"]
    import_only = []
    for name, subs, *_ in modes:
        if "(import-only)" in name:
            import_only.append(name.replace("(import-only)", "").strip())
            continue
        sub_list = [s.strip() for s in re.split(r",", subs) if s.strip()]
        # The spec table misses a comma between MFSK128 and MFSK128L.
        fixed = []
        for s in sub_list:
            fixed.extend(s.split(" ") if s == "MFSK128 MFSK128L" else [s])
        quoted = ", ".join(f"'{s}'" for s in fixed)
        out.append(f"  '{name}': [{quoted}],")
    out += ["};", "", "/// Modes the specification allows only on import.",
            "const List<String> adifImportOnlyModes = ["]
    out += [f"  '{m}'," for m in import_only]
    out += ["];", ""]
    open(OUT, "w").write("\n".join(out))
    print(f"{len(bands)} bands, {len(modes) - len(import_only)} modes, {len(import_only)} import-only → {OUT}")

if __name__ == "__main__":
    main(sys.argv[1])
