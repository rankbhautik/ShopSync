// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String?,
  mainCategoryId: json['mainCategoryId'] as String,
  subcategoryId: json['subcategoryId'] as String?,
  purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
  sellingPrice: (json['sellingPrice'] as num).toDouble(),
  unit: json['unit'] as String,
  barcode: json['barcode'] as String?,
  description: json['description'] as String?,
  notes: json['notes'] as String?,
  minimumStock: (json['minimumStock'] as num).toInt(),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sku': instance.sku,
  'mainCategoryId': instance.mainCategoryId,
  'subcategoryId': instance.subcategoryId,
  'purchasePrice': instance.purchasePrice,
  'sellingPrice': instance.sellingPrice,
  'unit': instance.unit,
  'barcode': instance.barcode,
  'description': instance.description,
  'notes': instance.notes,
  'minimumStock': instance.minimumStock,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
