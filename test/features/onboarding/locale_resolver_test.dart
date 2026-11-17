import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/features/onboarding/application/locale_resolver.dart';

void main() {
  const en = Locale('en');
  const ja = Locale('ja');
  const ko = Locale('ko');
  const hans = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  const hant = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');

  final cases = <String, (Locale, Locale)>{
    'fr -> en': (const Locale('fr'), en),
    'en_GB -> en': (const Locale('en', 'GB'), en),
    'zh_TW -> zh_Hant': (const Locale('zh', 'TW'), hant),
    'zh_HK -> zh_Hant': (const Locale('zh', 'HK'), hant),
    'zh_MO -> zh_Hant': (const Locale('zh', 'MO'), hant),
    'zh_CN -> zh_Hans': (const Locale('zh', 'CN'), hans),
    'zh (no region, no script) -> zh_Hans': (const Locale('zh'), hans),
    'ja_JP -> ja': (const Locale('ja', 'JP'), ja),
    'ko_KR -> ko': (const Locale('ko', 'KR'), ko),
    'zh_Hant_TW -> zh_Hant': (
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'TW',
      ),
      hant,
    ),
    'zh_Hans_HK -> zh_Hans (script wins over region)': (
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'HK',
      ),
      hans,
    ),
  };

  for (final MapEntry(key: name, value: (input, expected)) in cases.entries) {
    test(name, () {
      final got = resolveAppLocale(input);
      expect(got, expected);
      // Region is dropped so the result matches a supported locale exactly.
      expect(got.countryCode, isNull);
    });
  }
}
