import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? sku,
    required String mainCategoryId,
    String? subcategoryId,
    double? purchasePrice,
    required double sellingPrice,
    required String unit,
    String? barcode,
    String? description,
    String? notes,
    required int minimumStock,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
