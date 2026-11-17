// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'onboarded'],
    disallowNullValues: const ['id', 'native_lang', 'age_band', 'onboarded'],
  );
  return Profile(
    id: json['id'] as String,
    nickname: json['nickname'] as String?,
    nativeLang: Profile._read_nativeLang(json['native_lang']),
    mbti: json['mbti'] as String?,
    petType: json['pet_type'] as String?,
    ageBand: Profile._read_ageBand(json['age_band']),
    tz: json['tz'] as String?,
    onboarded: json['onboarded'] as bool,
    additionalProperties: Profile._extras(json, 'additionalProperties') == null
        ? const {}
        : Profile._readExtras(Profile._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'nickname': ?instance.nickname,
  'native_lang': ?Profile._write_nativeLang(instance.nativeLang),
  'mbti': ?instance.mbti,
  'pet_type': ?instance.petType,
  'age_band': ?Profile._write_ageBand(instance.ageBand),
  'tz': ?instance.tz,
  'onboarded': instance.onboarded,
};
