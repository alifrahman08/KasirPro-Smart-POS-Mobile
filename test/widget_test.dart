import 'package:flutter_test/flutter_test.dart';
import 'package:kasirpro/app/constants/app_constants.dart';
import 'package:kasirpro/core/utils/currency_formatter.dart';

void main() {
  test('App Constants and Currency Formatter Widget Verification', () {
    expect(AppConstants.appName, 'KasirPro');
    expect(AppConstants.defaultTaxRate, 11.0);

    expect(CurrencyFormatter.format(150000), 'Rp 150.000');
    expect(CurrencyFormatter.format(0), 'Rp 0');
    expect(CurrencyFormatter.parse('Rp 25.500'), 25500.0);
  });
}
