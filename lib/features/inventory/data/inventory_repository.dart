import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/inventory.dart';
import '../domain/stock_transfer.dart';
import '../domain/stock_adjustment.dart';

class InventoryRepository {
  final _uuid = const Uuid();
  final _inventoryController = StreamController<List<Inventory>>.broadcast();
  final _adjustmentsController = StreamController<List<StockAdjustment>>.broadcast();
  final _transfersController = StreamController<List<StockTransfer>>.broadcast();

  final List<Inventory> _inventory = [
    // Shop 1 (Downtown Flagship Store)
    Inventory(id: 'inv_1', productId: 'prod_headphones', shopId: 'shop_flagship', quantity: 14.0, updatedAt: DateTime.now()),
    Inventory(id: 'inv_2', productId: 'prod_desklamp', shopId: 'shop_flagship', quantity: 10.0, updatedAt: DateTime.now()),
    Inventory(id: 'inv_3', productId: 'prod_greentea', shopId: 'shop_flagship', quantity: 24.0, updatedAt: DateTime.now()),
    Inventory(id: 'inv_4', productId: 'prod_tshirt', shopId: 'shop_flagship', quantity: 30.0, updatedAt: DateTime.now()),
    Inventory(id: 'inv_5', productId: 'prod_screwdrivers', shopId: 'shop_flagship', quantity: 2.0, updatedAt: DateTime.now()), // LOW STOCK

    // Shop 2 (Westside Branch)
    Inventory(id: 'inv_6', productId: 'prod_headphones', shopId: 'shop_westside', quantity: 3.0, updatedAt: DateTime.now()), // LOW STOCK
    Inventory(id: 'inv_7', productId: 'prod_desklamp', shopId: 'shop_westside', quantity: 6.0, updatedAt: DateTime.now()), // LOW STOCK
    Inventory(id: 'inv_8', productId: 'prod_greentea', shopId: 'shop_westside', quantity: 18.0, updatedAt: DateTime.now()),
    Inventory(id: 'inv_9', productId: 'prod_tshirt', shopId: 'shop_westside', quantity: 12.0, updatedAt: DateTime.now()),
    Inventory(id: 'inv_10', productId: 'prod_screwdrivers', shopId: 'shop_westside', quantity: 7.0, updatedAt: DateTime.now()),
  ];

  final List<StockAdjustment> _adjustments = [
    StockAdjustment(
      id: 'adj_1',
      productId: 'prod_headphones',
      shopId: 'shop_flagship',
      quantityChanged: 5.0,
      reason: 'Restock',
      notes: 'Weekly vendor shipment received',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    StockAdjustment(
      id: 'adj_2',
      productId: 'prod_screwdrivers',
      shopId: 'shop_flagship',
      quantityChanged: -1.0,
      reason: 'Damage',
      notes: 'Item damaged during handling',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  final List<StockTransfer> _transfers = [
    StockTransfer(
      id: 'tr_1',
      productId: 'prod_tshirt',
      sourceShopId: 'shop_flagship',
      destinationShopId: 'shop_westside',
      quantity: 5.0,
      notes: 'Urgent weekend demand restock',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  InventoryRepository();

  List<Inventory> get currentInventory => List.unmodifiable(_inventory);

  void _notifyInventory() {
    _inventoryController.add(List.unmodifiable(_inventory));
  }

  Stream<List<Inventory>> watchAllInventory() async* {
    yield List.unmodifiable(_inventory);
    yield* _inventoryController.stream;
  }

  Stream<List<Inventory>> watchInventoryByShop(String shopId) async* {
    yield _inventory.where((i) => i.shopId == shopId).toList();
    yield* _inventoryController.stream.map(
      (list) => list.where((i) => i.shopId == shopId).toList(),
    );
  }

  Stream<List<Inventory>> watchInventoryByProduct(String productId) async* {
    yield _inventory.where((i) => i.productId == productId).toList();
    yield* _inventoryController.stream.map(
      (list) => list.where((i) => i.productId == productId).toList(),
    );
  }

  Stream<List<StockAdjustment>> watchAdjustments() async* {
    yield List.unmodifiable(_adjustments);
    yield* _adjustmentsController.stream;
  }

  Stream<List<StockTransfer>> watchTransfers() async* {
    yield List.unmodifiable(_transfers);
    yield* _transfersController.stream;
  }

  double getProductStockInShop(String productId, String shopId) {
    try {
      return _inventory.firstWhere(
        (i) => i.productId == productId && i.shopId == shopId,
      ).quantity;
    } catch (_) {
      return 0.0;
    }
  }

  double getTotalProductStock(String productId) {
    return _inventory
        .where((i) => i.productId == productId)
        .fold(0.0, (sum, i) => sum + i.quantity);
  }

  Future<void> adjustStock(StockAdjustment adjustment) async {
    final index = _inventory.indexWhere(
      (i) => i.shopId == adjustment.shopId && i.productId == adjustment.productId,
    );

    if (index == -1) {
      _inventory.add(Inventory(
        id: 'inv_${_uuid.v4().substring(0, 8)}',
        productId: adjustment.productId,
        shopId: adjustment.shopId,
        quantity: adjustment.quantityChanged < 0 ? 0 : adjustment.quantityChanged,
        updatedAt: DateTime.now(),
      ));
    } else {
      final existing = _inventory[index];
      final newQty = existing.quantity + adjustment.quantityChanged;
      _inventory[index] = existing.copyWith(
        quantity: newQty < 0 ? 0 : newQty,
        updatedAt: DateTime.now(),
      );
    }

    _adjustments.insert(0, adjustment.copyWith(
      id: adjustment.id.isEmpty ? 'adj_${_uuid.v4().substring(0, 8)}' : adjustment.id,
      createdAt: DateTime.now(),
    ));

    _notifyInventory();
    _adjustmentsController.add(List.unmodifiable(_adjustments));
  }

  Future<void> transferStock(StockTransfer transfer) async {
    final sourceIndex = _inventory.indexWhere(
      (i) => i.shopId == transfer.sourceShopId && i.productId == transfer.productId,
    );

    if (sourceIndex == -1 || _inventory[sourceIndex].quantity < transfer.quantity) {
      throw Exception('Insufficient stock in source shop');
    }

    // Deduct source
    final source = _inventory[sourceIndex];
    _inventory[sourceIndex] = source.copyWith(
      quantity: source.quantity - transfer.quantity,
      updatedAt: DateTime.now(),
    );

    // Add destination
    final destIndex = _inventory.indexWhere(
      (i) => i.shopId == transfer.destinationShopId && i.productId == transfer.productId,
    );

    if (destIndex == -1) {
      _inventory.add(Inventory(
        id: 'inv_${_uuid.v4().substring(0, 8)}',
        productId: transfer.productId,
        shopId: transfer.destinationShopId,
        quantity: transfer.quantity,
        updatedAt: DateTime.now(),
      ));
    } else {
      final dest = _inventory[destIndex];
      _inventory[destIndex] = dest.copyWith(
        quantity: dest.quantity + transfer.quantity,
        updatedAt: DateTime.now(),
      );
    }

    _transfers.insert(0, transfer.copyWith(
      id: transfer.id.isEmpty ? 'tr_${_uuid.v4().substring(0, 8)}' : transfer.id,
      createdAt: DateTime.now(),
    ));

    _notifyInventory();
    _transfersController.add(List.unmodifiable(_transfers));
  }
}

final _singletonInventoryRepo = InventoryRepository();

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return _singletonInventoryRepo;
});

final allInventoryStreamProvider = StreamProvider<List<Inventory>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAllInventory();
});

final stockAdjustmentsStreamProvider = StreamProvider<List<StockAdjustment>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAdjustments();
});

final stockTransfersStreamProvider = StreamProvider<List<StockTransfer>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchTransfers();
});
