// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinRequest _$JoinRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['code'],
    disallowNullValues: const ['code'],
  );
  return JoinRequest(
    code: json['code'] as String,
    additionalProperties:
        JoinRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : JoinRequest._readExtras(
            JoinRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$JoinRequestToJson(JoinRequest instance) =>
    <String, dynamic>{'code': instance.code};
