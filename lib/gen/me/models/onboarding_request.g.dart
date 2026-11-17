// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingRequest _$OnboardingRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['native_lang', 'mbti', 'nickname', 'age_band', 'tz'],
    disallowNullValues: const [
      'native_lang',
      'mbti',
      'nickname',
      'age_band',
      'tz',
    ],
  );
  return OnboardingRequest(
    nativeLang: OnboardingRequest._read_nativeLang(json['native_lang']),
    mbti: json['mbti'] as String,
    nickname: json['nickname'] as String,
    ageBand: OnboardingRequest._read_ageBand(json['age_band']),
    tz: json['tz'] as String,
    additionalProperties:
        OnboardingRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : OnboardingRequest._readExtras(
            OnboardingRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OnboardingRequestToJson(OnboardingRequest instance) =>
    <String, dynamic>{
      'native_lang': ?OnboardingRequest._write_nativeLang(instance.nativeLang),
      'mbti': instance.mbti,
      'nickname': instance.nickname,
      'age_band': ?OnboardingRequest._write_ageBand(instance.ageBand),
      'tz': instance.tz,
    };
