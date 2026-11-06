import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String formatCurrency(num amount, {bool showDecimals = false}) {
    if (showDecimals || amount % 1 != 0) {
      return _currencyFormatWithDecimals.format(amount);
    }
    return _currencyFormat.format(amount);
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    }
    return phone;
  }
}
