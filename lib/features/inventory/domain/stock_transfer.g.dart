// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockTransfer _$StockTransferFromJson(Map<String, dynamic> json) =>
    _StockTransfer(
      id: json['id'] as String,
      productId: json['productId'] as String,
      sourceShopId: json['sourceShopId'] as String,
      destinationShopId: json['destinationShopId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StockTransferToJson(_StockTransfer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'sourceShopId': instance.sourceShopId,
      'destinationShopId': instance.destinationShopId,
      'quantity': instance.quantity,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
