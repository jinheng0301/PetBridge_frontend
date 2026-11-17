// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDetail _$RoomDetailFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'is_owner',
      'status',
      'member_count',
      'capacity',
      'members',
    ],
    disallowNullValues: const [
      'id',
      'is_owner',
      'status',
      'member_count',
      'capacity',
      'members',
    ],
  );
  return RoomDetail(
    id: json['id'] as String,
    isOwner: json['is_owner'] as bool,
    status: RoomDetail._read_status(json['status']),
    memberCount: RoomDetail._read_memberCount(json['member_count']),
    capacity: RoomDetail._read_capacity(json['capacity']),
    members: (json['members'] as List<dynamic>)
        .map((e) => MemberInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        RoomDetail._extras(json, 'additionalProperties') == null
        ? const {}
        : RoomDetail._readExtras(
            RoomDetail._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RoomDetailToJson(RoomDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_owner': instance.isOwner,
      'status': ?RoomDetail._write_status(instance.status),
      'member_count': ?RoomDetail._write_memberCount(instance.memberCount),
      'capacity': ?RoomDetail._write_capacity(instance.capacity),
      'members': instance.members.map((e) => e.toJson()).toList(),
    };
