import 'dart:ui';

const _en = Locale('en');
const _ja = Locale('ja');
const _ko = Locale('ko');
const _zhHans = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
const _zhHant = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');

const _hantRegions = {'TW', 'HK', 'MO'};

/// Maps a system locale onto one of the five app languages. Chinese uses the
/// script subtag when present, else the region (TW/HK/MO → Traditional);
/// anything unsupported falls back to English.
Locale resolveAppLocale(Locale system) => switch (system.languageCode) {
  'ja' => _ja,
  'ko' => _ko,
  'zh' => switch (system.scriptCode) {
    'Hant' => _zhHant,
    'Hans' => _zhHans,
    _ => _hantRegions.contains(system.countryCode) ? _zhHant : _zhHans,
  },
  _ => _en,
};
