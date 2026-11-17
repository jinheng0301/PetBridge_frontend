// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_result_invite_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingResultInviteCode _$OnboardingResultInviteCodeFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['code', 'expires_at'],
    disallowNullValues: const ['code', 'expires_at'],
  );
  return OnboardingResultInviteCode(
    code: json['code'] as String,
    expiresAt: OnboardingResultInviteCode._read_expiresAt(json['expires_at']),
    additionalProperties:
        OnboardingResultInviteCode._extras(json, 'additionalProperties') == null
        ? const {}
        : OnboardingResultInviteCode._readExtras(
            OnboardingResultInviteCode._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OnboardingResultInviteCodeToJson(
  OnboardingResultInviteCode instance,
) => <String, dynamic>{
  'code': instance.code,
  'expires_at': ?OnboardingResultInviteCode._write_expiresAt(
    instance.expiresAt,
  ),
};
