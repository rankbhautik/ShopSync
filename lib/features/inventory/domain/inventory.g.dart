// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inventory _$InventoryFromJson(Map<String, dynamic> json) => _Inventory(
  id: json['id'] as String,
  productId: json['productId'] as String,
  shopId: json['shopId'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$InventoryToJson(_Inventory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'shopId': instance.shopId,
      'quantity': instance.quantity,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
