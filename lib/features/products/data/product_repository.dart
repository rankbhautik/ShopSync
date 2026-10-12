import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/product.dart';

class ProductRepository {
  final _uuid = const Uuid();
  final _controller = StreamController<List<Product>>.broadcast();

  final List<Product> _products = [
    Product(
      id: 'prod_headphones',
      name: 'Wireless ANC Headphones',
      sku: 'HEAD-001',
      mainCategoryId: 'cat_electronics',
      subcategoryId: 'sub_audio',
      purchasePrice: 1200.0,
      sellingPrice: 1999.0,
      unit: 'pcs',
      minimumStock: 5,
      description: 'High fidelity active noise cancelling Bluetooth headphones',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Product(
      id: 'prod_desklamp',
      name: 'Smart LED Desk Lamp',
      sku: 'LAMP-002',
      mainCategoryId: 'cat_electronics',
      subcategoryId: 'sub_smart_home',
      purchasePrice: 450.0,
      sellingPrice: 899.0,
      unit: 'pcs',
      minimumStock: 8,
      description: 'Dimmable color-changing lamp with touch sensor',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Product(
      id: 'prod_greentea',
      name: 'Organic Green Tea (250g)',
      sku: 'TEA-003',
      mainCategoryId: 'cat_groceries',
      subcategoryId: 'sub_beverages',
      purchasePrice: 150.0,
      sellingPrice: 299.0,
      unit: 'box',
      minimumStock: 10,
      description: 'Pure loose leaf organic antioxidant green tea',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Product(
      id: 'prod_tshirt',
      name: 'Classic Crewneck T-Shirt',
      sku: 'SHIRT-004',
      mainCategoryId: 'cat_clothing',
      subcategoryId: 'sub_mens_wear',
      purchasePrice: 220.0,
      sellingPrice: 599.0,
      unit: 'pcs',
      minimumStock: 12,
      description: '100% breathable organic cotton daily wear t-shirt',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Product(
      id: 'prod_screwdrivers',
      name: 'Precision Screwdriver Set',
      sku: 'TOOL-005',
      mainCategoryId: 'cat_hardware',
      subcategoryId: 'sub_hand_tools',
      purchasePrice: 180.0,
      sellingPrice: 449.0,
      unit: 'set',
      minimumStock: 4,
      description: '24-in-1 magnetic screwdriver repair kit for electronics',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  ProductRepository();

  void _notify() {
    _controller.add(List.unmodifiable(_products));
  }

  Stream<List<Product>> watchProducts() async* {
    yield List.unmodifiable(_products);
    yield* _controller.stream;
  }

  List<Product> get currentProducts => List.unmodifiable(_products);

  Future<Product?> getProduct(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    final newId = product.id.isEmpty ? 'prod_${_uuid.v4().substring(0, 8)}' : product.id;
    _products.add(product.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    _notify();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product.copyWith(updatedAt: DateTime.now());
      _notify();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    _notify();
  }
}

final _singletonProductRepo = ProductRepository();

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return _singletonProductRepo;
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});
