// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomResult _$RoomResultFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['room'],
    disallowNullValues: const ['room'],
  );
  return RoomResult(
    room: RoomSummary.fromJson(json['room'] as Map<String, dynamic>),
    additionalProperties:
        RoomResult._extras(json, 'additionalProperties') == null
        ? const {}
        : RoomResult._readExtras(
            RoomResult._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RoomResultToJson(RoomResult instance) =>
    <String, dynamic>{'room': instance.room.toJson()};
