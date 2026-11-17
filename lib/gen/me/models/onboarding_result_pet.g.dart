// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_result_pet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingResultPet _$OnboardingResultPetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['type', 'mbti'],
    disallowNullValues: const ['type', 'mbti'],
  );
  return OnboardingResultPet(
    type: OnboardingResultPet._read_type(json['type']),
    mbti: json['mbti'] as String,
    additionalProperties:
        OnboardingResultPet._extras(json, 'additionalProperties') == null
        ? const {}
        : OnboardingResultPet._readExtras(
            OnboardingResultPet._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OnboardingResultPetToJson(
  OnboardingResultPet instance,
) => <String, dynamic>{
  'type': ?OnboardingResultPet._write_type(instance.type),
  'mbti': instance.mbti,
};
