import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_transfer.freezed.dart';
part 'stock_transfer.g.dart';

@freezed
abstract class StockTransfer with _$StockTransfer {
  const factory StockTransfer({
    required String id,
    required String productId,
    required String sourceShopId,
    required String destinationShopId,
    required double quantity,
    String? notes,
    required DateTime createdAt,
  }) = _StockTransfer;

  factory StockTransfer.fromJson(Map<String, dynamic> json) =>
      _$StockTransferFromJson(json);
}
