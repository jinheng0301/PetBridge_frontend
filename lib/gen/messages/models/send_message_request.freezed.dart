// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_message_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SendMessageRequest {


/// Create a copy of SendMessageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendMessageRequestCopyWith<SendMessageRequest> get copyWith => _$SendMessageRequestCopyWithImpl<SendMessageRequest>(this as SendMessageRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SendMessageRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendMessageRequest&&(identical(other.clientMsgId, _this.clientMsgId) || other.clientMsgId == _this.clientMsgId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.phraseId, _this.phraseId) || other.phraseId == _this.phraseId)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.toUserId, _this.toUserId) || other.toUserId == _this.toUserId)&&(identical(other.polish, _this.polish) || other.polish == _this.polish)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as SendMessageRequest;
  return Object.hash(runtimeType,_this.clientMsgId,_this.kind,_this.text,_this.phraseId,_this.scope,_this.toUserId,_this.polish,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as SendMessageRequest;
  return 'SendMessageRequest(clientMsgId: ${_this.clientMsgId}, kind: ${_this.kind}, text: ${_this.text}, phraseId: ${_this.phraseId}, scope: ${_this.scope}, toUserId: ${_this.toUserId}, polish: ${_this.polish}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $SendMessageRequestCopyWith<$Res>  {
  factory $SendMessageRequestCopyWith(SendMessageRequest value, $Res Function(SendMessageRequest) _then) = _$SendMessageRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "client_msg_id", required: true, disallowNullValue: true) String clientMsgId,@JsonKey(required: true, disallowNullValue: true, fromJson: SendMessageRequest._read_kind, toJson: SendMessageRequest._write_kind) SendMessageRequestKind kind,@JsonKey(disallowNullValue: true, includeIfNull: false) String? text,@JsonKey(name: "phrase_id", disallowNullValue: true, includeIfNull: false) String? phraseId,@JsonKey(disallowNullValue: true, readValue: SendMessageRequest._presentValue, fromJson: SendMessageRequest._read_scope, toJson: SendMessageRequest._write_scope) SendMessageRequestScope scope,@JsonKey(name: "to_user_id", disallowNullValue: true, includeIfNull: false) String? toUserId,@JsonKey(disallowNullValue: true, readValue: SendMessageRequest._presentValue, fromJson: SendMessageRequest._read_polish, toJson: SendMessageRequest._write_polish) bool polish,@JsonKey(readValue: SendMessageRequest._extras, fromJson: SendMessageRequest._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$SendMessageRequestCopyWithImpl<$Res>
    implements $SendMessageRequestCopyWith<$Res> {
  _$SendMessageRequestCopyWithImpl(this._self, this._then);

  final SendMessageRequest _self;
  final $Res Function(SendMessageRequest) _then;

/// Create a copy of SendMessageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientMsgId = null,Object? kind = null,Object? text = freezed,Object? phraseId = freezed,Object? scope = null,Object? toUserId = freezed,Object? polish = null,Object? additionalProperties = null,}) {
  return _then(SendMessageRequest(
clientMsgId: null == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SendMessageRequestKind,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,phraseId: freezed == phraseId ? _self.phraseId : phraseId // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as SendMessageRequestScope,toUserId: freezed == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String?,polish: null == polish ? _self.polish : polish // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SendMessageRequest].
extension SendMessageRequestPatterns on SendMessageRequest {
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
