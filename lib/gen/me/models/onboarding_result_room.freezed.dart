// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_result_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingResultRoom {


/// Create a copy of OnboardingResultRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingResultRoomCopyWith<OnboardingResultRoom> get copyWith => _$OnboardingResultRoomCopyWithImpl<OnboardingResultRoom>(this as OnboardingResultRoom, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OnboardingResultRoom;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingResultRoom&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount)&&(identical(other.capacity, _this.capacity) || other.capacity == _this.capacity)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OnboardingResultRoom;
  return Object.hash(runtimeType,_this.id,_this.memberCount,_this.capacity,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OnboardingResultRoom;
  return 'OnboardingResultRoom(id: ${_this.id}, memberCount: ${_this.memberCount}, capacity: ${_this.capacity}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OnboardingResultRoomCopyWith<$Res>  {
  factory $OnboardingResultRoomCopyWith(OnboardingResultRoom value, $Res Function(OnboardingResultRoom) _then) = _$OnboardingResultRoomCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String id,@JsonKey(name: "member_count", required: true, disallowNullValue: true, fromJson: OnboardingResultRoom._read_memberCount, toJson: OnboardingResultRoom._write_memberCount) int memberCount,@JsonKey(required: true, disallowNullValue: true, fromJson: OnboardingResultRoom._read_capacity, toJson: OnboardingResultRoom._write_capacity) int capacity,@JsonKey(readValue: OnboardingResultRoom._extras, fromJson: OnboardingResultRoom._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$OnboardingResultRoomCopyWithImpl<$Res>
    implements $OnboardingResultRoomCopyWith<$Res> {
  _$OnboardingResultRoomCopyWithImpl(this._self, this._then);

  final OnboardingResultRoom _self;
  final $Res Function(OnboardingResultRoom) _then;

/// Create a copy of OnboardingResultRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberCount = null,Object? capacity = null,Object? additionalProperties = null,}) {
  return _then(OnboardingResultRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingResultRoom].
extension OnboardingResultRoomPatterns on OnboardingResultRoom {
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
