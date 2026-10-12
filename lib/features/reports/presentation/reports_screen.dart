import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../products/data/product_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../shops/data/shop_repository.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/utils/file_downloader.dart';

import '../../../core/utils/currency_formatter.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isExportingMaster = false;
  bool _isExportingLowStock = false;
  bool _isExportingValuation = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final DateFormat _fileDateFormat = DateFormat('yyyyMMdd_HHmm');
  final NumberFormat _currencyFormat = CurrencyFormatter.inrFormat;

  String _convertToCsv(List<List<dynamic>> rows) {
    return rows.map((row) {
      return row.map((cell) {
        final str = cell?.toString() ?? '';
        if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
          return '"${str.replaceAll('"', '""')}"';
        }
        return str;
      }).join(',');
    }).join('\r\n');
  }

  Future<void> _exportMasterProductCsv() async {
    setState(() => _isExportingMaster = true);

    try {
      final products = ref.read(productRepositoryProvider).currentProducts;
      final categories = ref.read(categoryRepositoryProvider).currentCategories;
      final shops = ref.read(shopRepositoryProvider).currentShops;
      final inventory = ref.read(inventoryRepositoryProvider).currentInventory;

      final catMap = {for (var c in categories) c.id: c.name};

      List<List<dynamic>> rows = [];

      // CSV Header Row
      List<dynamic> header = [
        "Product ID",
        "Product Name",
        "SKU / Barcode",
        "Main Category",
        "Subcategory",
        "Description",
        "Unit of Measure",
        "Purchase Price (₹)",
        "Selling Price (₹)",
        "Profit Margin (₹)",
        "Margin (%)",
        "Min Stock Threshold",
        "Total Available Stock",
      ];

      // Add dynamic columns for each shop's stock
      for (final shop in shops) {
        header.add("${shop.name} Stock");
      }

      header.addAll([
        "Total Stock Valuation (₹)",
        "Stock Status",
        "Date Added",
        "Last Updated",
      ]);

      rows.add(header);

      // Data Rows
      for (final product in products) {
        final mainCategoryName = catMap[product.mainCategoryId] ?? 'Uncategorized';
        final subcategoryName = product.subcategoryId != null ? (catMap[product.subcategoryId] ?? 'None') : 'None';

        final productInventory = inventory.where((i) => i.productId == product.id).toList();
        final double totalStock = productInventory.fold(0.0, (sum, i) => sum + i.quantity);

        final purchasePrice = product.purchasePrice ?? 0.0;
        final sellingPrice = product.sellingPrice;
        final profitMargin = sellingPrice - purchasePrice;
        final marginPercent = sellingPrice > 0 ? ((profitMargin / sellingPrice) * 100).toStringAsFixed(1) : '0.0';

        String stockStatus;
        if (totalStock <= 0) {
          stockStatus = "Out of Stock";
        } else if (totalStock <= product.minimumStock) {
          stockStatus = "Low Stock Alert";
        } else {
          stockStatus = "In Stock";
        }

        final double totalValuation = totalStock * purchasePrice;

        List<dynamic> row = [
          product.id,
          product.name,
          product.sku ?? '',
          mainCategoryName,
          subcategoryName,
          product.description,
          product.unit,
          purchasePrice.toStringAsFixed(2),
          sellingPrice.toStringAsFixed(2),
          profitMargin.toStringAsFixed(2),
          "$marginPercent%",
          product.minimumStock.toStringAsFixed(0),
          totalStock.toStringAsFixed(0),
        ];

        // Add quantity for each shop
        for (final shop in shops) {
          final shopStock = productInventory.where((i) => i.shopId == shop.id).fold(0.0, (sum, i) => sum + i.quantity);
          row.add(shopStock.toStringAsFixed(0));
        }

        row.addAll([
          totalValuation.toStringAsFixed(2),
          stockStatus,
          _dateFormat.format(product.createdAt),
          _dateFormat.format(product.updatedAt),
        ]);

        rows.add(row);
      }

      final csvContent = _convertToCsv(rows);
      final fileName = 'shopsync_master_inventory_report_${_fileDateFormat.format(DateTime.now())}.csv';

      await exportCsvFile(csvContent, fileName);

      if (mounted) {
        AppToast.showSuccess(
          context,
          'Master CSV downloaded (${products.length} products included)!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingMaster = false);
      }
    }
  }

  Future<void> _exportLowStockCsv() async {
    setState(() => _isExportingLowStock = true);

    try {
      final products = ref.read(productRepositoryProvider).currentProducts;
      final categories = ref.read(categoryRepositoryProvider).currentCategories;
      final inventory = ref.read(inventoryRepositoryProvider).currentInventory;

      final catMap = {for (var c in categories) c.id: c.name};

      List<List<dynamic>> rows = [];
      rows.add([
        "Product ID",
        "Product Name",
        "SKU",
        "Category",
        "Current Stock",
        "Minimum Stock",
        "Reorder Deficit",
        "Unit",
        "Unit Cost (₹)",
        "Est. Restock Cost (₹)",
        "Stock Status",
      ]);

      int count = 0;
      for (final product in products) {
        final productInventory = inventory.where((i) => i.productId == product.id).toList();
        final double currentStock = productInventory.fold(0.0, (sum, i) => sum + i.quantity);

        if (currentStock <= product.minimumStock) {
          count++;
          final deficit = (product.minimumStock * 2) - currentStock; // Target restock
          final unitCost = product.purchasePrice ?? 0.0;
          final estCost = deficit > 0 ? deficit * unitCost : 0.0;

          rows.add([
            product.id,
            product.name,
            product.sku ?? '',
            catMap[product.mainCategoryId] ?? 'General',
            currentStock.toStringAsFixed(0),
            product.minimumStock.toStringAsFixed(0),
            deficit > 0 ? deficit.toStringAsFixed(0) : '0',
            product.unit,
            unitCost.toStringAsFixed(2),
            estCost.toStringAsFixed(2),
            currentStock <= 0 ? 'CRITICAL - OUT OF STOCK' : 'LOW STOCK REORDER',
          ]);
        }
      }

      final csvContent = _convertToCsv(rows);
      final fileName = 'shopsync_low_stock_reorder_report_${_fileDateFormat.format(DateTime.now())}.csv';

      await exportCsvFile(csvContent, fileName);

      if (mounted) {
        AppToast.showSuccess(
          context,
          'Low stock report downloaded ($count items to reorder)!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingLowStock = false);
      }
    }
  }

  Future<void> _exportValuationCsv() async {
    setState(() => _isExportingValuation = true);

    try {
      final products = ref.read(productRepositoryProvider).currentProducts;
      final shops = ref.read(shopRepositoryProvider).currentShops;
      final inventory = ref.read(inventoryRepositoryProvider).currentInventory;

      List<List<dynamic>> rows = [];
      rows.add([
        "Store ID",
        "Store Name",
        "Location Address",
        "Total SKUs Stocked",
        "Total Units Count",
        "Total Inventory Cost Value (₹)",
        "Total Retail Value (₹)",
        "Potential Gross Profit (₹)",
      ]);

      for (final shop in shops) {
        final shopInventory = inventory.where((i) => i.shopId == shop.id).toList();
        final int skus = shopInventory.where((i) => i.quantity > 0).length;
        final double totalUnits = shopInventory.fold(0.0, (sum, i) => sum + i.quantity);

        double totalCostVal = 0.0;
        double totalRetailVal = 0.0;

        for (final inv in shopInventory) {
          final prod = products.where((p) => p.id == inv.productId).firstOrNull;
          if (prod != null) {
            totalCostVal += inv.quantity * (prod.purchasePrice ?? 0.0);
            totalRetailVal += inv.quantity * prod.sellingPrice;
          }
        }

        final double profit = totalRetailVal - totalCostVal;

        rows.add([
          shop.id,
          shop.name,
          shop.address,
          skus,
          totalUnits.toStringAsFixed(0),
          totalCostVal.toStringAsFixed(2),
          totalRetailVal.toStringAsFixed(2),
          profit.toStringAsFixed(2),
        ]);
      }

      final csvContent = _convertToCsv(rows);
      final fileName = 'shopsync_store_valuation_report_${_fileDateFormat.format(DateTime.now())}.csv';

      await exportCsvFile(csvContent, fileName);

      if (mounted) {
        AppToast.showSuccess(
          context,
          'Store valuation report downloaded successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingValuation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsStreamProvider).value ?? [];
    final inventory = ref.watch(allInventoryStreamProvider).value ?? [];
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final shops = ref.watch(shopsStreamProvider).value ?? [];

    final double totalUnits = inventory.fold(0.0, (sum, i) => sum + i.quantity);

    double totalCostValuation = 0.0;
    for (final inv in inventory) {
      final p = products.where((prod) => prod.id == inv.productId).firstOrNull;
      if (p != null) {
        totalCostValuation += inv.quantity * (p.purchasePrice ?? 0.0);
      }
    }

    final lowStockCount = products.where((p) {
      final currentStock = inventory.where((i) => i.productId == p.id).fold(0.0, (sum, i) => sum + i.quantity);
      return currentStock <= p.minimumStock;
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Data Reports & CSV Export'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // 1. Hero Overview Metrics
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5356FB), Color(0xFF6C5CE7)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppTheme.primaryGlowShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory Intelligence',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Export clean CSV files with all attributes',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.table_view_rounded, color: Colors.white, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeroMetric('Catalog Items', '${products.length}'),
                    _buildHeroMetric('Total Units', '${totalUnits.toStringAsFixed(0)} pcs'),
                    _buildHeroMetric('Stock Valuation', _currencyFormat.format(totalCostValuation)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title: Available CSV Reports
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Export Data Reports',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2243),
              ),
            ),
          ),

          // Report 1: Full Product Catalog Master Report
          _buildReportCard(
            title: 'Complete Products Master Report',
            description:
                'Full export containing SKU, Main Category, Subcategory, Descriptions, Units, Cost, Price, Margin, Stock per shop, and Valuation.',
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF5356FB),
            badgeText: 'All Fields Included',
            badgeColor: const Color(0xFF5356FB),
            isDownloading: _isExportingMaster,
            onDownload: _exportMasterProductCsv,
          ),
          const SizedBox(height: 14),

          // Report 2: Low Stock & Restock Advisory
          _buildReportCard(
            title: 'Low Stock & Reorder Advisory',
            description:
                'Identifies all items at or below threshold with calculated reorder quantity and estimated restocking costs.',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF7675),
            badgeText: '$lowStockCount Items Alert',
            badgeColor: const Color(0xFFFF7675),
            isDownloading: _isExportingLowStock,
            onDownload: _exportLowStockCsv,
          ),
          const SizedBox(height: 14),

          // Report 3: Multi-Shop Valuation
          _buildReportCard(
            title: 'Store Stock Valuation Breakdown',
            description:
                'Detailed breakdown of total stock value, cost, retail value, and gross profit potential grouped by each shop location.',
            icon: Icons.storefront_rounded,
            iconColor: const Color(0xFF00B894),
            badgeText: '${shops.length} Stores Tracked',
            badgeColor: const Color(0xFF00B894),
            isDownloading: _isExportingValuation,
            onDownload: _exportValuationCsv,
          ),
          const SizedBox(height: 28),

          // Live Data Preview Section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Catalog Data Preview (Sample)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2243),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'PRODUCT & SKU',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF636A88)),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'CATEGORY',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF636A88)),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'PRICE / COST',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF636A88)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < products.take(5).length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                products[i].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF1E2243),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                products[i].sku ?? 'NO-SKU',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF8A90A6)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            categories.where((c) => c.id == products[i].mainCategoryId).firstOrNull?.name ?? 'General',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5356FB)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _currencyFormat.format(products[i].sellingPrice),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E2243)),
                              ),
                              Text(
                                'Cost: ${_currencyFormat.format(products[i].purchasePrice ?? 0)}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF8A90A6)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < products.take(5).length - 1)
                    const Divider(height: 1, color: Color(0xFFF1F3F9)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required bool isDownloading,
    required VoidCallback onDownload,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E2243),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: badgeColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF636A88),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: isDownloading ? null : onDownload,
              icon: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(
                isDownloading ? 'Generating CSV...' : 'Download CSV File',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
