// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'readyz_response200_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReadyzResponse200Data {


/// Create a copy of ReadyzResponse200Data
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadyzResponse200DataCopyWith<ReadyzResponse200Data> get copyWith => _$ReadyzResponse200DataCopyWithImpl<ReadyzResponse200Data>(this as ReadyzResponse200Data, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReadyzResponse200Data;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadyzResponse200Data&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.redis, _this.redis) || other.redis == _this.redis)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ReadyzResponse200Data;
  return Object.hash(runtimeType,_this.status,_this.redis,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ReadyzResponse200Data;
  return 'ReadyzResponse200Data(status: ${_this.status}, redis: ${_this.redis}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ReadyzResponse200DataCopyWith<$Res>  {
  factory $ReadyzResponse200DataCopyWith(ReadyzResponse200Data value, $Res Function(ReadyzResponse200Data) _then) = _$ReadyzResponse200DataCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, includeIfNull: false, fromJson: ReadyzResponse200Data._read_status, toJson: ReadyzResponse200Data._write_status) ReadyzResponse200DataStatus? status,@JsonKey(disallowNullValue: true, includeIfNull: false, fromJson: ReadyzResponse200Data._read_redis, toJson: ReadyzResponse200Data._write_redis) ReadyzResponse200DataRedis? redis,@JsonKey(readValue: ReadyzResponse200Data._extras, fromJson: ReadyzResponse200Data._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ReadyzResponse200DataCopyWithImpl<$Res>
    implements $ReadyzResponse200DataCopyWith<$Res> {
  _$ReadyzResponse200DataCopyWithImpl(this._self, this._then);

  final ReadyzResponse200Data _self;
  final $Res Function(ReadyzResponse200Data) _then;

/// Create a copy of ReadyzResponse200Data
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? redis = freezed,Object? additionalProperties = null,}) {
  return _then(ReadyzResponse200Data(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReadyzResponse200DataStatus?,redis: freezed == redis ? _self.redis : redis // ignore: cast_nullable_to_non_nullable
as ReadyzResponse200DataRedis?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadyzResponse200Data].
extension ReadyzResponse200DataPatterns on ReadyzResponse200Data {
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
