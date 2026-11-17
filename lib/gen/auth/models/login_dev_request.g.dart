// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_dev_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDevRequest _$LoginDevRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['email'],
    disallowNullValues: const ['email'],
  );
  return LoginDevRequest(
    email: json['email'] as String,
    additionalProperties:
        LoginDevRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : LoginDevRequest._readExtras(
            LoginDevRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LoginDevRequestToJson(LoginDevRequest instance) =>
    <String, dynamic>{'email': instance.email};
