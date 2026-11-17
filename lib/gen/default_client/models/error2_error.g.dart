// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error2_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Error2Error _$Error2ErrorFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['code', 'message', 'request_id'],
    disallowNullValues: const ['code', 'message', 'request_id', 'details'],
  );
  return Error2Error(
    code: json['code'] as String,
    message: json['message'] as String,
    requestId: json['request_id'] as String,
    details: json['details'] == null
        ? null
        : Error2ErrorDetails.fromJson(json['details'] as Map<String, dynamic>),
    additionalProperties:
        Error2Error._extras(json, 'additionalProperties') == null
        ? const {}
        : Error2Error._readExtras(
            Error2Error._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$Error2ErrorToJson(Error2Error instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'request_id': instance.requestId,
      'details': ?instance.details?.toJson(),
    };
