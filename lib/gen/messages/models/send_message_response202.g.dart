// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_response202.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageResponse202 _$SendMessageResponse202FromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return SendMessageResponse202(
    data: MessageView.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        SendMessageResponse202._extras(json, 'additionalProperties') == null
        ? const {}
        : SendMessageResponse202._readExtras(
            SendMessageResponse202._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SendMessageResponse202ToJson(
  SendMessageResponse202 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
