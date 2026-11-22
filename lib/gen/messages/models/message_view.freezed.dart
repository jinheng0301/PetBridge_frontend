// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageView {


/// Create a copy of MessageView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageViewCopyWith<MessageView> get copyWith => _$MessageViewCopyWithImpl<MessageView>(this as MessageView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MessageView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageView&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.sender, _this.sender) || other.sender == _this.sender)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.toUserId, _this.toUserId) || other.toUserId == _this.toUserId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.phraseId, _this.phraseId) || other.phraseId == _this.phraseId)&&(identical(other.srcLang, _this.srcLang) || other.srcLang == _this.srcLang)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.clientMsgId, _this.clientMsgId) || other.clientMsgId == _this.clientMsgId)&&(identical(other.polishRequested, _this.polishRequested) || other.polishRequested == _this.polishRequested)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.delivery, _this.delivery) || other.delivery == _this.delivery)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as MessageView;
  return Object.hash(runtimeType,_this.id,_this.roomId,_this.sender,_this.scope,_this.toUserId,_this.kind,_this.phraseId,_this.srcLang,_this.text,_this.clientMsgId,_this.polishRequested,_this.createdAt,_this.delivery,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as MessageView;
  return 'MessageView(id: ${_this.id}, roomId: ${_this.roomId}, sender: ${_this.sender}, scope: ${_this.scope}, toUserId: ${_this.toUserId}, kind: ${_this.kind}, phraseId: ${_this.phraseId}, srcLang: ${_this.srcLang}, text: ${_this.text}, clientMsgId: ${_this.clientMsgId}, polishRequested: ${_this.polishRequested}, createdAt: ${_this.createdAt}, delivery: ${_this.delivery}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $MessageViewCopyWith<$Res>  {
  factory $MessageViewCopyWith(MessageView value, $Res Function(MessageView) _then) = _$MessageViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String id,@JsonKey(name: "room_id", required: true, disallowNullValue: true) String roomId,@JsonKey(required: true, disallowNullValue: true) SenderInfo sender,@JsonKey(required: true, disallowNullValue: true, fromJson: MessageView._read_scope, toJson: MessageView._write_scope) MessageViewScope scope,@JsonKey(name: "to_user_id", required: true) String? toUserId,@JsonKey(required: true, disallowNullValue: true, fromJson: MessageView._read_kind, toJson: MessageView._write_kind) MessageViewKind kind,@JsonKey(name: "phrase_id", required: true) String? phraseId,@JsonKey(name: "src_lang", required: true, disallowNullValue: true, fromJson: MessageView._read_srcLang, toJson: MessageView._write_srcLang) MessageViewSrcLang srcLang,@JsonKey(required: true, disallowNullValue: true) String text,@JsonKey(name: "client_msg_id", required: true) String? clientMsgId,@JsonKey(name: "polish_requested", required: true, disallowNullValue: true) bool polishRequested,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: MessageView._read_createdAt, toJson: MessageView._write_createdAt) DateTime createdAt,@JsonKey(required: true, disallowNullValue: true) DeliveryView delivery,@JsonKey(readValue: MessageView._extras, fromJson: MessageView._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$SenderInfoCopyWith<$Res> get sender;$DeliveryViewCopyWith<$Res> get delivery;

}
/// @nodoc
class _$MessageViewCopyWithImpl<$Res>
    implements $MessageViewCopyWith<$Res> {
  _$MessageViewCopyWithImpl(this._self, this._then);

  final MessageView _self;
  final $Res Function(MessageView) _then;

/// Create a copy of MessageView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomId = null,Object? sender = null,Object? scope = null,Object? toUserId = freezed,Object? kind = null,Object? phraseId = freezed,Object? srcLang = null,Object? text = null,Object? clientMsgId = freezed,Object? polishRequested = null,Object? createdAt = null,Object? delivery = null,Object? additionalProperties = null,}) {
  return _then(MessageView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SenderInfo,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as MessageViewScope,toUserId: freezed == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MessageViewKind,phraseId: freezed == phraseId ? _self.phraseId : phraseId // ignore: cast_nullable_to_non_nullable
as String?,srcLang: null == srcLang ? _self.srcLang : srcLang // ignore: cast_nullable_to_non_nullable
as MessageViewSrcLang,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,clientMsgId: freezed == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String?,polishRequested: null == polishRequested ? _self.polishRequested : polishRequested // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as DeliveryView,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of MessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SenderInfoCopyWith<$Res> get sender {
  
  return $SenderInfoCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of MessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryViewCopyWith<$Res> get delivery {
  
  return $DeliveryViewCopyWith<$Res>(_self.delivery, (value) {
    return _then(_self.copyWith(delivery: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageView].
extension MessageViewPatterns on MessageView {
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
