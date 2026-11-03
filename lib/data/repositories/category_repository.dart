import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class CategoryRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  CategoryRepository({required this.db, required this.syncService});

  Stream<List<Category>> watchCategories(String businessId) {
    return (db.select(db.categories)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Future<List<Category>> getCategories(String businessId) async {
    return (db.select(db.categories)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<void> addCategory(String businessId, String name, String icon, String color) async {
    final id = _uuid.v4();
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            icon: Value(icon),
            color: Value(color),
          ),
        );
    await syncService.enqueueMutation(
      action: 'INSERT',
      tableName: 'categories',
      recordId: id,
      payloadJson: '{"id": "$id", "name": "$name"}',
    );
  }

  Future<void> updateCategory(String id, String name, String icon, String color) async {
    await (db.update(db.categories)..where((tbl) => tbl.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        icon: Value(icon),
        color: Value(color),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await syncService.enqueueMutation(
      action: 'UPDATE',
      tableName: 'categories',
      recordId: id,
      payloadJson: '{"id": "$id", "name": "$name"}',
    );
  }

  Future<void> deleteCategory(String id) async {
    await (db.update(db.categories)..where((tbl) => tbl.id.equals(id))).write(
      const CategoriesCompanion(isActive: Value(false)),
    );
    await syncService.enqueueMutation(
      action: 'DELETE',
      tableName: 'categories',
      recordId: id,
      payloadJson: '{"id": "$id", "is_active": false}',
    );
  }
}

