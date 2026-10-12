import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_adjustment.freezed.dart';
part 'stock_adjustment.g.dart';

@freezed
abstract class StockAdjustment with _$StockAdjustment {
  const factory StockAdjustment({
    required String id,
    required String productId,
    required String shopId,
    required double quantityChanged, // Can be positive or negative
    required String reason, // 'Damage', 'Loss', 'Correction', etc.
    String? notes,
    required DateTime createdAt,
  }) = _StockAdjustment;

  factory StockAdjustment.fromJson(Map<String, dynamic> json) =>
      _$StockAdjustmentFromJson(json);
}
