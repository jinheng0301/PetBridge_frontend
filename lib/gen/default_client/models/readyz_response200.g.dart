// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readyz_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadyzResponse200 _$ReadyzResponse200FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return ReadyzResponse200(
    data: ReadyzResponse200Data.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        ReadyzResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : ReadyzResponse200._readExtras(
            ReadyzResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ReadyzResponse200ToJson(ReadyzResponse200 instance) =>
    <String, dynamic>{'data': instance.data.toJson()};
