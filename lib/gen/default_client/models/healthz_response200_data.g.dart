// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'healthz_response200_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthzResponse200Data _$HealthzResponse200DataFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, disallowNullValues: const ['status']);
  return HealthzResponse200Data(
    status: HealthzResponse200Data._read_status(json['status']),
    additionalProperties:
        HealthzResponse200Data._extras(json, 'additionalProperties') == null
        ? const {}
        : HealthzResponse200Data._readExtras(
            HealthzResponse200Data._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$HealthzResponse200DataToJson(
  HealthzResponse200Data instance,
) => <String, dynamic>{
  'status': ?HealthzResponse200Data._write_status(instance.status),
};
