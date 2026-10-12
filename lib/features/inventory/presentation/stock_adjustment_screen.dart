// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/stock_adjustment.dart';
import '../domain/stock_transfer.dart';
import '../data/inventory_repository.dart';
import '../../products/data/product_repository.dart';
import '../../shops/data/shop_repository.dart';
import '../../../core/widgets/app_toast.dart';

class StockAdjustmentScreen extends ConsumerStatefulWidget {
  final String? initialProductId;
  final String? initialShopId;

  const StockAdjustmentScreen({
    super.key,
    this.initialProductId,
    this.initialShopId,
  });

  @override
  ConsumerState<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends ConsumerState<StockAdjustmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Adjustment form state
  final _adjFormKey = GlobalKey<FormState>();
  final _adjQuantityController = TextEditingController();
  final _adjNotesController = TextEditingController();
  String? _adjSelectedProductId;
  String? _adjSelectedShopId;
  String _adjSelectedReason = 'Restock';
  final List<String> _reasons = ['Restock', 'Damage', 'Loss', 'Correction', 'Return', 'Other'];
  bool _isAddition = true;

  // Transfer form state
  final _trFormKey = GlobalKey<FormState>();
  final _trQuantityController = TextEditingController();
  final _trNotesController = TextEditingController();
  String? _trSelectedProductId;
  String? _trSourceShopId;
  String? _trDestShopId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _adjSelectedProductId = widget.initialProductId;
    _adjSelectedShopId = widget.initialShopId;
    _trSelectedProductId = widget.initialProductId;
    _trSourceShopId = widget.initialShopId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adjQuantityController.dispose();
    _adjNotesController.dispose();
    _trQuantityController.dispose();
    _trNotesController.dispose();
    super.dispose();
  }

  Future<void> _submitAdjustment() async {
    if (!_adjFormKey.currentState!.validate()) return;
    if (_adjSelectedProductId == null || _adjSelectedShopId == null) {
      AppToast.showWarning(context, 'Please select product and shop');
      return;
    }

    final double qty = double.parse(_adjQuantityController.text.trim());
    final adjustedQty = _isAddition ? qty : -qty;

    final repo = ref.read(inventoryRepositoryProvider);
    await repo.adjustStock(
      StockAdjustment(
        id: '',
        productId: _adjSelectedProductId!,
        shopId: _adjSelectedShopId!,
        quantityChanged: adjustedQty,
        reason: _adjSelectedReason,
        notes: _adjNotesController.text.trim().isEmpty ? null : _adjNotesController.text.trim(),
        createdAt: DateTime.now(),
      ),
    );

    if (mounted) {
      AppToast.showSuccess(
        context,
        'Stock adjusted: ${_isAddition ? "+$qty" : "-$qty"} units recorded',
      );
      _adjQuantityController.clear();
      _adjNotesController.clear();
    }
  }

  Future<void> _submitTransfer() async {
    if (!_trFormKey.currentState!.validate()) return;
    if (_trSelectedProductId == null || _trSourceShopId == null || _trDestShopId == null) {
      AppToast.showWarning(context, 'Please select product and both source & destination shops');
      return;
    }

    if (_trSourceShopId == _trDestShopId) {
      AppToast.showWarning(context, 'Source and destination shops must be different');
      return;
    }

    final double qty = double.parse(_trQuantityController.text.trim());
    final repo = ref.read(inventoryRepositoryProvider);

    try {
      await repo.transferStock(
        StockTransfer(
          id: '',
          productId: _trSelectedProductId!,
          sourceShopId: _trSourceShopId!,
          destinationShopId: _trDestShopId!,
          quantity: qty,
          notes: _trNotesController.text.trim().isEmpty ? null : _trNotesController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Successfully transferred $qty units between shops');
        _trQuantityController.clear();
        _trNotesController.clear();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Transfer failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsStreamProvider).value ?? [];
    final shops = ref.watch(shopsStreamProvider).value ?? [];
    final inventory = ref.watch(allInventoryStreamProvider).value ?? [];

    // Set defaults if empty
    if (_adjSelectedProductId == null && products.isNotEmpty) {
      _adjSelectedProductId = products.first.id;
    }
    if (_adjSelectedShopId == null && shops.isNotEmpty) {
      _adjSelectedShopId = shops.first.id;
    }
    if (_trSelectedProductId == null && products.isNotEmpty) {
      _trSelectedProductId = products.first.id;
    }
    if (_trSourceShopId == null && shops.isNotEmpty) {
      _trSourceShopId = shops.first.id;
    }
    if (_trDestShopId == null && shops.length > 1) {
      _trDestShopId = shops[1].id;
    }

    // Current stock calculation
    final currentAdjStock = inventory
        .where((i) => i.productId == _adjSelectedProductId && i.shopId == _adjSelectedShopId)
        .fold(0.0, (sum, i) => sum + i.quantity);

    final currentSourceStock = inventory
        .where((i) => i.productId == _trSelectedProductId && i.shopId == _trSourceShopId)
        .fold(0.0, (sum, i) => sum + i.quantity);

    final currentDestStock = inventory
        .where((i) => i.productId == _trSelectedProductId && i.shopId == _trDestShopId)
        .fold(0.0, (sum, i) => sum + i.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Operations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.tune), text: 'Adjust Stock'),
            Tab(icon: Icon(Icons.swap_horiz), text: 'Transfer Between Shops'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Adjustment
          Form(
            key: _adjFormKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target Product & Location',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Product *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_bag_outlined),
                          ),
                          value: _adjSelectedProductId,
                          items: products
                              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                              .toList(),
                          onChanged: (val) => setState(() => _adjSelectedProductId = val),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Shop *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.store),
                          ),
                          value: _adjSelectedShopId,
                          items: shops
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                              .toList(),
                          onChanged: (val) => setState(() => _adjSelectedShopId = val),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5356FB).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFF5356FB), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Current In-Shop Stock: ${currentAdjStock.toStringAsFixed(0)} units',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5356FB)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adjustment Type & Quantity',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Add (+)'),
                                value: true,
                                groupValue: _isAddition,
                                onChanged: (val) => setState(() => _isAddition = val!),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Remove (-)'),
                                value: false,
                                groupValue: _isAddition,
                                onChanged: (val) => setState(() => _isAddition = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _adjQuantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity to ${_isAddition ? "Add" : "Remove"} *',
                            border: const OutlineInputBorder(),
                            suffixText: _isAddition ? '+' : '-',
                            suffixStyle: TextStyle(
                              color: _isAddition ? Colors.green : Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Required';
                            final val = double.tryParse(value.trim());
                            if (val == null || val <= 0) return 'Must be greater than 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Reason *',
                            border: OutlineInputBorder(),
                          ),
                          value: _adjSelectedReason,
                          items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (val) => setState(() => _adjSelectedReason = val ?? 'Restock'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _adjNotesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes / Reference',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submitAdjustment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF167D63),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm Adjustment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Tab 2: Transfer Between Shops
          Form(
            key: _trFormKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transfer Details', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Product *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_bag_outlined),
                          ),
                          value: _trSelectedProductId,
                          items: products
                              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                              .toList(),
                          onChanged: (val) => setState(() => _trSelectedProductId = val),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Source Shop (From) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.upload),
                          ),
                          value: _trSourceShopId,
                          items: shops
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                              .toList(),
                          onChanged: (val) => setState(() => _trSourceShopId = val),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Available at source: ${currentSourceStock.toStringAsFixed(0)} units',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Destination Shop (To) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.download),
                          ),
                          value: _trDestShopId,
                          items: shops
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                              .toList(),
                          onChanged: (val) => setState(() => _trDestShopId = val),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Currently at destination: ${currentDestStock.toStringAsFixed(0)} units',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _trQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity to Transfer *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.swap_horiz),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Required';
                            final qty = double.tryParse(value.trim());
                            if (qty == null || qty <= 0) return 'Must be greater than 0';
                            if (qty > currentSourceStock) {
                              return 'Exceeds available stock ($currentSourceStock)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _trNotesController,
                          decoration: const InputDecoration(
                            labelText: 'Transfer Reason / Note',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submitTransfer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF167D63),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Execute Stock Transfer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
