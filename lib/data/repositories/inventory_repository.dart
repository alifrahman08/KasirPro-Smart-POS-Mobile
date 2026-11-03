import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class OpnameItemInput {
  final Product product;
  final double physicalStock;
  final String? notes;

  OpnameItemInput({
    required this.product,
    required this.physicalStock,
    this.notes,
  });

  double get systemStock => product.currentStock;
  double get difference => physicalStock - systemStock;
}

class InventoryRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  InventoryRepository({required this.db, required this.syncService});

  Stream<List<StockMovement>> watchStockMovements(String businessId, {String? productId}) {
    final query = db.select(db.stockMovements)..where((tbl) => tbl.businessId.equals(businessId));
    if (productId != null) {
      query.where((tbl) => tbl.productId.equals(productId));
    }
    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.watch();
  }

  Future<List<StockMovement>> getStockMovements(String businessId, {String? productId, int limit = 100}) async {
    final query = db.select(db.stockMovements)..where((tbl) => tbl.businessId.equals(businessId));
    if (productId != null) {
      query.where((tbl) => tbl.productId.equals(productId));
    }
    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    query.limit(limit);
    return query.get();
  }

  Future<void> adjustStock({
    required String businessId,
    required String branchId,
    required String productId,
    required double quantityChange,
    required String movementType, // 'PURCHASE', 'ADJUSTMENT', 'SALE_RETURN', 'PURCHASE_RETURN'
    required String? userId,
    String? referenceId,
    String? notes,
  }) async {
    await db.transaction(() async {
      final product = await (db.select(db.products)..where((tbl) => tbl.id.equals(productId))).getSingle();

      final prevStock = product.currentStock;
      final newStock = prevStock + quantityChange;

      await (db.update(db.products)..where((tbl) => tbl.id.equals(productId))).write(
        ProductsCompanion(
          currentStock: Value(newStock),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final smId = _uuid.v4();
      await db.into(db.stockMovements).insert(
            StockMovementsCompanion.insert(
              id: smId,
              businessId: businessId,
              branchId: branchId,
              productId: productId,
              movementType: movementType,
              previousStock: prevStock,
              quantityChanged: quantityChange,
              remainingStock: newStock,
              referenceId: Value(referenceId),
              userId: Value(userId),
              notes: Value(notes),
            ),
          );
    });

    await syncService.enqueueMutation(
      action: 'STOCK_ADJUSTMENT',
      tableName: 'stock_movements',
      recordId: productId,
      payloadJson: '{"product_id": "$productId", "change": $quantityChange, "type": "$movementType"}',
    );
  }

  Future<void> performStockOpname({
    required String businessId,
    required String branchId,
    required String? userId,
    required List<OpnameItemInput> items,
    String? notes,
  }) async {
    final opnameId = _uuid.v4();

    await db.transaction(() async {
      int discrepancyCount = 0;

      for (final item in items) {
        if (item.difference != 0) {
          discrepancyCount++;
        }
      }

      // 1. Insert Stock Opname Header
      await db.into(db.stockOpnames).insert(
            StockOpnamesCompanion.insert(
              id: opnameId,
              businessId: businessId,
              branchId: branchId,
              userId: Value(userId),
              totalDiscrepancyItems: Value(discrepancyCount),
              notes: Value(notes),
              status: const Value('COMPLETED'),
            ),
          );

      // 2. Insert items and update product stocks
      for (final item in items) {
        final itemId = _uuid.v4();

        await db.into(db.stockOpnameItems).insert(
              StockOpnameItemsCompanion.insert(
                id: itemId,
                stockOpnameId: opnameId,
                productId: item.product.id,
                systemStock: item.systemStock,
                physicalStock: item.physicalStock,
                difference: item.difference,
                notes: Value(item.notes),
              ),
            );

        if (item.difference != 0) {
          // Adjust product stock to match physical count
          await (db.update(db.products)..where((tbl) => tbl.id.equals(item.product.id))).write(
            ProductsCompanion(
              currentStock: Value(item.physicalStock),
              updatedAt: Value(DateTime.now()),
            ),
          );

          // Record stock movement
          await db.into(db.stockMovements).insert(
                StockMovementsCompanion.insert(
                  id: _uuid.v4(),
                  businessId: businessId,
                  branchId: branchId,
                  productId: item.product.id,
                  movementType: 'STOCK_OPNAME',
                  previousStock: item.systemStock,
                  quantityChanged: item.difference,
                  remainingStock: item.physicalStock,
                  referenceId: Value('OPNAME-$opnameId'),
                  userId: Value(userId),
                  notes: Value(item.notes ?? 'Stock Opname Penyesuaian Fisik'),
                ),
              );
        }
      }
    });

    await syncService.enqueueMutation(
      action: 'STOCK_OPNAME',
      tableName: 'stock_opnames',
      recordId: opnameId,
      payloadJson: '{"opname_id": "$opnameId"}',
    );
  }
}

