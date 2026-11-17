// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_result_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingResultRoom _$OnboardingResultRoomFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'member_count', 'capacity'],
    disallowNullValues: const ['id', 'member_count', 'capacity'],
  );
  return OnboardingResultRoom(
    id: json['id'] as String,
    memberCount: OnboardingResultRoom._read_memberCount(json['member_count']),
    capacity: OnboardingResultRoom._read_capacity(json['capacity']),
    additionalProperties:
        OnboardingResultRoom._extras(json, 'additionalProperties') == null
        ? const {}
        : OnboardingResultRoom._readExtras(
            OnboardingResultRoom._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OnboardingResultRoomToJson(
  OnboardingResultRoom instance,
) => <String, dynamic>{
  'id': instance.id,
  'member_count': ?OnboardingResultRoom._write_memberCount(
    instance.memberCount,
  ),
  'capacity': ?OnboardingResultRoom._write_capacity(instance.capacity),
};
