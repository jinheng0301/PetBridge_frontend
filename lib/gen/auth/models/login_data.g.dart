// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginData _$LoginDataFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['access_token', 'refresh_token', 'expires_in', 'user'],
    disallowNullValues: const [
      'access_token',
      'refresh_token',
      'expires_in',
      'user',
    ],
  );
  return LoginData(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiresIn: LoginData._read_expiresIn(json['expires_in']),
    user: LoginDataUser.fromJson(json['user'] as Map<String, dynamic>),
    additionalProperties:
        LoginData._extras(json, 'additionalProperties') == null
        ? const {}
        : LoginData._readExtras(
            LoginData._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'expires_in': ?LoginData._write_expiresIn(instance.expiresIn),
  'user': instance.user.toJson(),
};
