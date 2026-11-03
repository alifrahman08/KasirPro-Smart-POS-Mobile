import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class BranchRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  BranchRepository({required this.db, required this.syncService});

  Stream<List<Branch>> watchBranches(String businessId) {
    return (db.select(db.branches)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Future<List<Branch>> getBranches(String businessId) async {
    return (db.select(db.branches)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<void> addBranch({
    required String businessId,
    required String name,
    String? address,
    String? phone,
    bool isMain = false,
  }) async {
    final id = _uuid.v4();
    await db.into(db.branches).insert(
          BranchesCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            address: Value(address),
            phone: Value(phone),
            isMain: Value(isMain),
          ),
        );

    await syncService.enqueueMutation(
      action: 'INSERT',
      tableName: 'branches',
      recordId: id,
      payloadJson: '{"id": "$id", "name": "$name"}',
    );
  }

  Future<void> updateBranch({
    required String id,
    required String name,
    String? address,
    String? phone,
    bool? isMain,
  }) async {
    await (db.update(db.branches)..where((tbl) => tbl.id.equals(id))).write(
      BranchesCompanion(
        name: Value(name),
        address: Value(address),
        phone: Value(phone),
        isMain: isMain != null ? Value(isMain) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await syncService.enqueueMutation(
      action: 'UPDATE',
      tableName: 'branches',
      recordId: id,
      payloadJson: '{"id": "$id", "name": "$name"}',
    );
  }
}

