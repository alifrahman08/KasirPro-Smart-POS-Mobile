import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class DebtRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  DebtRepository({required this.db, required this.syncService});

  // Customer Debts
  Stream<List<Debt>> watchDebts(String businessId, {String? status}) {
    final query = db.select(db.debts)..where((tbl) => tbl.businessId.equals(businessId));
    if (status != null && status != 'ALL') {
      query.where((tbl) => tbl.status.equals(status));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]);
    return query.watch();
  }

  Future<List<Debt>> getDebts(String businessId, {String? status}) async {
    final query = db.select(db.debts)..where((tbl) => tbl.businessId.equals(businessId));
    if (status != null && status != 'ALL') {
      query.where((tbl) => tbl.status.equals(status));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]);
    return query.get();
  }

  Future<void> addDebtPayment({
    required String debtId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    await db.transaction(() async {
      final debt = await (db.select(db.debts)..where((tbl) => tbl.id.equals(debtId))).getSingle();

      final newPaid = debt.paidAmount + amount;
      final newRemaining = debt.totalDebt - newPaid;
      final newStatus = newRemaining <= 0 ? 'PAID' : 'PARTIAL';

      // 1. Record payment
      await db.into(db.debtPayments).insert(
            DebtPaymentsCompanion.insert(
              id: _uuid.v4(),
              debtId: debtId,
              amount: amount,
              paymentMethod: Value(paymentMethod),
              notes: Value(notes),
            ),
          );

      // 2. Update Debt
      await (db.update(db.debts)..where((tbl) => tbl.id.equals(debtId))).write(
        DebtsCompanion(
          paidAmount: Value(newPaid),
          remainingDebt: Value(newRemaining > 0 ? newRemaining : 0.0),
          status: Value(newStatus),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // 3. Update Customer active debt
      final customer = await (db.select(db.customers)..where((tbl) => tbl.id.equals(debt.customerId))).getSingleOrNull();
      if (customer != null) {
        final updatedDebt = customer.activeDebt - amount;
        await (db.update(db.customers)..where((tbl) => tbl.id.equals(customer.id))).write(
          CustomersCompanion(
            activeDebt: Value(updatedDebt > 0 ? updatedDebt : 0.0),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });

    await syncService.enqueueMutation(
      action: 'DEBT_PAYMENT',
      tableName: 'debt_payments',
      recordId: debtId,
      payloadJson: '{"debt_id": "$debtId", "amount": $amount}',
    );
  }

  // Supplier Receivables
  Stream<List<Receivable>> watchReceivables(String businessId, {String? status}) {
    final query = db.select(db.receivables)..where((tbl) => tbl.businessId.equals(businessId));
    if (status != null && status != 'ALL') {
      query.where((tbl) => tbl.status.equals(status));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]);
    return query.watch();
  }

  Future<List<Receivable>> getReceivables(String businessId, {String? status}) async {
    final query = db.select(db.receivables)..where((tbl) => tbl.businessId.equals(businessId));
    if (status != null && status != 'ALL') {
      query.where((tbl) => tbl.status.equals(status));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]);
    return query.get();
  }

  Future<void> addReceivablePayment({
    required String receivableId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    await db.transaction(() async {
      final rec = await (db.select(db.receivables)..where((tbl) => tbl.id.equals(receivableId))).getSingle();

      final newPaid = rec.paidAmount + amount;
      final newRemaining = rec.totalBill - newPaid;
      final newStatus = newRemaining <= 0 ? 'PAID' : 'PARTIAL';

      await db.into(db.receivablePayments).insert(
            ReceivablePaymentsCompanion.insert(
              id: _uuid.v4(),
              receivableId: receivableId,
              amount: amount,
              paymentMethod: Value(paymentMethod),
              notes: Value(notes),
            ),
          );

      await (db.update(db.receivables)..where((tbl) => tbl.id.equals(receivableId))).write(
        ReceivablesCompanion(
          paidAmount: Value(newPaid),
          remainingBill: Value(newRemaining > 0 ? newRemaining : 0.0),
          status: Value(newStatus),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final supplier = await (db.select(db.suppliers)..where((tbl) => tbl.id.equals(rec.supplierId))).getSingleOrNull();
      if (supplier != null) {
        final updatedPayable = supplier.activePayable - amount;
        await (db.update(db.suppliers)..where((tbl) => tbl.id.equals(supplier.id))).write(
          SuppliersCompanion(
            activePayable: Value(updatedPayable > 0 ? updatedPayable : 0.0),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });

    await syncService.enqueueMutation(
      action: 'RECEIVABLE_PAYMENT',
      tableName: 'receivable_payments',
      recordId: receivableId,
      payloadJson: '{"receivable_id": "$receivableId", "amount": $amount}',
    );
  }
}

