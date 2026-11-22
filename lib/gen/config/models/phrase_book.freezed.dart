// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phrase_book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhraseBook {


/// Create a copy of PhraseBook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhraseBookCopyWith<PhraseBook> get copyWith => _$PhraseBookCopyWithImpl<PhraseBook>(this as PhraseBook, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PhraseBook;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhraseBook&&(identical(other.version, _this.version) || other.version == _this.version)&&const DeepCollectionEquality().equals(other.phrases, _this.phrases)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PhraseBook;
  return Object.hash(runtimeType,_this.version,const DeepCollectionEquality().hash(_this.phrases),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PhraseBook;
  return 'PhraseBook(version: ${_this.version}, phrases: ${_this.phrases}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PhraseBookCopyWith<$Res>  {
  factory $PhraseBookCopyWith(PhraseBook value, $Res Function(PhraseBook) _then) = _$PhraseBookCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String version,@JsonKey(required: true, disallowNullValue: true) List<PhraseBookPhrasesItem> phrases,@JsonKey(readValue: PhraseBook._extras, fromJson: PhraseBook._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PhraseBookCopyWithImpl<$Res>
    implements $PhraseBookCopyWith<$Res> {
  _$PhraseBookCopyWithImpl(this._self, this._then);

  final PhraseBook _self;
  final $Res Function(PhraseBook) _then;

/// Create a copy of PhraseBook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? phrases = null,Object? additionalProperties = null,}) {
  return _then(PhraseBook(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,phrases: null == phrases ? _self.phrases : phrases // ignore: cast_nullable_to_non_nullable
as List<PhraseBookPhrasesItem>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PhraseBook].
extension PhraseBookPatterns on PhraseBook {
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
