// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['client_msg_id', 'kind'],
    disallowNullValues: const [
      'client_msg_id',
      'kind',
      'text',
      'phrase_id',
      'scope',
      'to_user_id',
      'polish',
    ],
  );
  return SendMessageRequest(
    clientMsgId: json['client_msg_id'] as String,
    kind: SendMessageRequest._read_kind(json['kind']),
    text: json['text'] as String?,
    phraseId: json['phrase_id'] as String?,
    scope: SendMessageRequest._presentValue(json, 'scope') == null
        ? SendMessageRequestScope.room
        : SendMessageRequest._read_scope(
            SendMessageRequest._presentValue(json, 'scope') as Object,
          ),
    toUserId: json['to_user_id'] as String?,
    polish: SendMessageRequest._presentValue(json, 'polish') == null
        ? false
        : SendMessageRequest._read_polish(
            SendMessageRequest._presentValue(json, 'polish') as Object,
          ),
    additionalProperties:
        SendMessageRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : SendMessageRequest._readExtras(
            SendMessageRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) =>
    <String, dynamic>{
      'client_msg_id': instance.clientMsgId,
      'kind': ?SendMessageRequest._write_kind(instance.kind),
      'text': ?instance.text,
      'phrase_id': ?instance.phraseId,
      'scope': ?SendMessageRequest._write_scope(instance.scope),
      'to_user_id': ?instance.toUserId,
      'polish': ?SendMessageRequest._write_polish(instance.polish),
    };
