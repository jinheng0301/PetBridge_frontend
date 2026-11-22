// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phrase_book_phrases_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhraseBookPhrasesItem {


/// Create a copy of PhraseBookPhrasesItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhraseBookPhrasesItemCopyWith<PhraseBookPhrasesItem> get copyWith => _$PhraseBookPhrasesItemCopyWithImpl<PhraseBookPhrasesItem>(this as PhraseBookPhrasesItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PhraseBookPhrasesItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhraseBookPhrasesItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.texts, _this.texts) || other.texts == _this.texts)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PhraseBookPhrasesItem;
  return Object.hash(runtimeType,_this.id,_this.texts,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PhraseBookPhrasesItem;
  return 'PhraseBookPhrasesItem(id: ${_this.id}, texts: ${_this.texts}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PhraseBookPhrasesItemCopyWith<$Res>  {
  factory $PhraseBookPhrasesItemCopyWith(PhraseBookPhrasesItem value, $Res Function(PhraseBookPhrasesItem) _then) = _$PhraseBookPhrasesItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String id,@JsonKey(required: true, disallowNullValue: true) PhraseBookPhrasesItemTexts texts,@JsonKey(readValue: PhraseBookPhrasesItem._extras, fromJson: PhraseBookPhrasesItem._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$PhraseBookPhrasesItemTextsCopyWith<$Res> get texts;

}
/// @nodoc
class _$PhraseBookPhrasesItemCopyWithImpl<$Res>
    implements $PhraseBookPhrasesItemCopyWith<$Res> {
  _$PhraseBookPhrasesItemCopyWithImpl(this._self, this._then);

  final PhraseBookPhrasesItem _self;
  final $Res Function(PhraseBookPhrasesItem) _then;

/// Create a copy of PhraseBookPhrasesItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? texts = null,Object? additionalProperties = null,}) {
  return _then(PhraseBookPhrasesItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,texts: null == texts ? _self.texts : texts // ignore: cast_nullable_to_non_nullable
as PhraseBookPhrasesItemTexts,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of PhraseBookPhrasesItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhraseBookPhrasesItemTextsCopyWith<$Res> get texts {
  
  return $PhraseBookPhrasesItemTextsCopyWith<$Res>(_self.texts, (value) {
    return _then(_self.copyWith(texts: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhraseBookPhrasesItem].
extension PhraseBookPhrasesItemPatterns on PhraseBookPhrasesItem {
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
