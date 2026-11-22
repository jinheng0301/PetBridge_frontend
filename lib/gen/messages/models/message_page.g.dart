// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagePage _$MessagePageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'has_more'],
    disallowNullValues: const ['items', 'has_more'],
  );
  return MessagePage(
    items: (json['items'] as List<dynamic>)
        .map((e) => MessageView.fromJson(e as Map<String, dynamic>))
        .toList(),
    hasMore: json['has_more'] as bool,
    additionalProperties:
        MessagePage._extras(json, 'additionalProperties') == null
        ? const {}
        : MessagePage._readExtras(
            MessagePage._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$MessagePageToJson(MessagePage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'has_more': instance.hasMore,
    };
