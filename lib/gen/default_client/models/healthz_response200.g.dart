// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'healthz_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthzResponse200 _$HealthzResponse200FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return HealthzResponse200(
    data: HealthzResponse200Data.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        HealthzResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : HealthzResponse200._readExtras(
            HealthzResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$HealthzResponse200ToJson(HealthzResponse200 instance) =>
    <String, dynamic>{'data': instance.data.toJson()};
