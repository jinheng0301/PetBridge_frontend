// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeInfo _$CodeInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['code', 'expires_at'],
    disallowNullValues: const ['code', 'expires_at'],
  );
  return CodeInfo(
    code: json['code'] as String,
    expiresAt: CodeInfo._read_expiresAt(json['expires_at']),
    additionalProperties: CodeInfo._extras(json, 'additionalProperties') == null
        ? const {}
        : CodeInfo._readExtras(CodeInfo._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CodeInfoToJson(CodeInfo instance) => <String, dynamic>{
  'code': instance.code,
  'expires_at': ?CodeInfo._write_expiresAt(instance.expiresAt),
};
