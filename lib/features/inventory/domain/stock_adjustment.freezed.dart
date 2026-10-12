// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_adjustment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StockAdjustment {

 String get id; String get productId; String get shopId; double get quantityChanged; String get reason; String? get notes; DateTime get createdAt;
/// Create a copy of StockAdjustment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockAdjustmentCopyWith<StockAdjustment> get copyWith => _$StockAdjustmentCopyWithImpl<StockAdjustment>(this as StockAdjustment, _$identity);

  /// Serializes this StockAdjustment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockAdjustment&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.quantityChanged, quantityChanged) || other.quantityChanged == quantityChanged)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,shopId,quantityChanged,reason,notes,createdAt);

@override
String toString() {
  return 'StockAdjustment(id: $id, productId: $productId, shopId: $shopId, quantityChanged: $quantityChanged, reason: $reason, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StockAdjustmentCopyWith<$Res>  {
  factory $StockAdjustmentCopyWith(StockAdjustment value, $Res Function(StockAdjustment) _then) = _$StockAdjustmentCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String shopId, double quantityChanged, String reason, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$StockAdjustmentCopyWithImpl<$Res>
    implements $StockAdjustmentCopyWith<$Res> {
  _$StockAdjustmentCopyWithImpl(this._self, this._then);

  final StockAdjustment _self;
  final $Res Function(StockAdjustment) _then;

/// Create a copy of StockAdjustment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? shopId = null,Object? quantityChanged = null,Object? reason = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(StockAdjustment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,quantityChanged: null == quantityChanged ? _self.quantityChanged : quantityChanged // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StockAdjustment].
extension StockAdjustmentPatterns on StockAdjustment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockAdjustment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockAdjustment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockAdjustment value)  $default,){
final _that = this;
switch (_that) {
case _StockAdjustment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockAdjustment value)?  $default,){
final _that = this;
switch (_that) {
case _StockAdjustment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String shopId,  double quantityChanged,  String reason,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockAdjustment() when $default != null:
return $default(_that.id,_that.productId,_that.shopId,_that.quantityChanged,_that.reason,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String shopId,  double quantityChanged,  String reason,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _StockAdjustment():
return $default(_that.id,_that.productId,_that.shopId,_that.quantityChanged,_that.reason,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String shopId,  double quantityChanged,  String reason,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StockAdjustment() when $default != null:
return $default(_that.id,_that.productId,_that.shopId,_that.quantityChanged,_that.reason,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockAdjustment implements StockAdjustment {
  const _StockAdjustment({required this.id, required this.productId, required this.shopId, required this.quantityChanged, required this.reason, this.notes, required this.createdAt});
  factory _StockAdjustment.fromJson(Map<String, dynamic> json) => _$StockAdjustmentFromJson(json);

@override final  String id;
@override final  String productId;
@override final  String shopId;
@override final  double quantityChanged;
@override final  String reason;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of StockAdjustment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockAdjustmentCopyWith<_StockAdjustment> get copyWith => __$StockAdjustmentCopyWithImpl<_StockAdjustment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockAdjustmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockAdjustment&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.quantityChanged, quantityChanged) || other.quantityChanged == quantityChanged)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,shopId,quantityChanged,reason,notes,createdAt);

@override
String toString() {
  return 'StockAdjustment(id: $id, productId: $productId, shopId: $shopId, quantityChanged: $quantityChanged, reason: $reason, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StockAdjustmentCopyWith<$Res> implements $StockAdjustmentCopyWith<$Res> {
  factory _$StockAdjustmentCopyWith(_StockAdjustment value, $Res Function(_StockAdjustment) _then) = __$StockAdjustmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String shopId, double quantityChanged, String reason, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$StockAdjustmentCopyWithImpl<$Res>
    implements _$StockAdjustmentCopyWith<$Res> {
  __$StockAdjustmentCopyWithImpl(this._self, this._then);

  final _StockAdjustment _self;
  final $Res Function(_StockAdjustment) _then;

/// Create a copy of StockAdjustment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? shopId = null,Object? quantityChanged = null,Object? reason = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_StockAdjustment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,quantityChanged: null == quantityChanged ? _self.quantityChanged : quantityChanged // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
