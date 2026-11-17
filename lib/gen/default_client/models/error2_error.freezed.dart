// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error2_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Error2Error {


/// Create a copy of Error2Error
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Error2ErrorCopyWith<Error2Error> get copyWith => _$Error2ErrorCopyWithImpl<Error2Error>(this as Error2Error, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Error2Error;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Error2Error&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.details, _this.details) || other.details == _this.details)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as Error2Error;
  return Object.hash(runtimeType,_this.code,_this.message,_this.requestId,_this.details,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as Error2Error;
  return 'Error2Error(code: ${_this.code}, message: ${_this.message}, requestId: ${_this.requestId}, details: ${_this.details}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $Error2ErrorCopyWith<$Res>  {
  factory $Error2ErrorCopyWith(Error2Error value, $Res Function(Error2Error) _then) = _$Error2ErrorCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String code,@JsonKey(required: true, disallowNullValue: true) String message,@JsonKey(name: "request_id", required: true, disallowNullValue: true) String requestId,@JsonKey(disallowNullValue: true, includeIfNull: false) Error2ErrorDetails? details,@JsonKey(readValue: Error2Error._extras, fromJson: Error2Error._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$Error2ErrorDetailsCopyWith<$Res>? get details;

}
/// @nodoc
class _$Error2ErrorCopyWithImpl<$Res>
    implements $Error2ErrorCopyWith<$Res> {
  _$Error2ErrorCopyWithImpl(this._self, this._then);

  final Error2Error _self;
  final $Res Function(Error2Error) _then;

/// Create a copy of Error2Error
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? requestId = null,Object? details = freezed,Object? additionalProperties = null,}) {
  return _then(Error2Error(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Error2ErrorDetails?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of Error2Error
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Error2ErrorDetailsCopyWith<$Res>? get details {
    if (_self.details == null) {
    return null;
  }

  return $Error2ErrorDetailsCopyWith<$Res>(_self.details!, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}


/// Adds pattern-matching-related methods to [Error2Error].
extension Error2ErrorPatterns on Error2Error {
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
