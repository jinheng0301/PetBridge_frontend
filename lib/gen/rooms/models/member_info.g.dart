// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberInfo _$MemberInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['user_id', 'nickname', 'pet_type', 'seat_no', 'role'],
    disallowNullValues: const ['user_id', 'seat_no', 'role'],
  );
  return MemberInfo(
    userId: json['user_id'] as String,
    nickname: json['nickname'] as String?,
    petType: json['pet_type'] as String?,
    seatNo: MemberInfo._read_seatNo(json['seat_no']),
    role: MemberInfo._read_role(json['role']),
    additionalProperties:
        MemberInfo._extras(json, 'additionalProperties') == null
        ? const {}
        : MemberInfo._readExtras(
            MemberInfo._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$MemberInfoToJson(MemberInfo instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'pet_type': instance.petType,
      'seat_no': ?MemberInfo._write_seatNo(instance.seatNo),
      'role': ?MemberInfo._write_role(instance.role),
    };
