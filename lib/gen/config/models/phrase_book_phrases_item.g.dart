// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_book_phrases_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseBookPhrasesItem _$PhraseBookPhrasesItemFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'texts'],
    disallowNullValues: const ['id', 'texts'],
  );
  return PhraseBookPhrasesItem(
    id: json['id'] as String,
    texts: PhraseBookPhrasesItemTexts.fromJson(
      json['texts'] as Map<String, dynamic>,
    ),
    additionalProperties:
        PhraseBookPhrasesItem._extras(json, 'additionalProperties') == null
        ? const {}
        : PhraseBookPhrasesItem._readExtras(
            PhraseBookPhrasesItem._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PhraseBookPhrasesItemToJson(
  PhraseBookPhrasesItem instance,
) => <String, dynamic>{'id': instance.id, 'texts': instance.texts.toJson()};
