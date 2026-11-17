// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readyz_response200_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadyzResponse200Data _$ReadyzResponse200DataFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, disallowNullValues: const ['status', 'redis']);
  return ReadyzResponse200Data(
    status: ReadyzResponse200Data._read_status(json['status']),
    redis: ReadyzResponse200Data._read_redis(json['redis']),
    additionalProperties:
        ReadyzResponse200Data._extras(json, 'additionalProperties') == null
        ? const {}
        : ReadyzResponse200Data._readExtras(
            ReadyzResponse200Data._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ReadyzResponse200DataToJson(
  ReadyzResponse200Data instance,
) => <String, dynamic>{
  'status': ?ReadyzResponse200Data._write_status(instance.status),
  'redis': ?ReadyzResponse200Data._write_redis(instance.redis),
};
