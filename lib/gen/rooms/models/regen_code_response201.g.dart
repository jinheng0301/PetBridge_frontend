// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'regen_code_response201.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegenCodeResponse201 _$RegenCodeResponse201FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return RegenCodeResponse201(
    data: CodeInfo.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        RegenCodeResponse201._extras(json, 'additionalProperties') == null
        ? const {}
        : RegenCodeResponse201._readExtras(
            RegenCodeResponse201._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RegenCodeResponse201ToJson(
  RegenCodeResponse201 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
