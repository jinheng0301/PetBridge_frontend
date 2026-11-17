// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingResult {


/// Create a copy of OnboardingResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingResultCopyWith<OnboardingResult> get copyWith => _$OnboardingResultCopyWithImpl<OnboardingResult>(this as OnboardingResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OnboardingResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingResult&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.pet, _this.pet) || other.pet == _this.pet)&&(identical(other.room, _this.room) || other.room == _this.room)&&(identical(other.inviteCode, _this.inviteCode) || other.inviteCode == _this.inviteCode)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OnboardingResult;
  return Object.hash(runtimeType,_this.user,_this.pet,_this.room,_this.inviteCode,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OnboardingResult;
  return 'OnboardingResult(user: ${_this.user}, pet: ${_this.pet}, room: ${_this.room}, inviteCode: ${_this.inviteCode}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OnboardingResultCopyWith<$Res>  {
  factory $OnboardingResultCopyWith(OnboardingResult value, $Res Function(OnboardingResult) _then) = _$OnboardingResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) Profile user,@JsonKey(required: true, disallowNullValue: true) OnboardingResultPet pet,@JsonKey(required: true, disallowNullValue: true) OnboardingResultRoom room,@JsonKey(name: "invite_code", required: true, disallowNullValue: true) OnboardingResultInviteCode inviteCode,@JsonKey(readValue: OnboardingResult._extras, fromJson: OnboardingResult._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$ProfileCopyWith<$Res> get user;$OnboardingResultPetCopyWith<$Res> get pet;$OnboardingResultRoomCopyWith<$Res> get room;$OnboardingResultInviteCodeCopyWith<$Res> get inviteCode;

}
/// @nodoc
class _$OnboardingResultCopyWithImpl<$Res>
    implements $OnboardingResultCopyWith<$Res> {
  _$OnboardingResultCopyWithImpl(this._self, this._then);

  final OnboardingResult _self;
  final $Res Function(OnboardingResult) _then;

/// Create a copy of OnboardingResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? pet = null,Object? room = null,Object? inviteCode = null,Object? additionalProperties = null,}) {
  return _then(OnboardingResult(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Profile,pet: null == pet ? _self.pet : pet // ignore: cast_nullable_to_non_nullable
as OnboardingResultPet,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as OnboardingResultRoom,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as OnboardingResultInviteCode,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of OnboardingResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get user {
  
  return $ProfileCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of OnboardingResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnboardingResultPetCopyWith<$Res> get pet {
  
  return $OnboardingResultPetCopyWith<$Res>(_self.pet, (value) {
    return _then(_self.copyWith(pet: value));
  });
}/// Create a copy of OnboardingResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnboardingResultRoomCopyWith<$Res> get room {
  
  return $OnboardingResultRoomCopyWith<$Res>(_self.room, (value) {
    return _then(_self.copyWith(room: value));
  });
}/// Create a copy of OnboardingResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnboardingResultInviteCodeCopyWith<$Res> get inviteCode {
  
  return $OnboardingResultInviteCodeCopyWith<$Res>(_self.inviteCode, (value) {
    return _then(_self.copyWith(inviteCode: value));
  });
}
}


/// Adds pattern-matching-related methods to [OnboardingResult].
extension OnboardingResultPatterns on OnboardingResult {
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
