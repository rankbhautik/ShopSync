import 'dart:async';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

enum AppToastType { success, error, info, warning }

class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void showSuccess(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppToastType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppToastType.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppToastType.info,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppToastType.warning,
      duration: duration,
    );
  }

  static void show(
    BuildContext? context, {
    required String message,
    String? title,
    AppToastType type = AppToastType.success,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    // Find suitable OverlayState
    OverlayState? overlay;
    if (context != null && context.mounted) {
      overlay = Overlay.maybeOf(context, rootOverlay: true);
    }
    overlay ??= rootNavigatorKey.currentState?.overlay;

    if (overlay == null) return;

    // Dismiss existing toast if active
    dismiss();

    late final OverlayEntry entry;
    final animKey = GlobalKey<_TopToastBannerState>();

    entry = OverlayEntry(
      builder: (ctx) => _TopToastBanner(
        key: animKey,
        title: title,
        message: message,
        type: type,
        onDismiss: () {
          dismiss();
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, () {
      if (_currentEntry == entry) {
        animKey.currentState?.animateOut().then((_) {
          if (_currentEntry == entry) {
            dismiss();
          }
        });
      }
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _TopToastBanner extends StatefulWidget {
  final String? title;
  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;

  const _TopToastBanner({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_TopToastBanner> createState() => _TopToastBannerState();
}

class _TopToastBannerState extends State<_TopToastBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  Future<void> animateOut() async {
    if (mounted) {
      await _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top > 0 ? media.padding.top : 24.0;

    Color startColor;
    Color endColor;
    Color shadowColor;
    IconData icon;

    switch (widget.type) {
      case AppToastType.success:
        startColor = const Color(0xFF00B894);
        endColor = const Color(0xFF00A382);
        shadowColor = const Color(0xFF00B894);
        icon = Icons.check_circle_rounded;
        break;
      case AppToastType.error:
        startColor = const Color(0xFFFF7675);
        endColor = const Color(0xFFD63031);
        shadowColor = const Color(0xFFFF7675);
        icon = Icons.error_outline_rounded;
        break;
      case AppToastType.warning:
        startColor = const Color(0xFFF39C12);
        endColor = const Color(0xFFE67E22);
        shadowColor = const Color(0xFFE67E22);
        icon = Icons.warning_amber_rounded;
        break;
      case AppToastType.info:
        startColor = const Color(0xFF5356FB);
        endColor = const Color(0xFF3D40D8);
        shadowColor = const Color(0xFF5356FB);
        icon = Icons.info_outline_rounded;
        break;
    }

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dismissible(
              key: const Key('top_toast_dismissible'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismiss(),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.38),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null && widget.title!.isNotEmpty) ...[
                            Text(
                              widget.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        await animateOut();
                        widget.onDismiss();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
