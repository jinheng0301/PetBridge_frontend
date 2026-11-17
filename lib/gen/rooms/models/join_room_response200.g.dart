// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_room_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinRoomResponse200 _$JoinRoomResponse200FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return JoinRoomResponse200(
    data: JoinResult.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        JoinRoomResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : JoinRoomResponse200._readExtras(
            JoinRoomResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$JoinRoomResponse200ToJson(
  JoinRoomResponse200 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
