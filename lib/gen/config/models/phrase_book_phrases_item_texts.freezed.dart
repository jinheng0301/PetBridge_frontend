// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phrase_book_phrases_item_texts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhraseBookPhrasesItemTexts {


/// Create a copy of PhraseBookPhrasesItemTexts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhraseBookPhrasesItemTextsCopyWith<PhraseBookPhrasesItemTexts> get copyWith => _$PhraseBookPhrasesItemTextsCopyWithImpl<PhraseBookPhrasesItemTexts>(this as PhraseBookPhrasesItemTexts, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PhraseBookPhrasesItemTexts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhraseBookPhrasesItemTexts&&(identical(other.ja, _this.ja) || other.ja == _this.ja)&&(identical(other.ko, _this.ko) || other.ko == _this.ko)&&(identical(other.zhHant, _this.zhHant) || other.zhHant == _this.zhHant)&&(identical(other.zhHans, _this.zhHans) || other.zhHans == _this.zhHans)&&(identical(other.en, _this.en) || other.en == _this.en)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PhraseBookPhrasesItemTexts;
  return Object.hash(runtimeType,_this.ja,_this.ko,_this.zhHant,_this.zhHans,_this.en,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PhraseBookPhrasesItemTexts;
  return 'PhraseBookPhrasesItemTexts(ja: ${_this.ja}, ko: ${_this.ko}, zhHant: ${_this.zhHant}, zhHans: ${_this.zhHans}, en: ${_this.en}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PhraseBookPhrasesItemTextsCopyWith<$Res>  {
  factory $PhraseBookPhrasesItemTextsCopyWith(PhraseBookPhrasesItemTexts value, $Res Function(PhraseBookPhrasesItemTexts) _then) = _$PhraseBookPhrasesItemTextsCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String ja,@JsonKey(required: true, disallowNullValue: true) String ko,@JsonKey(name: "zh-Hant", required: true, disallowNullValue: true) String zhHant,@JsonKey(name: "zh-Hans", required: true, disallowNullValue: true) String zhHans,@JsonKey(required: true, disallowNullValue: true) String en,@JsonKey(readValue: PhraseBookPhrasesItemTexts._extras, fromJson: PhraseBookPhrasesItemTexts._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PhraseBookPhrasesItemTextsCopyWithImpl<$Res>
    implements $PhraseBookPhrasesItemTextsCopyWith<$Res> {
  _$PhraseBookPhrasesItemTextsCopyWithImpl(this._self, this._then);

  final PhraseBookPhrasesItemTexts _self;
  final $Res Function(PhraseBookPhrasesItemTexts) _then;

/// Create a copy of PhraseBookPhrasesItemTexts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ja = null,Object? ko = null,Object? zhHant = null,Object? zhHans = null,Object? en = null,Object? additionalProperties = null,}) {
  return _then(PhraseBookPhrasesItemTexts(
ja: null == ja ? _self.ja : ja // ignore: cast_nullable_to_non_nullable
as String,ko: null == ko ? _self.ko : ko // ignore: cast_nullable_to_non_nullable
as String,zhHant: null == zhHant ? _self.zhHant : zhHant // ignore: cast_nullable_to_non_nullable
as String,zhHans: null == zhHans ? _self.zhHans : zhHans // ignore: cast_nullable_to_non_nullable
as String,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PhraseBookPhrasesItemTexts].
extension PhraseBookPhrasesItemTextsPatterns on PhraseBookPhrasesItemTexts {
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
