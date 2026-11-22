// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_book_phrases_item_texts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseBookPhrasesItemTexts _$PhraseBookPhrasesItemTextsFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['ja', 'ko', 'zh-Hant', 'zh-Hans', 'en'],
    disallowNullValues: const ['ja', 'ko', 'zh-Hant', 'zh-Hans', 'en'],
  );
  return PhraseBookPhrasesItemTexts(
    ja: json['ja'] as String,
    ko: json['ko'] as String,
    zhHant: json['zh-Hant'] as String,
    zhHans: json['zh-Hans'] as String,
    en: json['en'] as String,
    additionalProperties:
        PhraseBookPhrasesItemTexts._extras(json, 'additionalProperties') == null
        ? const {}
        : PhraseBookPhrasesItemTexts._readExtras(
            PhraseBookPhrasesItemTexts._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PhraseBookPhrasesItemTextsToJson(
  PhraseBookPhrasesItemTexts instance,
) => <String, dynamic>{
  'ja': instance.ja,
  'ko': instance.ko,
  'zh-Hant': instance.zhHant,
  'zh-Hans': instance.zhHans,
  'en': instance.en,
};
