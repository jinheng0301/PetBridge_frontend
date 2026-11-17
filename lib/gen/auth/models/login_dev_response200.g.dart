// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_dev_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDevResponse200 _$LoginDevResponse200FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return LoginDevResponse200(
    data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        LoginDevResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : LoginDevResponse200._readExtras(
            LoginDevResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LoginDevResponse200ToJson(
  LoginDevResponse200 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
