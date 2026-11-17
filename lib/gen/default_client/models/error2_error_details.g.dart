// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error2_error_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Error2ErrorDetails _$Error2ErrorDetailsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    disallowNullValues: const ['fields', 'room_id', 'retry_after_seconds'],
  );
  return Error2ErrorDetails(
    fields: (json['fields'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    roomId: json['room_id'] as String?,
    retryAfterSeconds: Error2ErrorDetails._read_retryAfterSeconds(
      json['retry_after_seconds'],
    ),
    additionalProperties:
        Error2ErrorDetails._extras(json, 'additionalProperties') == null
        ? const {}
        : Error2ErrorDetails._readExtras(
            Error2ErrorDetails._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$Error2ErrorDetailsToJson(Error2ErrorDetails instance) =>
    <String, dynamic>{
      'fields': ?instance.fields,
      'room_id': ?instance.roomId,
      'retry_after_seconds': ?Error2ErrorDetails._write_retryAfterSeconds(
        instance.retryAfterSeconds,
      ),
    };
