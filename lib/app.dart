import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/router.dart';

class ShopSyncApp extends ConsumerWidget {
  const ShopSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ShopSync',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Consistent clean vibrant light mode
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
