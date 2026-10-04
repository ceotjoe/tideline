/// The app version, as in `app/pubspec.yaml` (a test keeps them in step).
///
/// Written into exported files (`CREATED-BY`, ADIF `PROGRAMVERSION`) and the
/// User-Agent of the one public download. It is a constant rather than read
/// from the platform, so exports are the same everywhere and need no plugin.
const String appVersion = '0.3.1';
