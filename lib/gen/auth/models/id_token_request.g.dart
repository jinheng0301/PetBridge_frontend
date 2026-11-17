// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IDTokenRequest _$IDTokenRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id_token'],
    disallowNullValues: const ['id_token'],
  );
  return IDTokenRequest(
    idToken: json['id_token'] as String,
    additionalProperties:
        IDTokenRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : IDTokenRequest._readExtras(
            IDTokenRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$IDTokenRequestToJson(IDTokenRequest instance) =>
    <String, dynamic>{'id_token': instance.idToken};
