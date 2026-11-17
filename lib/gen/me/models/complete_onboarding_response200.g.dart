// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_onboarding_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteOnboardingResponse200 _$CompleteOnboardingResponse200FromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return CompleteOnboardingResponse200(
    data: OnboardingResult.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        CompleteOnboardingResponse200._extras(json, 'additionalProperties') ==
            null
        ? const {}
        : CompleteOnboardingResponse200._readExtras(
            CompleteOnboardingResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CompleteOnboardingResponse200ToJson(
  CompleteOnboardingResponse200 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
