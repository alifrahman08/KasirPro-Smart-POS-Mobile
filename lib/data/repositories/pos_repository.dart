import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class CartItemModel {
  final Product product;
  int quantity;
  double discount;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.discount = 0.0,
  });

  double get unitPrice => product.sellPrice;
  double get subtotal => (unitPrice * quantity) - discount;
  double get totalHpp => product.buyPrice * quantity;
  double get profit => subtotal - totalHpp;
}

class CheckoutResult {
  final Transaction transaction;
  final List<TransactionItem> items;

  CheckoutResult({required this.transaction, required this.items});
}

class PosRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();
  bool _isProcessingCheckout = false;

  PosRepository({required this.db, required this.syncService});

  Future<String> generateNextInvoiceNumber(String businessId) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final prefix = 'INV-$dateStr-';

    final count = await (db.select(db.transactions)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.invoiceNumber.like('$prefix%')))
        .get();

    final nextIndex = (count.length + 1).toString().padLeft(4, '0');
    return '$prefix$nextIndex';
  }

  Future<CheckoutResult> processTransaction({
    required String businessId,
    required String branchId,
    required String cashierId,
    String? customerId,
    required List<CartItemModel> cartItems,
    required double subtotal,
    required double discountAmount,
    required double discountPercent,
    required double taxAmount,
    required double totalAmount,
    required String paymentMethod,
    required double cashReceived,
    required double changeAmount,
    String? notes,
  }) async {
    if (_isProcessingCheckout) {
      throw Exception('Transaksi sedang diproses. Mohon tunggu...');
    }

    _isProcessingCheckout = true;

    try {
      final txId = _uuid.v4();
      final invoiceNumber = await generateNextInvoiceNumber(businessId);
      final createdItems = <TransactionItem>[];

      await db.transaction(() async {
        // 1. Insert Transaction Header
        final txCompanion = TransactionsCompanion.insert(
          id: txId,
          businessId: businessId,
          branchId: branchId,
          cashierId: cashierId,
          customerId: Value(customerId),
          invoiceNumber: invoiceNumber,
          subtotal: Value(subtotal),
          discountAmount: Value(discountAmount),
          discountPercent: Value(discountPercent),
          taxAmount: Value(taxAmount),
          totalAmount: Value(totalAmount),
          paymentMethod: Value(paymentMethod),
          cashReceived: Value(cashReceived),
          changeAmount: Value(changeAmount),
          status: const Value('COMPLETED'),
          notes: Value(notes),
        );
        await db.into(db.transactions).insert(txCompanion);

        // 2. Process each cart item
        for (final cartItem in cartItems) {
          final itemId = _uuid.v4();

          // Fetch fresh product for current stock
          final product = await (db.select(db.products)..where((tbl) => tbl.id.equals(cartItem.product.id))).getSingle();

          final prevStock = product.currentStock;
          final newStock = prevStock - cartItem.quantity;

          // Update stock
          await (db.update(db.products)..where((tbl) => tbl.id.equals(product.id))).write(
            ProductsCompanion(
              currentStock: Value(newStock),
              updatedAt: Value(DateTime.now()),
            ),
          );

          // Insert Transaction Item
          final itemCompanion = TransactionItemsCompanion.insert(
            id: itemId,
            transactionId: txId,
            productId: product.id,
            productName: product.name,
            sku: Value(product.sku),
            barcode: Value(product.barcode),
            buyPrice: Value(product.buyPrice),
            sellPrice: Value(product.sellPrice),
            quantity: Value(cartItem.quantity.toDouble()),
            discountAmount: Value(cartItem.discount),
            subtotalAmount: Value(cartItem.subtotal),
          );
          await db.into(db.transactionItems).insert(itemCompanion);

          createdItems.add(
            TransactionItem(
              id: itemId,
              transactionId: txId,
              productId: product.id,
              productName: product.name,
              sku: product.sku,
              barcode: product.barcode,
              buyPrice: product.buyPrice,
              sellPrice: product.sellPrice,
              quantity: cartItem.quantity.toDouble(),
              discountAmount: cartItem.discount,
              subtotalAmount: cartItem.subtotal,
              createdAt: DateTime.now(),
            ),
          );

          // Record Stock Movement Audit
          await db.into(db.stockMovements).insert(
                StockMovementsCompanion.insert(
                  id: _uuid.v4(),
                  businessId: businessId,
                  branchId: branchId,
                  productId: product.id,
                  movementType: 'SALE',
                  previousStock: prevStock,
                  quantityChanged: -cartItem.quantity.toDouble(),
                  remainingStock: newStock,
                  referenceId: Value(invoiceNumber),
                  userId: Value(cashierId),
                  notes: const Value('Penjualan Kasir POS'),
                ),
              );
        }

        // 3. Payment record
        await db.into(db.payments).insert(
              PaymentsCompanion.insert(
                id: _uuid.v4(),
                transactionId: txId,
                paymentMethod: Value(paymentMethod),
                amount: Value(totalAmount),
              ),
            );

        // 4. Update Customer spend if attached
        if (customerId != null && customerId.isNotEmpty) {
          final cust = await (db.select(db.customers)..where((tbl) => tbl.id.equals(customerId))).getSingleOrNull();
          if (cust != null) {
            await (db.update(db.customers)..where((tbl) => tbl.id.equals(customerId))).write(
              CustomersCompanion(
                totalSpend: Value(cust.totalSpend + totalAmount),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }
      });

      final createdTx = await (db.select(db.transactions)..where((tbl) => tbl.id.equals(txId))).getSingle();

      // Enqueue sync mutation
      await syncService.enqueueMutation(
        action: 'POS_CHECKOUT',
        tableName: 'transactions',
        recordId: txId,
        payloadJson: jsonEncode({
          'transaction_id': txId,
          'invoice_number': invoiceNumber,
          'total_amount': totalAmount,
          'payment_method': paymentMethod,
        }),
      );

      return CheckoutResult(transaction: createdTx, items: createdItems);
    } finally {
      _isProcessingCheckout = false;
    }
  }

  Future<List<Transaction>> getRecentTransactions({
    required String businessId,
    String? cashierId,
    int limit = 50,
  }) async {
    final query = db.select(db.transactions)..where((tbl) => tbl.businessId.equals(businessId));

    if (cashierId != null) {
      query.where((tbl) => tbl.cashierId.equals(cashierId));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    query.limit(limit);

    return query.get();
  }

  Future<List<TransactionItem>> getTransactionItems(String transactionId) async {
    return (db.select(db.transactionItems)..where((tbl) => tbl.transactionId.equals(transactionId))).get();
  }
}

