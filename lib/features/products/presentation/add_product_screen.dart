// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/domain/category.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../shops/data/shop_repository.dart';
import '../../inventory/domain/stock_adjustment.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _minStockController;
  late final TextEditingController _initialStockController;
  late final TextEditingController _descController;
  
  String? _selectedMainCategoryId;
  String? _selectedSubcategoryId;
  String _selectedUnit = 'pcs';
  final List<String> _units = ['pcs', 'box', 'kg', 'ltr', 'set', 'pack', 'meter', 'pair'];

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _sellingPriceController = TextEditingController(text: p?.sellingPrice != null ? p!.sellingPrice.toString() : '');
    _purchasePriceController = TextEditingController(text: p?.purchasePrice != null ? p!.purchasePrice.toString() : '');
    _minStockController = TextEditingController(text: p?.minimumStock != null ? p!.minimumStock.toString() : '5');
    _initialStockController = TextEditingController(text: '10');
    _descController = TextEditingController(text: p?.description ?? '');
    _selectedMainCategoryId = p?.mainCategoryId;
    _selectedSubcategoryId = p?.subcategoryId;
    if (p != null && _units.contains(p.unit)) {
      _selectedUnit = p.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    _minStockController.dispose();
    _initialStockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Quick dialog to add a new subcategory on the fly
  void _showAddSubcategoryDialog(BuildContext context, String parentCategoryId, String parentName) {
    final subNameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'New Subcategory for $parentName',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1E2243)),
        ),
        content: TextField(
          controller: subNameCtrl,
          autofocus: true,
          style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Subcategory Name *',
            labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
            hintText: 'e.g. Headphones, Snack Bars...',
            hintStyle: const TextStyle(color: Color(0xFF9EA5C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A90A6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              final name = subNameCtrl.text.trim();
              if (name.isEmpty) return;
              final repo = ref.read(categoryRepositoryProvider);
              await repo.addCategory(
                Category(
                  id: '',
                  name: name,
                  description: 'Subcategory of $parentName',
                  parentId: parentCategoryId,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              final newlyAdded = repo.currentCategories.lastWhere((c) => c.parentId == parentCategoryId);
              setState(() {
                _selectedSubcategoryId = newlyAdded.id;
              });
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Add Subcategory'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    final sellingPrice = double.parse(_sellingPriceController.text.trim());
    final purchasePrice = _purchasePriceController.text.trim().isNotEmpty
        ? double.tryParse(_purchasePriceController.text.trim())
        : null;
    final minStock = int.tryParse(_minStockController.text.trim()) ?? 5;
    final initialStock = double.tryParse(_initialStockController.text.trim()) ?? 0.0;

    final productRepo = ref.read(productRepositoryProvider);

    if (isEditing) {
      final updated = widget.productToEdit!.copyWith(
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        mainCategoryId: _selectedMainCategoryId ?? 'cat_electronics',
        subcategoryId: _selectedSubcategoryId,
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
        minimumStock: minStock,
        unit: _selectedUnit,
        description: _descController.text.trim(),
        updatedAt: DateTime.now(),
      );
      await productRepo.updateProduct(updated);
      if (mounted) {
        AppToast.showSuccess(context, 'Product updated successfully!');
        Navigator.of(context).pop();
      }
    } else {
      final now = DateTime.now();
      final newProduct = Product(
        id: '',
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        mainCategoryId: _selectedMainCategoryId ?? 'cat_electronics',
        subcategoryId: _selectedSubcategoryId,
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
        minimumStock: minStock,
        unit: _selectedUnit,
        description: _descController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await productRepo.addProduct(newProduct);

      // Add initial stock if positive
      if (initialStock > 0) {
        final shops = ref.read(shopRepositoryProvider).currentShops;
        final targetShopId = shops.isNotEmpty ? shops.first.id : 'shop_flagship';
        final savedProduct = productRepo.currentProducts.last;
        await ref.read(inventoryRepositoryProvider).adjustStock(
          StockAdjustment(
            id: '',
            productId: savedProduct.id,
            shopId: targetShopId,
            quantityChanged: initialStock,
            reason: 'Restock',
            notes: 'Initial stock setup',
            createdAt: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        AppToast.showSuccess(context, 'Product added successfully to inventory!');
        _nameController.clear();
        _skuController.clear();
        _sellingPriceController.clear();
        _purchasePriceController.clear();
        _minStockController.text = '5';
        _initialStockController.text = '10';
        _descController.clear();
        setState(() {
          _selectedSubcategoryId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesList = ref.watch(categoriesStreamProvider).value ?? [];
    
    // Split into main categories & subcategories
    final mainCategories = categoriesList.where((c) => c.parentId == null).toList();

    // Default main category if not set
    if (_selectedMainCategoryId == null && mainCategories.isNotEmpty) {
      _selectedMainCategoryId = mainCategories.first.id;
    }

    // Available subcategories for the chosen main category
    final availableSubcategories = categoriesList
        .where((c) => c.parentId == _selectedMainCategoryId)
        .toList();

    // Reset subcategory if current selection is not under the selected main category
    if (_selectedSubcategoryId != null &&
        !availableSubcategories.any((sub) => sub.id == _selectedSubcategoryId)) {
      _selectedSubcategoryId = null;
    }

    final selectedMainCategoryObj = mainCategories.where((c) => c.id == _selectedMainCategoryId).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Item' : 'New Product Item',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Visual Step Flow Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  _buildFlowStepBadge(number: '1', title: 'Category', isDone: _selectedMainCategoryId != null),
                  _buildFlowDivider(),
                  _buildFlowStepBadge(number: '2', title: 'Subcategory', isDone: _selectedSubcategoryId != null),
                  _buildFlowDivider(),
                  _buildFlowStepBadge(number: '3', title: 'Product Details', isDone: _nameController.text.trim().isNotEmpty),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 1: Category Selection
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.category_rounded, color: AppTheme.primaryColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Step 1: Main Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2243),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (mainCategories.isEmpty)
                    const Text('No categories found. Please create one.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: mainCategories.map((cat) {
                        final isSelected = _selectedMainCategoryId == cat.id;
                        return ChoiceChip(
                          label: Text(cat.name),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedMainCategoryId = cat.id;
                                _selectedSubcategoryId = null; // Reset subcategory when main changes
                              });
                            }
                          },
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: const Color(0xFFF7F8FC),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E2243),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryColor : const Color(0xFFE8EAF3),
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Subcategory Selection
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B894).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.subdirectory_arrow_right_rounded, color: Color(0xFF00B894), size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Step 2: Subcategory',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E2243),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedMainCategoryId != null && selectedMainCategoryObj != null)
                        TextButton.icon(
                          onPressed: () => _showAddSubcategoryDialog(
                            context,
                            _selectedMainCategoryId!,
                            selectedMainCategoryObj.name,
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Sub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (availableSubcategories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFF8A90A6)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No subcategories for ${selectedMainCategoryObj?.name ?? "selected category"}. Tap "+ Add Sub" above to create one or proceed with general.',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8A90A6)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSubcategories.map((sub) {
                        final isSelected = _selectedSubcategoryId == sub.id;
                        return ChoiceChip(
                          label: Text(sub.name),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              _selectedSubcategoryId = val ? sub.id : null;
                            });
                          },
                          selectedColor: const Color(0xFF00B894),
                          backgroundColor: const Color(0xFFF7F8FC),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E2243),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF00B894) : const Color(0xFFE8EAF3),
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 3: Product Name & Code Info
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0984E3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF0984E3), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Step 3: Product Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2243),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                      hintText: 'e.g. Wireless ANC Earbuds, Green Tea Box',
                      hintStyle: const TextStyle(color: Color(0xFF9EA5C0)),
                      prefixIcon: const Icon(Icons.label_outline_rounded, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Product name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skuController,
                          style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'SKU / Barcode',
                            labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                            hintText: 'e.g. EAR-101',
                            hintStyle: const TextStyle(color: Color(0xFF9EA5C0)),
                            prefixIcon: const Icon(Icons.qr_code_rounded, color: AppTheme.primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                            prefixIcon: const Icon(Icons.straighten_rounded, color: AppTheme.primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          value: _selectedUnit,
                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600)))).toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val ?? 'pcs'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 4: Pricing & Inventory Details
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7675).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.payments_outlined, color: Color(0xFFFF7675), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Pricing & Initial Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2243),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sellingPriceController,
                          style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w700, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Selling Price (₹) *',
                            labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                            prefixText: '₹ ',
                            prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            final d = double.tryParse(val.trim());
                            if (d == null || d < 0) return 'Invalid price';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _purchasePriceController,
                          style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w700, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Cost Price (₹)',
                            labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                            prefixText: '₹ ',
                            prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E2243)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minStockController,
                          style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Min Stock Alert',
                            labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                            prefixIcon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      if (!isEditing) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _initialStockController,
                            style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w600, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Initial Units',
                              labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                              prefixIcon: const Icon(Icons.inventory_rounded, color: AppTheme.primaryColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes / Description
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(color: Color(0xFF1E2243), fontWeight: FontWeight.w500, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Product Notes / Description (Optional)',
                      labelStyle: const TextStyle(color: Color(0xFF636A88), fontWeight: FontWeight.w600),
                      hintText: 'Add product specs, warranty or special tags...',
                      hintStyle: const TextStyle(color: Color(0xFF9EA5C0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5356FB), Color(0xFF6C5CE7)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.primaryGlowShadow,
              ),
              child: ElevatedButton.icon(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: Text(
                  isEditing ? 'Save Product Changes' : 'Create & Register Product',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStepBadge({
    required String number,
    required String title,
    required bool isDone,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF00B894) : const Color(0xFFE8EAF3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      number,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A809B),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
              color: isDone ? const Color(0xFF1E2243) : const Color(0xFF8A90A6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowDivider() {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFE8EAF3),
    );
  }
}
