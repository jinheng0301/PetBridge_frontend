// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryView {


/// Create a copy of DeliveryView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryViewCopyWith<DeliveryView> get copyWith => _$DeliveryViewCopyWithImpl<DeliveryView>(this as DeliveryView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryView&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.targetLang, _this.targetLang) || other.targetLang == _this.targetLang)&&(identical(other.baseText, _this.baseText) || other.baseText == _this.baseText)&&(identical(other.translationStatus, _this.translationStatus) || other.translationStatus == _this.translationStatus)&&(identical(other.polishedText, _this.polishedText) || other.polishedText == _this.polishedText)&&(identical(other.polishStatus, _this.polishStatus) || other.polishStatus == _this.polishStatus)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as DeliveryView;
  return Object.hash(runtimeType,_this.id,_this.targetLang,_this.baseText,_this.translationStatus,_this.polishedText,_this.polishStatus,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as DeliveryView;
  return 'DeliveryView(id: ${_this.id}, targetLang: ${_this.targetLang}, baseText: ${_this.baseText}, translationStatus: ${_this.translationStatus}, polishedText: ${_this.polishedText}, polishStatus: ${_this.polishStatus}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $DeliveryViewCopyWith<$Res>  {
  factory $DeliveryViewCopyWith(DeliveryView value, $Res Function(DeliveryView) _then) = _$DeliveryViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String id,@JsonKey(name: "target_lang", required: true, disallowNullValue: true, fromJson: DeliveryView._read_targetLang, toJson: DeliveryView._write_targetLang) DeliveryViewTargetLang targetLang,@JsonKey(name: "base_text", required: true) String? baseText,@JsonKey(name: "translation_status", required: true, disallowNullValue: true, fromJson: DeliveryView._read_translationStatus, toJson: DeliveryView._write_translationStatus) DeliveryViewTranslationStatus translationStatus,@JsonKey(name: "polished_text", required: true) String? polishedText,@JsonKey(name: "polish_status", required: true, disallowNullValue: true, fromJson: DeliveryView._read_polishStatus, toJson: DeliveryView._write_polishStatus) DeliveryViewPolishStatus polishStatus,@JsonKey(readValue: DeliveryView._extras, fromJson: DeliveryView._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$DeliveryViewCopyWithImpl<$Res>
    implements $DeliveryViewCopyWith<$Res> {
  _$DeliveryViewCopyWithImpl(this._self, this._then);

  final DeliveryView _self;
  final $Res Function(DeliveryView) _then;

/// Create a copy of DeliveryView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetLang = null,Object? baseText = freezed,Object? translationStatus = null,Object? polishedText = freezed,Object? polishStatus = null,Object? additionalProperties = null,}) {
  return _then(DeliveryView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetLang: null == targetLang ? _self.targetLang : targetLang // ignore: cast_nullable_to_non_nullable
as DeliveryViewTargetLang,baseText: freezed == baseText ? _self.baseText : baseText // ignore: cast_nullable_to_non_nullable
as String?,translationStatus: null == translationStatus ? _self.translationStatus : translationStatus // ignore: cast_nullable_to_non_nullable
as DeliveryViewTranslationStatus,polishedText: freezed == polishedText ? _self.polishedText : polishedText // ignore: cast_nullable_to_non_nullable
as String?,polishStatus: null == polishStatus ? _self.polishStatus : polishStatus // ignore: cast_nullable_to_non_nullable
as DeliveryViewPolishStatus,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryView].
extension DeliveryViewPatterns on DeliveryView {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
