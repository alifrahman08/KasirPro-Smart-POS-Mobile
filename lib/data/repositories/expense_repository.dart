import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class ExpenseRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  ExpenseRepository({required this.db, required this.syncService});

  Stream<List<Expense>> watchExpenses(String businessId) {
    return (db.select(db.expenses)
          ..where((tbl) => tbl.businessId.equals(businessId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.expenseDate)]))
        .watch();
  }

  Future<List<Expense>> getExpenses({
    required String businessId,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    final query = db.select(db.expenses)..where((tbl) => tbl.businessId.equals(businessId));

    if (category != null && category != 'ALL') {
      query.where((tbl) => tbl.category.equals(category));
    }

    if (startDate != null && endDate != null) {
      query.where((tbl) => tbl.expenseDate.isBiggerOrEqualValue(startDate) & tbl.expenseDate.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.expenseDate)]);
    return query.get();
  }

  Future<void> addExpense({
    required String businessId,
    String? branchId,
    required String category,
    required double amount,
    required DateTime date,
    required String description,
    String? receiptUrl,
    String? userId,
  }) async {
    final id = _uuid.v4();
    await db.into(db.expenses).insert(
          ExpensesCompanion.insert(
            id: id,
            businessId: businessId,
            branchId: Value(branchId),
            category: category,
            amount: amount,
            expenseDate: Value(date),
            description: description,
            receiptUrl: Value(receiptUrl),
            userId: Value(userId),
          ),
        );

    await syncService.enqueueMutation(
      action: 'INSERT',
      tableName: 'expenses',
      recordId: id,
      payloadJson: '{"id": "$id", "amount": $amount, "category": "$category"}',
    );
  }

  Future<void> deleteExpense(String id) async {
    await (db.delete(db.expenses)..where((tbl) => tbl.id.equals(id))).go();
    await syncService.enqueueMutation(
      action: 'DELETE',
      tableName: 'expenses',
      recordId: id,
      payloadJson: '{"id": "$id"}',
    );
  }
}

