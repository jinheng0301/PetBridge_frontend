// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryView _$DeliveryViewFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'target_lang',
      'base_text',
      'translation_status',
      'polished_text',
      'polish_status',
    ],
    disallowNullValues: const [
      'id',
      'target_lang',
      'translation_status',
      'polish_status',
    ],
  );
  return DeliveryView(
    id: json['id'] as String,
    targetLang: DeliveryView._read_targetLang(json['target_lang']),
    baseText: json['base_text'] as String?,
    translationStatus: DeliveryView._read_translationStatus(
      json['translation_status'],
    ),
    polishedText: json['polished_text'] as String?,
    polishStatus: DeliveryView._read_polishStatus(json['polish_status']),
    additionalProperties:
        DeliveryView._extras(json, 'additionalProperties') == null
        ? const {}
        : DeliveryView._readExtras(
            DeliveryView._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$DeliveryViewToJson(DeliveryView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'target_lang': ?DeliveryView._write_targetLang(instance.targetLang),
      'base_text': instance.baseText,
      'translation_status': ?DeliveryView._write_translationStatus(
        instance.translationStatus,
      ),
      'polished_text': instance.polishedText,
      'polish_status': ?DeliveryView._write_polishStatus(instance.polishStatus),
    };
