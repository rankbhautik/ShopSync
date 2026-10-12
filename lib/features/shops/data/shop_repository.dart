import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/shop.dart';

class ShopRepository {
  final _uuid = const Uuid();
  final _controller = StreamController<List<Shop>>.broadcast();

  final List<Shop> _shops = [
    Shop(
      id: 'shop_flagship',
      name: 'Downtown Flagship Store',
      address: '101 MG Road, Commercial Plaza, Floor 1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Shop(
      id: 'shop_westside',
      name: 'Westside Branch',
      address: '204 Ring Road, West Hub, Sector 4',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  ShopRepository();

  void _notify() {
    _controller.add(List.unmodifiable(_shops));
  }

  Stream<List<Shop>> watchShops() async* {
    yield List.unmodifiable(_shops);
    yield* _controller.stream;
  }

  List<Shop> get currentShops => List.unmodifiable(_shops);

  Future<void> addShop(Shop shop) async {
    final newId = shop.id.isEmpty ? 'shop_${_uuid.v4().substring(0, 8)}' : shop.id;
    _shops.add(shop.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    _notify();
  }

  Future<void> updateShop(Shop shop) async {
    final index = _shops.indexWhere((s) => s.id == shop.id);
    if (index != -1) {
      _shops[index] = shop.copyWith(updatedAt: DateTime.now());
      _notify();
    }
  }

  Future<void> deleteShop(String id) async {
    _shops.removeWhere((s) => s.id == id);
    _notify();
  }
}

final _singletonShopRepo = ShopRepository();

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return _singletonShopRepo;
});

final shopsStreamProvider = StreamProvider<List<Shop>>((ref) {
  return ref.watch(shopRepositoryProvider).watchShops();
});
