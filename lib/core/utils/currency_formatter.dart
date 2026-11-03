import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactIdrFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  static String format(num? value) {
    if (value == null) return 'Rp 0';
    return _idrFormatter.format(value);
  }

  static String formatCompact(num? value) {
    if (value == null) return 'Rp 0';
    return _compactIdrFormatter.format(value);
  }

  static double parse(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}

