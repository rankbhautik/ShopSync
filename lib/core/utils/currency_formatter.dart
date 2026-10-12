import 'package:intl/intl.dart';

/// Centralized Indian Rupee (INR) currency formatting utility for ShopSync.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const String symbol = '₹';
  static const String currencyCode = 'INR';

  /// Standard Indian Rupee formatter (e.g. ₹1,499.00 or ₹1,20,000.00)
  static final NumberFormat inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Compact Indian Rupee formatter (e.g. ₹1.5K, ₹1.2L)
  static final NumberFormat inrCompact = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );

  /// Formats amount in INR with standard 2 decimal places: e.g. ₹1,499.00
  static String format(num? amount) {
    if (amount == null) return '₹0.00';
    return inrFormat.format(amount);
  }

  /// Formats amount in INR with compact format
  static String formatCompact(num? amount) {
    if (amount == null) return '₹0';
    return inrCompact.format(amount);
  }
}
