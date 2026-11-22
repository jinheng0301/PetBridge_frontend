// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_messages_response200.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListMessagesResponse200 {


/// Create a copy of ListMessagesResponse200
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListMessagesResponse200CopyWith<ListMessagesResponse200> get copyWith => _$ListMessagesResponse200CopyWithImpl<ListMessagesResponse200>(this as ListMessagesResponse200, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ListMessagesResponse200;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListMessagesResponse200&&(identical(other.data, _this.data) || other.data == _this.data)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ListMessagesResponse200;
  return Object.hash(runtimeType,_this.data,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ListMessagesResponse200;
  return 'ListMessagesResponse200(data: ${_this.data}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ListMessagesResponse200CopyWith<$Res>  {
  factory $ListMessagesResponse200CopyWith(ListMessagesResponse200 value, $Res Function(ListMessagesResponse200) _then) = _$ListMessagesResponse200CopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) MessagePage data,@JsonKey(readValue: ListMessagesResponse200._extras, fromJson: ListMessagesResponse200._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$MessagePageCopyWith<$Res> get data;

}
/// @nodoc
class _$ListMessagesResponse200CopyWithImpl<$Res>
    implements $ListMessagesResponse200CopyWith<$Res> {
  _$ListMessagesResponse200CopyWithImpl(this._self, this._then);

  final ListMessagesResponse200 _self;
  final $Res Function(ListMessagesResponse200) _then;

/// Create a copy of ListMessagesResponse200
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? additionalProperties = null,}) {
  return _then(ListMessagesResponse200(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as MessagePage,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of ListMessagesResponse200
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessagePageCopyWith<$Res> get data {
  
  return $MessagePageCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListMessagesResponse200].
extension ListMessagesResponse200Patterns on ListMessagesResponse200 {
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
