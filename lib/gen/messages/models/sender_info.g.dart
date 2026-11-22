// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SenderInfo _$SenderInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['user_id', 'nickname', 'pet_type'],
    disallowNullValues: const ['user_id'],
  );
  return SenderInfo(
    userId: json['user_id'] as String,
    nickname: json['nickname'] as String?,
    petType: json['pet_type'] as String?,
    additionalProperties:
        SenderInfo._extras(json, 'additionalProperties') == null
        ? const {}
        : SenderInfo._readExtras(
            SenderInfo._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SenderInfoToJson(SenderInfo instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'pet_type': instance.petType,
    };
