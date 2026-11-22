// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseBook _$PhraseBookFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['version', 'phrases'],
    disallowNullValues: const ['version', 'phrases'],
  );
  return PhraseBook(
    version: json['version'] as String,
    phrases: (json['phrases'] as List<dynamic>)
        .map((e) => PhraseBookPhrasesItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        PhraseBook._extras(json, 'additionalProperties') == null
        ? const {}
        : PhraseBook._readExtras(
            PhraseBook._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PhraseBookToJson(PhraseBook instance) =>
    <String, dynamic>{
      'version': instance.version,
      'phrases': instance.phrases.map((e) => e.toJson()).toList(),
    };
