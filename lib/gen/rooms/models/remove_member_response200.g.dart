// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remove_member_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoveMemberResponse200 _$RemoveMemberResponse200FromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return RemoveMemberResponse200(
    data: RoomResult.fromJson(json['data'] as Map<String, dynamic>),
    additionalProperties:
        RemoveMemberResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : RemoveMemberResponse200._readExtras(
            RemoveMemberResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RemoveMemberResponse200ToJson(
  RemoveMemberResponse200 instance,
) => <String, dynamic>{'data': instance.data.toJson()};
