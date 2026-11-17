// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_codes_response200.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListCodesResponse200 _$ListCodesResponse200FromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['data'],
    disallowNullValues: const ['data'],
  );
  return ListCodesResponse200(
    data: (json['data'] as List<dynamic>)
        .map((e) => CodeListItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        ListCodesResponse200._extras(json, 'additionalProperties') == null
        ? const {}
        : ListCodesResponse200._readExtras(
            ListCodesResponse200._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ListCodesResponse200ToJson(
  ListCodesResponse200 instance,
) => <String, dynamic>{'data': instance.data.map((e) => e.toJson()).toList()};
