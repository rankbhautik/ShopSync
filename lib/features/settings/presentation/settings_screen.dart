import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../shops/data/shop_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../products/data/product_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/main_navigation_screen.dart';

class LowStockNotificationNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  @override
  set state(bool value) => super.state = value;
}

final lowStockNotificationProvider =
    NotifierProvider<LowStockNotificationNotifier, bool>(LowStockNotificationNotifier.new);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final shopsCount = ref.watch(shopsStreamProvider).value?.length ?? 0;
    final productsCount = ref.watch(productsStreamProvider).value?.length ?? 0;
    final categoriesCount = ref.watch(categoriesStreamProvider).value?.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // 1. User Profile Hero Card (Tappable to manage profile)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            child: InkWell(
              onTap: () => context.push('/profile'),
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5356FB), Color(0xFF6C5CE7)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: AppTheme.primaryGlowShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user != null && user.displayName.isNotEmpty
                              ? (user.displayName.split(' ').length >= 2
                                  ? '${user.displayName.split(' ')[0][0]}${user.displayName.split(' ')[1][0]}'.toUpperCase()
                                  : user.displayName.substring(0, 2).toUpperCase())
                              : 'SM',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5356FB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user != null ? user.displayName : 'Store Manager',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user != null ? user.email : 'asd@gmail.com',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user != null ? user.role : 'Full Administrator',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Manage >',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
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
          const SizedBox(height: 20),

          // 2. System Overview Stats Card with Direct Tap Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  label: 'Stores',
                  value: '$shopsCount',
                  icon: Icons.storefront_rounded,
                  color: const Color(0xFF0984E3),
                  onTap: () => ref.read(appNavIndexProvider.notifier).state = 3,
                ),
                _buildStatDivider(),
                _buildMiniStat(
                  label: 'Categories',
                  value: '$categoriesCount',
                  icon: Icons.category_rounded,
                  color: const Color(0xFF00B894),
                  onTap: () => context.push('/categories'),
                ),
                _buildStatDivider(),
                _buildMiniStat(
                  label: 'Products',
                  value: '$productsCount',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF5356FB),
                  onTap: () => ref.read(appNavIndexProvider.notifier).state = 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title: Store Management
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Store Configuration',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2243),
              ),
            ),
          ),

          // Settings Items Group 1
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF5356FB),
                  title: 'User Profile & Account Info',
                  subtitle: 'Name, phone number, primary store & security',
                  onTap: () => context.push('/profile'),
                ),
                _buildDivider(),
                _buildSettingTile(
                  context,
                  icon: Icons.store_mall_directory_rounded,
                  iconColor: const Color(0xFF0984E3),
                  title: 'Shop Preferences & Locations',
                  subtitle: 'Manage default store locations and warehouse sync',
                  onTap: () => ref.read(appNavIndexProvider.notifier).state = 3,
                ),
                _buildDivider(),
                _buildSettingTile(
                  context,
                  icon: Icons.category_rounded,
                  iconColor: const Color(0xFF00B894),
                  title: 'Category Hierarchy',
                  subtitle: 'Manage main categories and subcategories',
                  onTap: () => context.push('/categories'),
                ),
                _buildDivider(),
                _buildSettingTile(
                  context,
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFFE17055),
                  title: 'Data & CSV Reports Export',
                  subtitle: 'Download inventory reports and product spreadsheets',
                  onTap: () => context.push('/reports'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title: System & Preferences
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Application Preferences',
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.palette_rounded,
                  iconColor: const Color(0xFF6C5CE7),
                  title: 'Theme & Aesthetics',
                  subtitle: 'Vibrant Light Mode with Soft Shadows (Active)',
                  onTap: () {
                    AppToast.showInfo(context, 'ShopSync Vibrant Theme is currently active');
                  },
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5356FB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Light Theme',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5356FB)),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildSettingTile(
                  context,
                  icon: Icons.notifications_none_rounded,
                  iconColor: const Color(0xFFFD79A8),
                  title: 'Low Stock Alerts',
                  subtitle: 'Instant alerts when shop quantities fall below minimum',
                  trailing: Switch(
                    value: ref.watch(lowStockNotificationProvider),
                    activeThumbColor: const Color(0xFF5356FB),
                    activeTrackColor: const Color(0xFF5356FB).withValues(alpha: 0.3),
                    onChanged: (val) {
                      ref.read(lowStockNotificationProvider.notifier).state = val;
                      AppToast.showSuccess(
                        context,
                        val ? 'Low stock notifications enabled' : 'Low stock notifications silenced',
                      );
                    },
                  ),
                ),
                _buildDivider(),
                _buildSettingTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF7A809B),
                  title: 'About ShopSync Prototype',
                  subtitle: 'Version 1.0.0 (Clean Architecture & Riverpod)',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'ShopSync Multi-Store Manager',
                      applicationVersion: '1.0.0 Final Prototype',
                      applicationIcon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF5356FB), Color(0xFF6C5CE7)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                      ),
                      children: const [
                        SizedBox(height: 12),
                        Text('ShopSync is an enterprise-grade multi-location inventory and retail catalog management prototype with realtime Riverpod state, Indian Rupee (₹) financial metrics, and CSV reporting.'),
                      ],
                    );
                  },
                  trailing: const Text(
                    'v1.0',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8A90A6)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.softShadow,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7675).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFFF7675), size: 22),
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Color(0xFFFF7675),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'End session and return to Login Screen',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A90A6)),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFFFF7675)),
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2243),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A90A6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE8EAF3),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2243),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF636A88)),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Color(0xFFA5ABC0), size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, color: Color(0xFFF0F2F8)),
    );
  }
}
