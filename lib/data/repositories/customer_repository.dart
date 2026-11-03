import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class CustomerRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  CustomerRepository({required this.db, required this.syncService});

  Stream<List<Customer>> watchCustomers(String businessId) {
    return (db.select(db.customers)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Future<List<Customer>> getCustomers(String businessId, {String? searchQuery}) async {
    final query = db.select(db.customers)
      ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true));

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where((tbl) => tbl.name.lower().like(term) | tbl.phone.like(term));
    }

    query.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.get();
  }

  Future<void> addCustomer({
    required String businessId,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final id = _uuid.v4();
    await db.into(db.customers).insert(
          CustomersCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(address),
          ),
        );

    await syncService.enqueueMutation(
      action: 'INSERT',
      tableName: 'customers',
      recordId: id,
      payloadJson: '{"id": "$id", "name": "$name"}',
    );
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    await (db.update(db.customers)..where((tbl) => tbl.id.equals(id))).write(
      CustomersCompanion(
        name: Value(name),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await syncService.enqueueMutation(
      action: 'UPDATE',
      tableName: 'customers',
      recordId: id,
      payloadJson: '{"id": "$id", "name": "$name"}',
    );
  }

  Future<void> deleteCustomer(String id) async {
    await (db.update(db.customers)..where((tbl) => tbl.id.equals(id))).write(
      const CustomersCompanion(isActive: Value(false)),
    );
    await syncService.enqueueMutation(
      action: 'DELETE',
      tableName: 'customers',
      recordId: id,
      payloadJson: '{"id": "$id"}',
    );
  }
}

