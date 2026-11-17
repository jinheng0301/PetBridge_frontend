// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dissolve_room_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DissolveRoomResponse200 _$DissolveRoomResponse200FromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return DissolveRoomResponse200(
    data: RoomResult.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        DissolveRoomResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : DissolveRoomResponse200._readExtras(
            DissolveRoomResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$DissolveRoomResponse200ToJson(
  DissolveRoomResponse200 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
