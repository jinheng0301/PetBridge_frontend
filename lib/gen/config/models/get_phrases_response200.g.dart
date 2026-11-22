// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_phrases_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPhrasesResponse200 _$GetPhrasesResponse200FromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return GetPhrasesResponse200(
    data: PhraseBook.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        GetPhrasesResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : GetPhrasesResponse200._readExtras(
            GetPhrasesResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$GetPhrasesResponse200ToJson(
  GetPhrasesResponse200 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
