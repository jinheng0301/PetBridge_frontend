// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_my_rooms_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMyRoomsResponse200 _$ListMyRoomsResponse200FromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return ListMyRoomsResponse200(
    data: (json['data'] as List<dynamic>)
        .map((e) => RoomDetail.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        ListMyRoomsResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : ListMyRoomsResponse200._readExtras(
            ListMyRoomsResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ListMyRoomsResponse200ToJson(
  ListMyRoomsResponse200 instance,
) => <String, dynamic>{'data': instance.data.map((e) => e.toJson()).toList()};
