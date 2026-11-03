import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class EmployeeRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  EmployeeRepository({required this.db, required this.syncService});

  Stream<List<User>> watchEmployees(String businessId) {
    return (db.select(db.users)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fullName)]))
        .watch();
  }

  Future<List<User>> getEmployees(String businessId) async {
    return (db.select(db.users)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fullName)]))
        .get();
  }

  Future<void> addEmployee({
    required String businessId,
    required String fullName,
    required String email,
    String? phone,
    required String role, // owner, admin, cashier
    String? branchId,
  }) async {
    final id = _uuid.v4();
    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: id,
            businessId: businessId,
            fullName: fullName,
            email: email.trim().toLowerCase(),
            phone: Value(phone),
            role: Value(role),
            branchId: Value(branchId),
          ),
        );

    await syncService.enqueueMutation(
      action: 'INSERT',
      tableName: 'profiles',
      recordId: id,
      payloadJson: '{"id": "$id", "full_name": "$fullName", "role": "$role"}',
    );
  }

  Future<void> updateEmployee({
    required String id,
    required String fullName,
    String? phone,
    required String role,
    String? branchId,
    bool? isActive,
  }) async {
    await (db.update(db.users)..where((tbl) => tbl.id.equals(id))).write(
      UsersCompanion(
        fullName: Value(fullName),
        phone: Value(phone),
        role: Value(role),
        branchId: Value(branchId),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await syncService.enqueueMutation(
      action: 'UPDATE',
      tableName: 'profiles',
      recordId: id,
      payloadJson: '{"id": "$id", "full_name": "$fullName", "role": "$role"}',
    );
  }
}

