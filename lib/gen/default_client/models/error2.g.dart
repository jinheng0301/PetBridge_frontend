// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Error2 _$Error2FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['error'],
    disallowNullValues: const ['error'],
  );
  return Error2(
    error: Error2Error.fromJson(json['error'] as Map<String, dynamic>),
    additionalProperties: Error2._extras(json, 'additionalProperties') == null
        ? const {}
        : Error2._readExtras(Error2._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$Error2ToJson(Error2 instance) => <String, dynamic>{
  'error': instance.error.toJson(),
};
