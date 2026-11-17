// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_data_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDataUser _$LoginDataUserFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'onboarded'],
    disallowNullValues: const ['id', 'onboarded'],
  );
  return LoginDataUser(
    id: json['id'] as String,
    onboarded: json['onboarded'] as bool,
    additionalProperties:
        LoginDataUser._extras(json, 'additionalProperties') == null
        ? const {}
        : LoginDataUser._readExtras(
            LoginDataUser._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LoginDataUserToJson(LoginDataUser instance) =>
    <String, dynamic>{'id': instance.id, 'onboarded': instance.onboarded};
