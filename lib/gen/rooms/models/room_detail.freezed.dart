// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoomDetail {


/// Create a copy of RoomDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomDetailCopyWith<RoomDetail> get copyWith => _$RoomDetailCopyWithImpl<RoomDetail>(this as RoomDetail, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RoomDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.isOwner, _this.isOwner) || other.isOwner == _this.isOwner)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount)&&(identical(other.capacity, _this.capacity) || other.capacity == _this.capacity)&&const DeepCollectionEquality().equals(other.members, _this.members)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as RoomDetail;
  return Object.hash(runtimeType,_this.id,_this.isOwner,_this.status,_this.memberCount,_this.capacity,const DeepCollectionEquality().hash(_this.members),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as RoomDetail;
  return 'RoomDetail(id: ${_this.id}, isOwner: ${_this.isOwner}, status: ${_this.status}, memberCount: ${_this.memberCount}, capacity: ${_this.capacity}, members: ${_this.members}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $RoomDetailCopyWith<$Res>  {
  factory $RoomDetailCopyWith(RoomDetail value, $Res Function(RoomDetail) _then) = _$RoomDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String id,@JsonKey(name: "is_owner", required: true, disallowNullValue: true) bool isOwner,@JsonKey(required: true, disallowNullValue: true, fromJson: RoomDetail._read_status, toJson: RoomDetail._write_status) RoomDetailStatus status,@JsonKey(name: "member_count", required: true, disallowNullValue: true, fromJson: RoomDetail._read_memberCount, toJson: RoomDetail._write_memberCount) int memberCount,@JsonKey(required: true, disallowNullValue: true, fromJson: RoomDetail._read_capacity, toJson: RoomDetail._write_capacity) int capacity,@JsonKey(required: true, disallowNullValue: true) List<MemberInfo> members,@JsonKey(readValue: RoomDetail._extras, fromJson: RoomDetail._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$RoomDetailCopyWithImpl<$Res>
    implements $RoomDetailCopyWith<$Res> {
  _$RoomDetailCopyWithImpl(this._self, this._then);

  final RoomDetail _self;
  final $Res Function(RoomDetail) _then;

/// Create a copy of RoomDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isOwner = null,Object? status = null,Object? memberCount = null,Object? capacity = null,Object? members = null,Object? additionalProperties = null,}) {
  return _then(RoomDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RoomDetailStatus,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<MemberInfo>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoomDetail].
extension RoomDetailPatterns on RoomDetail {
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
