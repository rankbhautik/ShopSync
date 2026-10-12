// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_transfer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StockTransfer {

 String get id; String get productId; String get sourceShopId; String get destinationShopId; double get quantity; String? get notes; DateTime get createdAt;
/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockTransferCopyWith<StockTransfer> get copyWith => _$StockTransferCopyWithImpl<StockTransfer>(this as StockTransfer, _$identity);

  /// Serializes this StockTransfer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockTransfer&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.sourceShopId, sourceShopId) || other.sourceShopId == sourceShopId)&&(identical(other.destinationShopId, destinationShopId) || other.destinationShopId == destinationShopId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,sourceShopId,destinationShopId,quantity,notes,createdAt);

@override
String toString() {
  return 'StockTransfer(id: $id, productId: $productId, sourceShopId: $sourceShopId, destinationShopId: $destinationShopId, quantity: $quantity, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StockTransferCopyWith<$Res>  {
  factory $StockTransferCopyWith(StockTransfer value, $Res Function(StockTransfer) _then) = _$StockTransferCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String sourceShopId, String destinationShopId, double quantity, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$StockTransferCopyWithImpl<$Res>
    implements $StockTransferCopyWith<$Res> {
  _$StockTransferCopyWithImpl(this._self, this._then);

  final StockTransfer _self;
  final $Res Function(StockTransfer) _then;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? sourceShopId = null,Object? destinationShopId = null,Object? quantity = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(StockTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,sourceShopId: null == sourceShopId ? _self.sourceShopId : sourceShopId // ignore: cast_nullable_to_non_nullable
as String,destinationShopId: null == destinationShopId ? _self.destinationShopId : destinationShopId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StockTransfer].
extension StockTransferPatterns on StockTransfer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockTransfer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockTransfer value)  $default,){
final _that = this;
switch (_that) {
case _StockTransfer():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockTransfer value)?  $default,){
final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String sourceShopId,  String destinationShopId,  double quantity,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that.id,_that.productId,_that.sourceShopId,_that.destinationShopId,_that.quantity,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String sourceShopId,  String destinationShopId,  double quantity,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _StockTransfer():
return $default(_that.id,_that.productId,_that.sourceShopId,_that.destinationShopId,_that.quantity,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String sourceShopId,  String destinationShopId,  double quantity,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that.id,_that.productId,_that.sourceShopId,_that.destinationShopId,_that.quantity,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockTransfer implements StockTransfer {
  const _StockTransfer({required this.id, required this.productId, required this.sourceShopId, required this.destinationShopId, required this.quantity, this.notes, required this.createdAt});
  factory _StockTransfer.fromJson(Map<String, dynamic> json) => _$StockTransferFromJson(json);

@override final  String id;
@override final  String productId;
@override final  String sourceShopId;
@override final  String destinationShopId;
@override final  double quantity;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockTransferCopyWith<_StockTransfer> get copyWith => __$StockTransferCopyWithImpl<_StockTransfer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockTransferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockTransfer&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.sourceShopId, sourceShopId) || other.sourceShopId == sourceShopId)&&(identical(other.destinationShopId, destinationShopId) || other.destinationShopId == destinationShopId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,sourceShopId,destinationShopId,quantity,notes,createdAt);

@override
String toString() {
  return 'StockTransfer(id: $id, productId: $productId, sourceShopId: $sourceShopId, destinationShopId: $destinationShopId, quantity: $quantity, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StockTransferCopyWith<$Res> implements $StockTransferCopyWith<$Res> {
  factory _$StockTransferCopyWith(_StockTransfer value, $Res Function(_StockTransfer) _then) = __$StockTransferCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String sourceShopId, String destinationShopId, double quantity, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$StockTransferCopyWithImpl<$Res>
    implements _$StockTransferCopyWith<$Res> {
  __$StockTransferCopyWithImpl(this._self, this._then);

  final _StockTransfer _self;
  final $Res Function(_StockTransfer) _then;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? sourceShopId = null,Object? destinationShopId = null,Object? quantity = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_StockTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,sourceShopId: null == sourceShopId ? _self.sourceShopId : sourceShopId // ignore: cast_nullable_to_non_nullable
as String,destinationShopId: null == destinationShopId ? _self.destinationShopId : destinationShopId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
