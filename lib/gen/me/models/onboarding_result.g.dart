// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingResult _$OnboardingResultFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['user', 'pet', 'room', 'invite_code'],
    disallowNullValues: const ['user', 'pet', 'room', 'invite_code'],
  );
  return OnboardingResult(
    user: Profile.fromJson(json['user'] as Map<String, dynamic>),
    pet: OnboardingResultPet.fromJson(json['pet'] as Map<String, dynamic>),
    room: OnboardingResultRoom.fromJson(json['room'] as Map<String, dynamic>),
    inviteCode: OnboardingResultInviteCode.fromJson(
      json['invite_code'] as Map<String, dynamic>,
    ),
    additionalProperties:
        OnboardingResult._extras(json, 'additionalProperties') == null
        ? const {}
        : OnboardingResult._readExtras(
            OnboardingResult._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OnboardingResultToJson(OnboardingResult instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'pet': instance.pet.toJson(),
      'room': instance.room.toJson(),
      'invite_code': instance.inviteCode.toJson(),
    };
