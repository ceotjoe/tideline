# Translating Tideline

Tideline's user interface and manual can be translated without touching any Dart code.

## App strings

All user-facing strings live in ARB files (JSON) in `app/lib/l10n/arb/`:

- `app_en.arb`: the **template**. English source strings with descriptions (`@key` entries) for translators.
- `app_de.arb`: German.
- `app_<locale>.arb`: add yours here, for example `app_fr.arb` or `app_pt_BR.arb`.

### Adding a language

1. Copy `app_en.arb` to `app_<locale>.arb` and set `"@@locale": "<locale>"`.
2. Translate every value. Keep:
   - **placeholders** such as `{count}` and `{callsign}` unchanged;
   - **ICU plural/select syntax** (`{count, plural, =0{…} =1{…} other{…}}`) structurally intact. Add the plural forms
     your language needs (`few`, `many`, …).
3. Do not translate the `@key` metadata entries. Read their `description` for context.
4. Ham-radio terms the community expects (QSO, RST, grid, DXCC, SOTA, POTA, WWFF) are usually kept as-is.
   Use whatever operators in your language really say.
5. Open a pull request. CI checks that every key exists in every language and that placeholders match.

A missing key falls back to English, so a partial translation is fine to start with.

### Right-to-left languages

Tideline supports RTL layouts. When adding Arabic, Hebrew, Persian or Urdu, please check the app with your
locale selected in **Settings → Language**, and report any layout that looks wrong.

## Manual

The user manual lives in `docs/manual/<locale>/`. Copy the `en` folder and translate the Markdown files.
Keep file names identical so pages link correctly.

## Translation platform

We may move to a hosted platform (Weblate or Crowdin) once there are several translators. Until then,
pull requests are the way in.
