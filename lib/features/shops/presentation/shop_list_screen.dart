import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/shop_repository.dart';
import '../domain/shop.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../inventory/presentation/stock_adjustment_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';

class ShopListScreen extends ConsumerWidget {
  const ShopListScreen({super.key});

  void _showAddOrEditShopDialog(BuildContext context, WidgetRef ref, [Shop? shopToEdit]) {
    final isEditing = shopToEdit != null;
    final nameController = TextEditingController(text: shopToEdit?.name ?? '');
    final addressController = TextEditingController(text: shopToEdit?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: Text(
          isEditing ? 'Edit Store' : 'Add New Store',
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E2243)),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Store Name *',
                  prefixIcon: const Icon(Icons.storefront_rounded, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address *',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                maxLines: 2,
                validator: (val) => val == null || val.trim().isEmpty ? 'Address is required' : null,
              ),
            ],
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
              if (!formKey.currentState!.validate()) return;
              final repo = ref.read(shopRepositoryProvider);

              if (isEditing) {
                await repo.updateShop(
                  shopToEdit.copyWith(
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    updatedAt: DateTime.now(),
                  ),
                );
                if (ctx.mounted) {
                  AppToast.showSuccess(context, 'Shop updated successfully');
                }
              } else {
                await repo.addShop(
                  Shop(
                    id: '',
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                if (ctx.mounted) {
                  AppToast.showSuccess(context, 'Shop added successfully');
                }
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(isEditing ? 'Save Changes' : 'Create Store'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShop(BuildContext context, WidgetRef ref, Shop shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('Delete Store', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete "${shop.name}"?'),
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
              await ref.read(shopRepositoryProvider).deleteShop(shop.id);
              if (context.mounted) {
                AppToast.showInfo(context, 'Shop "${shop.name}" removed');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsyncValue = ref.watch(shopsStreamProvider);
    final inventoryAsync = ref.watch(allInventoryStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Stores & Locations'),
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
              onPressed: () => _showAddOrEditShopDialog(context, ref),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_new_shop',
        backgroundColor: AppTheme.primaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _showAddOrEditShopDialog(context, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: shopsAsyncValue.when(
        data: (shops) {
          if (shops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 54, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No stores found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E2243)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddOrEditShopDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first store'),
                  ),
                ],
              ),
            );
          }

          final inventoryList = inventoryAsync.value ?? [];

          return ListView.separated(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 90),
            itemCount: shops.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final shop = shops[index];
              final shopInventory = inventoryList.where((i) => i.shopId == shop.id).toList();
              final totalUnits = shopInventory.fold(0.0, (sum, i) => sum + i.quantity);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5356FB), Color(0xFF6C5CE7)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF1E2243),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8A90A6)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        shop.address,
                                        style: const TextStyle(color: Color(0xFF8A90A6), fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  '${shopInventory.length} Products in stock',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E2243),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${totalUnits.toStringAsFixed(0)} units total',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              foregroundColor: AppTheme.primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 16),
                            label: const Text('Adjust Stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => StockAdjustmentScreen(initialShopId: shop.id)),
                              );
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF7A809B), size: 20),
                                tooltip: 'Edit Store',
                                onPressed: () => _showAddOrEditShopDialog(context, ref, shop),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7675), size: 20),
                                tooltip: 'Delete Store',
                                onPressed: () => _confirmDeleteShop(context, ref, shop),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
