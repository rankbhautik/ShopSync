import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/domain/category.dart';
import '../../shops/data/shop_repository.dart';
import '../../shops/domain/shop.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../inventory/domain/inventory.dart';
import '../../inventory/presentation/stock_adjustment_screen.dart';
import 'add_product_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/main_navigation_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  final ScrollController _mainCatScrollController = ScrollController();
  final ScrollController _subCatScrollController = ScrollController();
  String _searchQuery = '';
  String? _selectedCategoryFilter; // null means 'All Products'
  String? _selectedSubcategoryFilter; // null means all in selected category
  String _sortBy = 'name'; // 'name', 'price_asc', 'price_desc', 'stock_asc'

  @override
  void dispose() {
    _searchController.dispose();
    _mainCatScrollController.dispose();
    _subCatScrollController.dispose();
    super.dispose();
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to remove "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A90A6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(productRepositoryProvider).deleteProduct(product.id);
              if (mounted) {
                AppToast.showInfo(context, 'Product "${product.name}" removed');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openEditScreen(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddProductScreen(productToEdit: product),
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort Products By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E2243))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            _buildSortOption(ctx, 'Name (A to Z)', 'name', Icons.sort_by_alpha_rounded),
            _buildSortOption(ctx, 'Price (Low to High)', 'price_asc', Icons.arrow_upward_rounded),
            _buildSortOption(ctx, 'Price (High to Low)', 'price_desc', Icons.arrow_downward_rounded),
            _buildSortOption(ctx, 'Stock (Lowest First)', 'stock_asc', Icons.warning_amber_rounded),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext ctx, String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : const Color(0xFF8A90A6)),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? AppTheme.primaryColor : const Color(0xFF1E2243))),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(ctx);
      },
    );
  }

  void _showProductDetailModal(
    BuildContext context,
    Product product,
    String mainCatName,
    String subCatName,
    double totalStock,
    bool isLowStock,
    List<Inventory> productInventory,
    List<Shop> shops,
  ) {
    final purchasePrice = product.purchasePrice ?? 0.0;
    final sellingPrice = product.sellingPrice;
    final profitMargin = sellingPrice - purchasePrice;
    final marginPercent = sellingPrice > 0 ? ((profitMargin / sellingPrice) * 100).toStringAsFixed(1) : '0.0';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E4EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.15),
                          AppTheme.secondaryColor.withValues(alpha: 0.25),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        product.name.isNotEmpty ? product.name[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E2243),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5356FB).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                mainCatName,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5356FB)),
                              ),
                            ),
                            if (subCatName.isNotEmpty && subCatName != 'None')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B894).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subCatName,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00B894)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF8A90A6)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModalMetric('Selling Price', CurrencyFormatter.format(sellingPrice), AppTheme.primaryColor),
                    ),
                    _buildModalDivider(),
                    Expanded(
                      child: _buildModalMetric('Cost Price', CurrencyFormatter.format(purchasePrice), const Color(0xFF1E2243)),
                    ),
                    _buildModalDivider(),
                    Expanded(
                      child: _buildModalMetric('Margin', '${CurrencyFormatter.format(profitMargin)}\n($marginPercent%)', const Color(0xFF00B894)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isLowStock ? const Color(0xFFFF7675).withValues(alpha: 0.08) : const Color(0xFF00B894).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                            color: isLowStock ? const Color(0xFFFF7675) : const Color(0xFF00B894),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLowStock ? 'Low Stock Alert' : 'Stock Optimal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isLowStock ? const Color(0xFFFF7675) : const Color(0xFF00B894),
                                ),
                              ),
                              Text(
                                '${totalStock.toStringAsFixed(0)} ${product.unit} available',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E2243)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Min Alert', style: TextStyle(fontSize: 11, color: Color(0xFF8A90A6))),
                        Text('${product.minimumStock} ${product.unit}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              if (product.description != null && product.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E2243))),
                const SizedBox(height: 4),
                Text(product.description!, style: const TextStyle(fontSize: 12.5, color: Color(0xFF636A88))),
              ],
              const SizedBox(height: 18),
              const Text('Stock by Store Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E2243))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (int sIdx = 0; sIdx < shops.length; sIdx++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.store_rounded, size: 16, color: Color(0xFF5356FB)),
                                const SizedBox(width: 8),
                                Text(shops[sIdx].name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E2243))),
                              ],
                            ),
                            Text(
                              '${productInventory.where((i) => i.shopId == shops[sIdx].id).fold(0.0, (sum, i) => sum + i.quantity).toStringAsFixed(0)} ${product.unit}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF5356FB)),
                            ),
                          ],
                        ),
                      ),
                      if (sIdx < shops.length - 1)
                        const Divider(height: 1, color: Color(0xFFEBEBF5)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('Adjust Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StockAdjustmentScreen(initialProductId: product.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E2243),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      side: const BorderSide(color: Color(0xFFD6DAE6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openEditScreen(product);
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7675).withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7675), size: 20),
                    tooltip: 'Delete Product',
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDelete(product);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8A90A6), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildModalDivider() {
    return Container(width: 1, height: 26, color: const Color(0xFFE2E4EC));
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final inventoryAsync = ref.watch(allInventoryStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Products & Catalog'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, color: AppTheme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name, SKU, barcode, category...',
                        hintStyle: const TextStyle(color: Color(0xFFA5ABC0), fontSize: 13.5),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: IconButton(
                    tooltip: 'Sort Options',
                    icon: const Icon(Icons.sort_rounded, color: AppTheme.primaryColor),
                    onPressed: _showSortDialog,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_new_product',
        backgroundColor: AppTheme.primaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: productsAsync.when(
        data: (products) {
          final categories = categoriesAsync.value ?? [];
          final inventoryList = inventoryAsync.value ?? [];
          final shops = ref.watch(shopsStreamProvider).value ?? [];
          final stockFilter = ref.watch(productStockFilterProvider);

          final mainCategories = categories.where((c) => c.parentId == null).toList();
          final subcategories = categories.where((c) => c.parentId != null).toList();

          final availableSubcategories = _selectedCategoryFilter != null
              ? subcategories.where((s) => s.parentId == _selectedCategoryFilter).toList()
              : <Category>[];

          final selectedMainCategory = mainCategories
              .where((c) => c.id == _selectedCategoryFilter)
              .firstOrNull;

          final selectedSubcategory = subcategories
              .where((s) => s.id == _selectedSubcategoryFilter)
              .firstOrNull;

          final catMap = {for (var c in categories) c.id: c.name};

          final query = _searchQuery.toLowerCase();
          final filteredProducts = products.where((p) {
            final pStock = inventoryList
                .where((i) => i.productId == p.id)
                .fold(0.0, (sum, i) => sum + i.quantity);
            final pCat = (catMap[p.mainCategoryId] ?? '').toLowerCase();
            final pSub = (p.subcategoryId != null ? (catMap[p.subcategoryId] ?? '') : '').toLowerCase();

            final matchesSearch = query.isEmpty ||
                p.name.toLowerCase().contains(query) ||
                (p.sku?.toLowerCase().contains(query) ?? false) ||
                (p.barcode?.toLowerCase().contains(query) ?? false) ||
                (p.description?.toLowerCase().contains(query) ?? false) ||
                pCat.contains(query) ||
                pSub.contains(query);

            final matchesCat = _selectedCategoryFilter == null ||
                p.mainCategoryId == _selectedCategoryFilter;
            final matchesSub = _selectedSubcategoryFilter == null ||
                p.subcategoryId == _selectedSubcategoryFilter;

            bool matchesStock = true;
            if (stockFilter == 'low_stock') {
              matchesStock = pStock <= p.minimumStock && pStock > 0;
            } else if (stockFilter == 'out_of_stock') {
              matchesStock = pStock <= 0;
            } else if (stockFilter == 'in_stock') {
              matchesStock = pStock > p.minimumStock;
            }

            return matchesSearch && matchesCat && matchesSub && matchesStock;
          }).toList();

          if (_sortBy == 'price_asc') {
            filteredProducts.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
          } else if (_sortBy == 'price_desc') {
            filteredProducts.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
          } else if (_sortBy == 'stock_asc') {
            filteredProducts.sort((a, b) {
              final sa = inventoryList.where((i) => i.productId == a.id).fold(0.0, (s, i) => s + i.quantity);
              final sb = inventoryList.where((i) => i.productId == b.id).fold(0.0, (s, i) => s + i.quantity);
              return sa.compareTo(sb);
            });
          } else {
            filteredProducts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          }

          final lowCount = products.where((p) {
            final s = inventoryList.where((i) => i.productId == p.id).fold(0.0, (sum, i) => sum + i.quantity);
            return s <= p.minimumStock && s > 0;
          }).length;

          final outCount = products.where((p) {
            final s = inventoryList.where((i) => i.productId == p.id).fold(0.0, (sum, i) => sum + i.quantity);
            return s <= 0;
          }).length;

          final inCount = products.where((p) {
            final s = inventoryList.where((i) => i.productId == p.id).fold(0.0, (sum, i) => sum + i.quantity);
            return s > p.minimumStock;
          }).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Category filter scrollable row
              if (mainCategories.isNotEmpty)
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.stylus,
                    },
                  ),
                  child: SingleChildScrollView(
                    controller: _mainCatScrollController,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      children: [
                        _buildFilterPill(
                          title: 'All Products',
                          count: products.length,
                          isSelected: _selectedCategoryFilter == null,
                          icon: Icons.grid_view_rounded,
                          onTap: () {
                            setState(() {
                              _selectedCategoryFilter = null;
                              _selectedSubcategoryFilter = null;
                            });
                          },
                        ),
                        for (final cat in mainCategories) ...[
                          const SizedBox(width: 8),
                          _buildFilterPill(
                            title: cat.name,
                            count: products.where((p) => p.mainCategoryId == cat.id).length,
                            isSelected: _selectedCategoryFilter == cat.id,
                            icon: Icons.folder_rounded,
                            onTap: () {
                              setState(() {
                                if (_selectedCategoryFilter == cat.id) {
                                  _selectedCategoryFilter = null;
                                  _selectedSubcategoryFilter = null;
                                } else {
                                  _selectedCategoryFilter = cat.id;
                                  _selectedSubcategoryFilter = null;
                                }
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Subcategory filter scrollable row (when main category is selected and has subs)
              if (_selectedCategoryFilter != null && availableSubcategories.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5356FB).withValues(alpha: 0.04),
                    border: Border(
                      top: BorderSide(color: const Color(0xFF5356FB).withValues(alpha: 0.08)),
                      bottom: BorderSide(color: const Color(0xFF5356FB).withValues(alpha: 0.08)),
                    ),
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                      },
                    ),
                    child: SingleChildScrollView(
                      controller: _subCatScrollController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right_rounded,
                                    size: 16, color: Color(0xFF5356FB)),
                                const SizedBox(width: 4),
                                Text(
                                  'Subcategories:',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF5356FB).withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildSubcategoryFilterPill(
                            title: 'All ${selectedMainCategory?.name ?? ""}',
                            count: products.where((p) => p.mainCategoryId == _selectedCategoryFilter).length,
                            isSelected: _selectedSubcategoryFilter == null,
                            onTap: () {
                              setState(() => _selectedSubcategoryFilter = null);
                            },
                          ),
                          for (final sub in availableSubcategories) ...[
                            const SizedBox(width: 8),
                            _buildSubcategoryFilterPill(
                              title: sub.name,
                              count: products.where((p) => p.subcategoryId == sub.id).length,
                              isSelected: _selectedSubcategoryFilter == sub.id,
                              onTap: () {
                                setState(() {
                                  _selectedSubcategoryFilter =
                                      _selectedSubcategoryFilter == sub.id ? null : sub.id;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

              // Active filter breadcrumb & result summary
              if (_selectedCategoryFilter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E4F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedMainCategory?.name ?? 'Category',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E2243),
                              ),
                            ),
                            if (selectedSubcategory != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF8A90A6)),
                              ),
                              Text(
                                selectedSubcategory.name,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00B894),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryFilter = null;
                                  _selectedSubcategoryFilter = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF8A90A6)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${filteredProducts.length} ${filteredProducts.length == 1 ? "product" : "products"})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A90A6),
                        ),
                      ),
                    ],
                  ),
                ),

              // Quick Stock Filter Pills Row
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      _buildStockFilterChip('All Items', 'all', products.length, stockFilter),
                      const SizedBox(width: 8),
                      _buildStockFilterChip('Low Stock', 'low_stock', lowCount, stockFilter, color: const Color(0xFFFF7675)),
                      const SizedBox(width: 8),
                      _buildStockFilterChip('Out of Stock', 'out_of_stock', outCount, stockFilter, color: const Color(0xFFE17055)),
                      const SizedBox(width: 8),
                      _buildStockFilterChip('In Stock', 'in_stock', inCount, stockFilter, color: const Color(0xFF00B894)),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.inventory_2_outlined,
                                    size: 54, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No products match "$_searchQuery"'
                                    : (stockFilter != 'all' ? 'No items in "$stockFilter" category' : 'No products found'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E2243)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try clearing filters or search keywords.',
                                style: TextStyle(fontSize: 13, color: Color(0xFF8A90A6)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_searchQuery.isNotEmpty || _selectedCategoryFilter != null || stockFilter != 'all')
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF5356FB),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      label: const Text('Reset Filters'),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _selectedCategoryFilter = null;
                                          _selectedSubcategoryFilter = null;
                                        });
                                        ref.read(productStockFilterProvider.notifier).state = 'all';
                                      },
                                    ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    label: const Text('New Product'),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const AddProductScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 110),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final categoryName = catMap[product.mainCategoryId] ?? 'General';
                          final subcategoryName = product.subcategoryId != null ? (catMap[product.subcategoryId] ?? '') : '';

                          final totalStock = inventoryList
                              .where((i) => i.productId == product.id)
                              .fold(0.0, (sum, i) => sum + i.quantity);

                          final isLowStock = totalStock <= product.minimumStock;
                          final productInventory = inventoryList.where((i) => i.productId == product.id).toList();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () => _showProductDetailModal(
                                  context,
                                  product,
                                  categoryName,
                                  subcategoryName,
                                  totalStock,
                                  isLowStock,
                                  productInventory,
                                  shops,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product Avatar
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryColor.withValues(alpha: 0.15),
                                          AppTheme.secondaryColor.withValues(alpha: 0.25),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        product.name.isNotEmpty
                                            ? product.name[0].toUpperCase()
                                            : 'P',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: Color(0xFF1E2243),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  CurrencyFormatter.format(product.sellingPrice),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ),
                                                if (product.purchasePrice != null && product.purchasePrice! > 0)
                                                  Text(
                                                    'Cost: ${CurrencyFormatter.format(product.purchasePrice)}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFF8A90A6),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF5356FB).withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                categoryName,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                            ),
                                            if (product.subcategoryId != null &&
                                                catMap.containsKey(product.subcategoryId))
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00B894).withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  catMap[product.subcategoryId]!,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF00B894),
                                                  ),
                                                ),
                                              ),
                                            if (product.sku != null &&
                                                product.sku!.isNotEmpty)
                                              Text(
                                                'SKU: ${product.sku}',
                                                style: const TextStyle(
                                                    fontSize: 11, color: Color(0xFF8A90A6)),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isLowStock
                                                      ? const Color(0xFFFF7675).withValues(alpha: 0.12)
                                                      : const Color(0xFF00B894).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isLowStock
                                                        ? Icons.warning_amber_rounded
                                                        : Icons.check_circle_rounded,
                                                    size: 14,
                                                    color: isLowStock
                                                        ? const Color(0xFFFF7675)
                                                        : const Color(0xFF00B894),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      '${totalStock.toStringAsFixed(0)} ${product.unit} ${isLowStock ? "(Low)" : ""}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: isLowStock
                                                            ? const Color(0xFFFF7675)
                                                            : const Color(0xFF00B894),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined,
                                                size: 19, color: Color(0xFF7A809B)),
                                            tooltip: 'Edit',
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _openEditScreen(product),
                                          ),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded,
                                                size: 19, color: Color(0xFFFF7675)),
                                            tooltip: 'Delete',
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _confirmDelete(product),
                                          ),
                                        ],
                                      ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                      },
                    ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildFilterPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE5E7F2),
            width: 1,
          ),
          boxShadow: isSelected ? AppTheme.primaryGlowShadow : AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF7A809B),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E2243),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFFF0F2F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF7A809B),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryFilterPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
  }) {
    const activeColor = Color(0xFF00B894);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E4F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.subdirectory_arrow_right_rounded,
              size: 14,
              color: isSelected ? Colors.white : activeColor,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E2243),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFF1F3FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF636A88),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockFilterChip(
    String label,
    String value,
    int count,
    String currentFilter, {
    Color color = AppTheme.primaryColor,
  }) {
    final isSelected = currentFilter == value;
    return GestureDetector(
      onTap: () {
        ref.read(productStockFilterProvider.notifier).state = value;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E4F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E2243),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
