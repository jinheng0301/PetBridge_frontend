// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_messages_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMessagesResponse200 _$ListMessagesResponse200FromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return ListMessagesResponse200(
    data: MessagePage.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        ListMessagesResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : ListMessagesResponse200._readExtras(
            ListMessagesResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ListMessagesResponse200ToJson(
  ListMessagesResponse200 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
