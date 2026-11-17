// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JoinResult {


/// Create a copy of JoinResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinResultCopyWith<JoinResult> get copyWith => _$JoinResultCopyWithImpl<JoinResult>(this as JoinResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JoinResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinResult&&(identical(other.room, _this.room) || other.room == _this.room)&&(identical(other.seatNo, _this.seatNo) || other.seatNo == _this.seatNo)&&const DeepCollectionEquality().equals(other.members, _this.members)&&const DeepCollectionEquality().equals(other.rewards, _this.rewards)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as JoinResult;
  return Object.hash(runtimeType,_this.room,_this.seatNo,const DeepCollectionEquality().hash(_this.members),const DeepCollectionEquality().hash(_this.rewards),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as JoinResult;
  return 'JoinResult(room: ${_this.room}, seatNo: ${_this.seatNo}, members: ${_this.members}, rewards: ${_this.rewards}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $JoinResultCopyWith<$Res>  {
  factory $JoinResultCopyWith(JoinResult value, $Res Function(JoinResult) _then) = _$JoinResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) RoomSummary room,@JsonKey(name: "seat_no", required: true, disallowNullValue: true, fromJson: JoinResult._read_seatNo, toJson: JoinResult._write_seatNo) int seatNo,@JsonKey(required: true, disallowNullValue: true) List<MemberInfo> members,@JsonKey(required: true, disallowNullValue: true) List<CodeInfo> rewards,@JsonKey(readValue: JoinResult._extras, fromJson: JoinResult._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$RoomSummaryCopyWith<$Res> get room;

}
/// @nodoc
class _$JoinResultCopyWithImpl<$Res>
    implements $JoinResultCopyWith<$Res> {
  _$JoinResultCopyWithImpl(this._self, this._then);

  final JoinResult _self;
  final $Res Function(JoinResult) _then;

/// Create a copy of JoinResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? room = null,Object? seatNo = null,Object? members = null,Object? rewards = null,Object? additionalProperties = null,}) {
  return _then(JoinResult(
room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as RoomSummary,seatNo: null == seatNo ? _self.seatNo : seatNo // ignore: cast_nullable_to_non_nullable
as int,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<MemberInfo>,rewards: null == rewards ? _self.rewards : rewards // ignore: cast_nullable_to_non_nullable
as List<CodeInfo>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of JoinResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoomSummaryCopyWith<$Res> get room {
  
  return $RoomSummaryCopyWith<$Res>(_self.room, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinResult].
extension JoinResultPatterns on JoinResult {
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
