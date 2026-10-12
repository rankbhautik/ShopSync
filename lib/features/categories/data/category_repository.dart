import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/category.dart';

class CategoryRepository {
  final _uuid = const Uuid();
  final _controller = StreamController<List<Category>>.broadcast();

  final List<Category> _categories = [
    // Main Categories (parentId = null)
    Category(
      id: 'cat_electronics',
      name: 'Electronics',
      description: 'Gadgets, smartphones, accessories & audio gear',
      parentId: null,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Category(
      id: 'cat_groceries',
      name: 'Groceries',
      description: 'Packaged foods, beverages, and daily essentials',
      parentId: null,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Category(
      id: 'cat_clothing',
      name: 'Clothing',
      description: 'Apparel, footwear, and fashion accessories',
      parentId: null,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Category(
      id: 'cat_hardware',
      name: 'Hardware',
      description: 'Tools, electrical supplies, fixtures & fittings',
      parentId: null,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),

    // Subcategories (parentId links to main category id)
    // Under Electronics:
    Category(
      id: 'sub_audio',
      name: 'Audio & Headphones',
      description: 'Wireless earbuds, wired earphones, speakers',
      parentId: 'cat_electronics',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Category(
      id: 'sub_smart_home',
      name: 'Smart Home & Lighting',
      description: 'Smart lamps, plugs, LED fixtures',
      parentId: 'cat_electronics',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Category(
      id: 'sub_mobile_acc',
      name: 'Mobile Accessories',
      description: 'Cables, power banks, cases',
      parentId: 'cat_electronics',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),

    // Under Groceries:
    Category(
      id: 'sub_beverages',
      name: 'Tea & Coffee',
      description: 'Organic green tea, roast coffee beans, powders',
      parentId: 'cat_groceries',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Category(
      id: 'sub_snacks',
      name: 'Packaged Snacks',
      description: 'Biscuits, nuts, crisps',
      parentId: 'cat_groceries',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),

    // Under Clothing:
    Category(
      id: 'sub_mens_wear',
      name: "Men's Casual Wear",
      description: 'T-Shirts, polos, denim',
      parentId: 'cat_clothing',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Category(
      id: 'sub_womens_wear',
      name: "Women's Fashion",
      description: 'Tops, dresses, trousers',
      parentId: 'cat_clothing',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),

    // Under Hardware:
    Category(
      id: 'sub_hand_tools',
      name: 'Hand Tools & Repair Kits',
      description: 'Screwdrivers, wrenches, measuring tapes',
      parentId: 'cat_hardware',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  CategoryRepository();

  void _notify() {
    _controller.add(List.unmodifiable(_categories));
  }

  Stream<List<Category>> watchCategories() async* {
    yield List.unmodifiable(_categories);
    yield* _controller.stream;
  }

  List<Category> get currentCategories => List.unmodifiable(_categories);

  List<Category> getMainCategories() {
    return _categories.where((c) => c.parentId == null).toList();
  }

  List<Category> getSubcategories(String parentId) {
    return _categories.where((c) => c.parentId == parentId).toList();
  }

  Future<void> addCategory(Category category) async {
    final newId = category.id.isEmpty ? 'cat_${_uuid.v4().substring(0, 8)}' : category.id;
    _categories.add(category.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    _notify();
  }

  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category.copyWith(updatedAt: DateTime.now());
      _notify();
    }
  }

  Future<void> deleteCategory(String id) async {
    // When deleting a main category, also cascade or unlink subcategories
    _categories.removeWhere((c) => c.id == id || c.parentId == id);
    _notify();
  }
}

final _singletonCategoryRepo = CategoryRepository();

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return _singletonCategoryRepo;
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories();
});
