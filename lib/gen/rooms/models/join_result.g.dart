// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinResult _$JoinResultFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['room', 'seat_no', 'members', 'rewards'],
    disallowNullValues: const ['room', 'seat_no', 'members', 'rewards'],
  );
  return JoinResult(
    room: RoomSummary.fromJson(json['room'] as Map<String, dynamic>),
    seatNo: JoinResult._read_seatNo(json['seat_no']),
    members: (json['members'] as List<dynamic>)
        .map((e) => MemberInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    rewards: (json['rewards'] as List<dynamic>)
        .map((e) => CodeInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        JoinResult._extras(json, 'additionalProperties') == null
        ? const {}
        : JoinResult._readExtras(
            JoinResult._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$JoinResultToJson(JoinResult instance) =>
    <String, dynamic>{
      'room': instance.room.toJson(),
      'seat_no': ?JoinResult._write_seatNo(instance.seatNo),
      'members': instance.members.map((e) => e.toJson()).toList(),
      'rewards': instance.rewards.map((e) => e.toJson()).toList(),
    };
