import 'package:flutter/widgets.dart';

/// Languages are listed by their own name (endonym), which by convention
/// is not translated. This file is allow-listed in the hard-coded string
/// test.
const Map<String, String> languageEndonyms = {'en': 'English', 'de': 'Deutsch'};

/// The endonym for [locale], falling back to its language tag.
String endonymFor(Locale locale) =>
    languageEndonyms[locale.languageCode] ?? locale.toLanguageTag();
