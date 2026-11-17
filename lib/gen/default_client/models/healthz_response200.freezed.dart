// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'healthz_response200.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthzResponse200 {


/// Create a copy of HealthzResponse200
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthzResponse200CopyWith<HealthzResponse200> get copyWith => _$HealthzResponse200CopyWithImpl<HealthzResponse200>(this as HealthzResponse200, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthzResponse200;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthzResponse200&&(identical(other.data, _this.data) || other.data == _this.data)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as HealthzResponse200;
  return Object.hash(runtimeType,_this.data,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as HealthzResponse200;
  return 'HealthzResponse200(data: ${_this.data}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $HealthzResponse200CopyWith<$Res>  {
  factory $HealthzResponse200CopyWith(HealthzResponse200 value, $Res Function(HealthzResponse200) _then) = _$HealthzResponse200CopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) HealthzResponse200Data data,@JsonKey(readValue: HealthzResponse200._extras, fromJson: HealthzResponse200._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$HealthzResponse200DataCopyWith<$Res> get data;

}
/// @nodoc
class _$HealthzResponse200CopyWithImpl<$Res>
    implements $HealthzResponse200CopyWith<$Res> {
  _$HealthzResponse200CopyWithImpl(this._self, this._then);

  final HealthzResponse200 _self;
  final $Res Function(HealthzResponse200) _then;

/// Create a copy of HealthzResponse200
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? additionalProperties = null,}) {
  return _then(HealthzResponse200(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as HealthzResponse200Data,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of HealthzResponse200
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthzResponse200DataCopyWith<$Res> get data {
  
  return $HealthzResponse200DataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [HealthzResponse200].
extension HealthzResponse200Patterns on HealthzResponse200 {
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
