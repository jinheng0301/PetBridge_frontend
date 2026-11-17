// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeListItem _$CodeListItemFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['code', 'source', 'status', 'expires_at', 'room'],
    disallowNullValues: const [
      'code',
      'source',
      'status',
      'expires_at',
      'room',
    ],
  );
  return CodeListItem(
    code: json['code'] as String,
    source: CodeListItem._read_source(json['source']),
    status: CodeListItem._read_status(json['status']),
    expiresAt: CodeListItem._read_expiresAt(json['expires_at']),
    room: CodeListItemRoom.fromJson(json['room'] as Map<String, dynamic>),
    additionalProperties:
        CodeListItem._extras(json, 'additionalProperties') == null
        ? const {}
        : CodeListItem._readExtras(
            CodeListItem._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CodeListItemToJson(CodeListItem instance) =>
    <String, dynamic>{
      'code': instance.code,
      'source': ?CodeListItem._write_source(instance.source),
      'status': ?CodeListItem._write_status(instance.status),
      'expires_at': ?CodeListItem._write_expiresAt(instance.expiresAt),
      'room': instance.room.toJson(),
    };
