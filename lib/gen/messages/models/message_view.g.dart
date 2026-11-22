// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageView _$MessageViewFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'room_id',
      'sender',
      'scope',
      'to_user_id',
      'kind',
      'phrase_id',
      'src_lang',
      'text',
      'client_msg_id',
      'polish_requested',
      'created_at',
      'delivery',
    ],
    disallowNullValues: const [
      'id',
      'room_id',
      'sender',
      'scope',
      'kind',
      'src_lang',
      'text',
      'polish_requested',
      'created_at',
      'delivery',
    ],
  );
  return MessageView(
    id: json['id'] as String,
    roomId: json['room_id'] as String,
    sender: SenderInfo.fromJson(json['sender'] as Map<String, dynamic>),
    scope: MessageView._read_scope(json['scope']),
    toUserId: json['to_user_id'] as String?,
    kind: MessageView._read_kind(json['kind']),
    phraseId: json['phrase_id'] as String?,
    srcLang: MessageView._read_srcLang(json['src_lang']),
    text: json['text'] as String,
    clientMsgId: json['client_msg_id'] as String?,
    polishRequested: json['polish_requested'] as bool,
    createdAt: MessageView._read_createdAt(json['created_at']),
    delivery: DeliveryView.fromJson(json['delivery'] as Map<String, dynamic>),
    additionalProperties:
        MessageView._extras(json, 'additionalProperties') == null
        ? const {}
        : MessageView._readExtras(
            MessageView._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$MessageViewToJson(MessageView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'sender': instance.sender.toJson(),
      'scope': ?MessageView._write_scope(instance.scope),
      'to_user_id': instance.toUserId,
      'kind': ?MessageView._write_kind(instance.kind),
      'phrase_id': instance.phraseId,
      'src_lang': ?MessageView._write_srcLang(instance.srcLang),
      'text': instance.text,
      'client_msg_id': instance.clientMsgId,
      'polish_requested': instance.polishRequested,
      'created_at': ?MessageView._write_createdAt(instance.createdAt),
      'delivery': instance.delivery.toJson(),
    };
