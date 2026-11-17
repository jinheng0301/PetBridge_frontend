// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_me_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetMeResponse200 _$GetMeResponse200FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return GetMeResponse200(
    data: Profile.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        GetMeResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : GetMeResponse200._readExtras(
            GetMeResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$GetMeResponse200ToJson(GetMeResponse200 instance) =>
    <String, dynamic>{'data': instance.data.toJson()};
