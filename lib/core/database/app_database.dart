import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Businesses,
  Branches,
  Users,
  Categories,
  Products,
  Customers,
  Suppliers,
  Transactions,
  TransactionItems,
  Payments,
  StockMovements,
  StockOpnames,
  StockOpnameItems,
  Debts,
  DebtPayments,
  Receivables,
  ReceivablePayments,
  Expenses,
  Printers,
  Notifications,
  AuditLogs,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'kasirpro_db',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 1;
}

