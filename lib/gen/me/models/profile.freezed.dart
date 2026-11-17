// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Profile {


/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.nativeLang, _this.nativeLang) || other.nativeLang == _this.nativeLang)&&(identical(other.mbti, _this.mbti) || other.mbti == _this.mbti)&&(identical(other.petType, _this.petType) || other.petType == _this.petType)&&(identical(other.ageBand, _this.ageBand) || other.ageBand == _this.ageBand)&&(identical(other.tz, _this.tz) || other.tz == _this.tz)&&(identical(other.onboarded, _this.onboarded) || other.onboarded == _this.onboarded)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.nickname,_this.nativeLang,_this.mbti,_this.petType,_this.ageBand,_this.tz,_this.onboarded,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, nickname: ${_this.nickname}, nativeLang: ${_this.nativeLang}, mbti: ${_this.mbti}, petType: ${_this.petType}, ageBand: ${_this.ageBand}, tz: ${_this.tz}, onboarded: ${_this.onboarded}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String id,@JsonKey(includeIfNull: false) String? nickname,@JsonKey(name: "native_lang", includeIfNull: false, fromJson: Profile._read_nativeLang, toJson: Profile._write_nativeLang) ProfileNativeLang? nativeLang,@JsonKey(includeIfNull: false) String? mbti,@JsonKey(name: "pet_type", includeIfNull: false) String? petType,@JsonKey(name: "age_band", includeIfNull: false, fromJson: Profile._read_ageBand, toJson: Profile._write_ageBand) ProfileAgeBand? ageBand,@JsonKey(includeIfNull: false) String? tz,@JsonKey(required: true, disallowNullValue: true) bool onboarded,@JsonKey(readValue: Profile._extras, fromJson: Profile._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nickname = freezed,Object? nativeLang = freezed,Object? mbti = freezed,Object? petType = freezed,Object? ageBand = freezed,Object? tz = freezed,Object? onboarded = null,Object? additionalProperties = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,nativeLang: freezed == nativeLang ? _self.nativeLang : nativeLang // ignore: cast_nullable_to_non_nullable
as ProfileNativeLang?,mbti: freezed == mbti ? _self.mbti : mbti // ignore: cast_nullable_to_non_nullable
as String?,petType: freezed == petType ? _self.petType : petType // ignore: cast_nullable_to_non_nullable
as String?,ageBand: freezed == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as ProfileAgeBand?,tz: freezed == tz ? _self.tz : tz // ignore: cast_nullable_to_non_nullable
as String?,onboarded: null == onboarded ? _self.onboarded : onboarded // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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
