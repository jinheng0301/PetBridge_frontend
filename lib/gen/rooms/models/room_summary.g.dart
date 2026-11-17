// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomSummary _$RoomSummaryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'status', 'member_count', 'capacity'],
    disallowNullValues: const ['id', 'status', 'member_count', 'capacity'],
  );
  return RoomSummary(
    id: json['id'] as String,
    status: RoomSummary._read_status(json['status']),
    memberCount: RoomSummary._read_memberCount(json['member_count']),
    capacity: RoomSummary._read_capacity(json['capacity']),
    additionalProperties:
        RoomSummary._extras(json, 'additionalProperties') == null
        ? const {}
        : RoomSummary._readExtras(
            RoomSummary._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RoomSummaryToJson(RoomSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': ?RoomSummary._write_status(instance.status),
      'member_count': ?RoomSummary._write_memberCount(instance.memberCount),
      'capacity': ?RoomSummary._write_capacity(instance.capacity),
    };
