// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['refresh_token'],
    disallowNullValues: const ['refresh_token'],
  );
  return RefreshRequest(
    refreshToken: json['refresh_token'] as String,
    additionalProperties:
        RefreshRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : RefreshRequest._readExtras(
            RefreshRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{'refresh_token': instance.refreshToken};
