import 'package:drift/drift.dart';

// 1. Businesses Table
class Businesses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get slug => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Jakarta'))();
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  TextColumn get logoUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Branches Table
@DataClassName('Branch')
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isMain => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 3. Users / Profiles Table
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get email => text().withLength(min: 1, max: 255)();
  TextColumn get fullName => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('cashier'))(); // owner, admin, cashier
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 4. Categories Table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  TextColumn get color => text().withDefault(const Constant('#2D6A4F'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Products Table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get sku => text().withLength(min: 1, max: 100)();
  TextColumn get barcode => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get buyPrice => real().withDefault(const Constant(0.0))();
  RealColumn get sellPrice => real().withDefault(const Constant(0.0))();
  RealColumn get currentStock => real().withDefault(const Constant(0.0))();
  RealColumn get minStock => real().withDefault(const Constant(5.0))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 6. Customers Table
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get totalSpend => real().withDefault(const Constant(0.0))();
  RealColumn get activeDebt => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 7. Suppliers Table
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get totalPurchased => real().withDefault(const Constant(0.0))();
  RealColumn get activePayable => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 8. Transactions Table
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get branchId => text()();
  TextColumn get cashierId => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get invoiceNumber => text()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get discountPercent => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))();
  RealColumn get cashReceived => real().withDefault(const Constant(0.0))();
  RealColumn get changeAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 9. TransactionItems Table
class TransactionItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get buyPrice => real().withDefault(const Constant(0.0))();
  RealColumn get sellPrice => real().withDefault(const Constant(0.0))();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get subtotalAmount => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 10. Payments Table
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 11. StockMovements Table
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get branchId => text()();
  TextColumn get productId => text()();
  TextColumn get movementType => text()(); // PURCHASE, SALE, SALE_RETURN, PURCHASE_RETURN, ADJUSTMENT, STOCK_OPNAME
  RealColumn get previousStock => real()();
  RealColumn get quantityChanged => real()();
  RealColumn get remainingStock => real()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 12. StockOpnames Table
class StockOpnames extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get branchId => text()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get opnameDate => dateTime().withDefault(currentDateAndTime)();
  IntColumn get totalDiscrepancyItems => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 13. StockOpnameItems Table
class StockOpnameItems extends Table {
  TextColumn get id => text()();
  TextColumn get stockOpnameId => text()();
  TextColumn get productId => text()();
  RealColumn get systemStock => real()();
  RealColumn get physicalStock => real()();
  RealColumn get difference => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 14. Debts Table (Customer Hutang)
class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get customerId => text()();
  TextColumn get transactionId => text().nullable()();
  TextColumn get invoiceNumber => text()();
  RealColumn get totalDebt => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  RealColumn get remainingDebt => real()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('UNPAID'))(); // UNPAID, PARTIAL, PAID, OVERDUE
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 15. DebtPayments Table
class DebtPayments extends Table {
  TextColumn get id => text()();
  TextColumn get debtId => text()();
  RealColumn get amount => real()();
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))();
  DateTimeColumn get paymentDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 16. Receivables Table (Hutang ke Supplier)
class Receivables extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get supplierId => text()();
  TextColumn get purchaseReference => text()();
  RealColumn get totalBill => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  RealColumn get remainingBill => real()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('UNPAID'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 17. ReceivablePayments Table
class ReceivablePayments extends Table {
  TextColumn get id => text()();
  TextColumn get receivableId => text()();
  RealColumn get amount => real()();
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))();
  DateTimeColumn get paymentDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 18. Expenses Table
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get category => text()(); // RENT, ELECTRICITY, WATER, SALARY, TRANSPORT, OPERATIONAL, MAINTENANCE, OTHER
  RealColumn get amount => real()();
  DateTimeColumn get expenseDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get description => text()();
  TextColumn get receiptUrl => text().nullable()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 19. Printers Table
class Printers extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get macAddress => text().nullable()();
  TextColumn get paperSize => text().withDefault(const Constant('58mm'))(); // 58mm, 80mm
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isConnected => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 20. Notifications Table
@DataClassName('AppNotification')
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get type => text().withDefault(const Constant('SYSTEM'))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 21. AuditLogs Table
class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get targetEntity => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get oldValues => text().nullable()();
  TextColumn get newValues => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 22. SyncQueue Table (Offline-First Synchronization)
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get action => text()(); // INSERT, UPDATE, DELETE, POS_CHECKOUT
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // PENDING, SYNCING, SYNCED, FAILED
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

