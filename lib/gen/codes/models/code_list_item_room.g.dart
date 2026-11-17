// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_list_item_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeListItemRoom _$CodeListItemRoomFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'member_count', 'capacity'],
    disallowNullValues: const ['id', 'member_count', 'capacity'],
  );
  return CodeListItemRoom(
    id: json['id'] as String,
    memberCount: CodeListItemRoom._read_memberCount(json['member_count']),
    capacity: CodeListItemRoom._read_capacity(json['capacity']),
    additionalProperties:
        CodeListItemRoom._extras(json, 'additionalProperties') == null
        ? const {}
        : CodeListItemRoom._readExtras(
            CodeListItemRoom._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CodeListItemRoomToJson(
  CodeListItemRoom instance,
) => <String, dynamic>{
  'id': instance.id,
  'member_count': ?CodeListItemRoom._write_memberCount(instance.memberCount),
  'capacity': ?CodeListItemRoom._write_capacity(instance.capacity),
};
