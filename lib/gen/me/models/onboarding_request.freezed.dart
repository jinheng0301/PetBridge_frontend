// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingRequest {


/// Create a copy of OnboardingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingRequestCopyWith<OnboardingRequest> get copyWith => _$OnboardingRequestCopyWithImpl<OnboardingRequest>(this as OnboardingRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OnboardingRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingRequest&&(identical(other.nativeLang, _this.nativeLang) || other.nativeLang == _this.nativeLang)&&(identical(other.mbti, _this.mbti) || other.mbti == _this.mbti)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.ageBand, _this.ageBand) || other.ageBand == _this.ageBand)&&(identical(other.tz, _this.tz) || other.tz == _this.tz)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OnboardingRequest;
  return Object.hash(runtimeType,_this.nativeLang,_this.mbti,_this.nickname,_this.ageBand,_this.tz,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OnboardingRequest;
  return 'OnboardingRequest(nativeLang: ${_this.nativeLang}, mbti: ${_this.mbti}, nickname: ${_this.nickname}, ageBand: ${_this.ageBand}, tz: ${_this.tz}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OnboardingRequestCopyWith<$Res>  {
  factory $OnboardingRequestCopyWith(OnboardingRequest value, $Res Function(OnboardingRequest) _then) = _$OnboardingRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "native_lang", required: true, disallowNullValue: true, fromJson: OnboardingRequest._read_nativeLang, toJson: OnboardingRequest._write_nativeLang) OnboardingRequestNativeLang nativeLang,@JsonKey(required: true, disallowNullValue: true) String mbti,@JsonKey(required: true, disallowNullValue: true) String nickname,@JsonKey(name: "age_band", required: true, disallowNullValue: true, fromJson: OnboardingRequest._read_ageBand, toJson: OnboardingRequest._write_ageBand) OnboardingRequestAgeBand ageBand,@JsonKey(required: true, disallowNullValue: true) String tz,@JsonKey(readValue: OnboardingRequest._extras, fromJson: OnboardingRequest._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$OnboardingRequestCopyWithImpl<$Res>
    implements $OnboardingRequestCopyWith<$Res> {
  _$OnboardingRequestCopyWithImpl(this._self, this._then);

  final OnboardingRequest _self;
  final $Res Function(OnboardingRequest) _then;

/// Create a copy of OnboardingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nativeLang = null,Object? mbti = null,Object? nickname = null,Object? ageBand = null,Object? tz = null,Object? additionalProperties = null,}) {
  return _then(OnboardingRequest(
nativeLang: null == nativeLang ? _self.nativeLang : nativeLang // ignore: cast_nullable_to_non_nullable
as OnboardingRequestNativeLang,mbti: null == mbti ? _self.mbti : mbti // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,ageBand: null == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as OnboardingRequestAgeBand,tz: null == tz ? _self.tz : tz // ignore: cast_nullable_to_non_nullable
as String,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingRequest].
extension OnboardingRequestPatterns on OnboardingRequest {
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
