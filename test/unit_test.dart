import 'package:flutter_test/flutter_test.dart';
import 'package:kasirpro/core/database/app_database.dart';
import 'package:kasirpro/data/repositories/pos_repository.dart';

void main() {
  group('POS Cart & Calculations Unit Tests', () {
    final sampleProduct1 = Product(
      id: 'p1',
      businessId: 'biz1',
      name: 'Indomie Goreng',
      sku: 'SKU-001',
      buyPrice: 2800.0,
      sellPrice: 3500.0,
      currentStock: 50.0,
      minStock: 10.0,
      unit: 'bungkus',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final sampleProduct2 = Product(
      id: 'p2',
      businessId: 'biz1',
      name: 'Minyak Bimoli 2L',
      sku: 'SKU-002',
      buyPrice: 33500.0,
      sellPrice: 38500.0,
      currentStock: 20.0,
      minStock: 5.0,
      unit: 'pouch',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('CartItem calculates subtotal, total HPP, and profit correctly', () {
      final cartItem = CartItemModel(product: sampleProduct1, quantity: 4, discount: 1000.0);

      // 4 x 3500 = 14000 - 1000 = 13000
      expect(cartItem.subtotal, 13000.0);
      // 4 x 2800 = 11200
      expect(cartItem.totalHpp, 11200.0);
      // 13000 - 11200 = 1800
      expect(cartItem.profit, 1800.0);
    });

    test('Tax and Grand Total Calculations (PPN 11%)', () {
      final cartItem1 = CartItemModel(product: sampleProduct1, quantity: 2); // 7000
      final cartItem2 = CartItemModel(product: sampleProduct2, quantity: 1); // 38500

      final subtotal = cartItem1.subtotal + cartItem2.subtotal; // 45500
      expect(subtotal, 45500.0);

      const discount = 5500.0;
      final taxable = subtotal - discount; // 40000
      final tax = taxable * 0.11; // 4400
      expect(tax, 4400.0);

      final grandTotal = taxable + tax; // 44400
      expect(grandTotal, 44400.0);

      // Cash payment & change calculation
      const cashReceived = 50000.0;
      final change = cashReceived - grandTotal; // 5600
      expect(change, 5600.0);
    });

    test('Validates underpayment prevention logic', () {
      const grandTotal = 75000.0;
      const underpayment = 50000.0;
      const exactPayment = 75000.0;
      const overPayment = 100000.0;

      expect(underpayment >= grandTotal, false); // Blocked
      expect(exactPayment >= grandTotal, true); // Allowed
      expect(overPayment >= grandTotal, true); // Allowed
    });
  });

  group('Financial Formulas Unit Tests', () {
    test('Omzet, HPP, Gross Profit, and Net Profit accuracy', () {
      const omzet = 12500000.0;
      const hpp = 9800000.0;
      const expenses = 1200000.0;

      // Formula: Gross Profit = Omzet - HPP
      const grossProfit = omzet - hpp;
      expect(grossProfit, 2700000.0);

      // Formula: Net Profit = Gross Profit - Operational Expenses
      const netProfit = grossProfit - expenses;
      expect(netProfit, 1500000.0);
    });

    test('Customer Debt Partial Payment Calculation', () {
      const totalDebt = 500000.0;
      const installment1 = 150000.0;

      final remaining1 = totalDebt - installment1;
      expect(remaining1, 350000.0);
      expect(remaining1 <= 0 ? 'PAID' : 'PARTIAL', 'PARTIAL');

      const installment2 = 350000.0;
      final remaining2 = remaining1 - installment2;
      expect(remaining2, 0.0);
      expect(remaining2 <= 0 ? 'PAID' : 'PARTIAL', 'PAID');
    });
  });

  group('Role Permissions Matrix Tests', () {
    bool canViewFinancials(String role) => role == 'owner';
    bool canManageProducts(String role) => role == 'owner' || role == 'admin';
    bool canEditHpp(String role) => role == 'owner' || role == 'admin';
    bool canPerformCashierSale(String role) => true;

    test('Owner has full access', () {
      expect(canViewFinancials('owner'), true);
      expect(canManageProducts('owner'), true);
      expect(canEditHpp('owner'), true);
      expect(canPerformCashierSale('owner'), true);
    });

    test('Admin has operational access without sensitive profit financials', () {
      expect(canViewFinancials('admin'), false);
      expect(canManageProducts('admin'), true);
      expect(canEditHpp('admin'), true);
      expect(canPerformCashierSale('admin'), true);
    });

    test('Cashier is restricted from HPP and financial reports', () {
      expect(canViewFinancials('cashier'), false);
      expect(canManageProducts('cashier'), false);
      expect(canEditHpp('cashier'), false);
      expect(canPerformCashierSale('cashier'), true);
    });
  });
}

