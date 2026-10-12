import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/products/presentation/product_list_screen.dart';
import '../../features/products/presentation/add_product_screen.dart';
import '../../features/shops/presentation/shop_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

// Global Riverpod providers for seamless app-wide navigation flow
class AppNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  @override
  set state(int value) => super.state = value;
}

final appNavIndexProvider = NotifierProvider<AppNavIndexNotifier, int>(AppNavIndexNotifier.new);

class ProductStockFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';
  @override
  set state(String value) => super.state = value;
}

final productStockFilterProvider =
    NotifierProvider<ProductStockFilterNotifier, String>(ProductStockFilterNotifier.new);

class SelectedCategoryNavigationNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  @override
  set state(String? value) => super.state = value;
}

final selectedCategoryNavigationProvider =
    NotifierProvider<SelectedCategoryNavigationNotifier, String?>(
  SelectedCategoryNavigationNotifier.new,
);

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductListScreen(),
    const AddProductScreen(),
    const ShopListScreen(),
    const SettingsScreen(),
  ];

  final List<_NavTabItem> _navItems = const [
    _NavTabItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavTabItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Products'),
    _NavTabItem(icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, label: 'Add Item'),
    _NavTabItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: 'Shops'),
    _NavTabItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(appNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF50558F).withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = currentIndex == index;

              return Flexible(
                fit: isSelected ? FlexFit.loose : FlexFit.tight,
                child: GestureDetector(
                  onTap: () => ref.read(appNavIndexProvider.notifier).state = index,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 12 : 6,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5356FB).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? const Color(0xFF5356FB)
                              : const Color(0xFFA5ABC0),
                          size: 22,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF5356FB),
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
