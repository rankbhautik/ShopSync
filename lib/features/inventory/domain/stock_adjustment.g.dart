// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockAdjustment _$StockAdjustmentFromJson(Map<String, dynamic> json) =>
    _StockAdjustment(
      id: json['id'] as String,
      productId: json['productId'] as String,
      shopId: json['shopId'] as String,
      quantityChanged: (json['quantityChanged'] as num).toDouble(),
      reason: json['reason'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StockAdjustmentToJson(_StockAdjustment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'shopId': instance.shopId,
      'quantityChanged': instance.quantityChanged,
      'reason': instance.reason,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
