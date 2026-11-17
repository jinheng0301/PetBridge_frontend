// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'code_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodeListItem {


/// Create a copy of CodeListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeListItemCopyWith<CodeListItem> get copyWith => _$CodeListItemCopyWithImpl<CodeListItem>(this as CodeListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CodeListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeListItem&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.room, _this.room) || other.room == _this.room)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CodeListItem;
  return Object.hash(runtimeType,_this.code,_this.source,_this.status,_this.expiresAt,_this.room,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CodeListItem;
  return 'CodeListItem(code: ${_this.code}, source: ${_this.source}, status: ${_this.status}, expiresAt: ${_this.expiresAt}, room: ${_this.room}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CodeListItemCopyWith<$Res>  {
  factory $CodeListItemCopyWith(CodeListItem value, $Res Function(CodeListItem) _then) = _$CodeListItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String code,@JsonKey(required: true, disallowNullValue: true, fromJson: CodeListItem._read_source, toJson: CodeListItem._write_source) CodeListItemSource source,@JsonKey(required: true, disallowNullValue: true, fromJson: CodeListItem._read_status, toJson: CodeListItem._write_status) CodeListItemStatus status,@JsonKey(name: "expires_at", required: true, disallowNullValue: true, fromJson: CodeListItem._read_expiresAt, toJson: CodeListItem._write_expiresAt) DateTime expiresAt,@JsonKey(required: true, disallowNullValue: true) CodeListItemRoom room,@JsonKey(readValue: CodeListItem._extras, fromJson: CodeListItem._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$CodeListItemRoomCopyWith<$Res> get room;

}
/// @nodoc
class _$CodeListItemCopyWithImpl<$Res>
    implements $CodeListItemCopyWith<$Res> {
  _$CodeListItemCopyWithImpl(this._self, this._then);

  final CodeListItem _self;
  final $Res Function(CodeListItem) _then;

/// Create a copy of CodeListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? source = null,Object? status = null,Object? expiresAt = null,Object? room = null,Object? additionalProperties = null,}) {
  return _then(CodeListItem(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CodeListItemSource,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CodeListItemStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as CodeListItemRoom,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of CodeListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CodeListItemRoomCopyWith<$Res> get room {
  
  return $CodeListItemRoomCopyWith<$Res>(_self.room, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}


/// Adds pattern-matching-related methods to [CodeListItem].
extension CodeListItemPatterns on CodeListItem {
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
