import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/services/sync_service.dart';

class ProductRepository {
  final AppDatabase db;
  final SyncService syncService;
  final _uuid = const Uuid();

  ProductRepository({required this.db, required this.syncService});

  Stream<List<Product>> watchAllProducts({String? businessId}) {
    final query = db.select(db.products);
    if (businessId != null) {
      query.where((tbl) => tbl.businessId.equals(businessId));
    }
    return (query..where((tbl) => tbl.isActive.equals(true))).watch();
  }

  Future<List<Product>> getProducts({
    String? businessId,
    String? searchQuery,
    String? categoryId,
    String? stockFilter, // 'ALL', 'LOW', 'OUT'
    String? sortBy, // 'NAME_ASC', 'PRICE_ASC', 'PRICE_DESC', 'STOCK_ASC'
  }) async {
    final query = db.select(db.products);

    query.where((tbl) => tbl.isActive.equals(true));

    if (businessId != null) {
      query.where((tbl) => tbl.businessId.equals(businessId));
    }

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'ALL') {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where((tbl) => tbl.name.lower().like(term) | tbl.barcode.like(term) | tbl.sku.lower().like(term));
    }

    if (stockFilter == 'LOW') {
      query.where((tbl) => tbl.currentStock.isSmallerOrEqual(tbl.minStock) & tbl.currentStock.isBiggerThanValue(0));
    } else if (stockFilter == 'OUT') {
      query.where((tbl) => tbl.currentStock.isSmallerOrEqualValue(0));
    }

    if (sortBy == 'PRICE_ASC') {
      query.orderBy([(tbl) => OrderingTerm.asc(tbl.sellPrice)]);
    } else if (sortBy == 'PRICE_DESC') {
      query.orderBy([(tbl) => OrderingTerm.desc(tbl.sellPrice)]);
    } else if (sortBy == 'STOCK_ASC') {
      query.orderBy([(tbl) => OrderingTerm.asc(tbl.currentStock)]);
    } else {
      query.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    }

    return query.get();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    return (db.select(db.products)..where((tbl) => tbl.barcode.equals(barcode) & tbl.isActive.equals(true))).getSingleOrNull();
  }

  Future<Product?> getProductById(String id) async {
    return (db.select(db.products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<bool> isBarcodeDuplicate(String barcode, {String? excludeProductId}) async {
    final query = db.select(db.products)..where((tbl) => tbl.barcode.equals(barcode) & tbl.isActive.equals(true));
    if (excludeProductId != null) {
      query.where((tbl) => tbl.id.equals(excludeProductId).not());
    }
    final match = await query.getSingleOrNull();
    return match != null;
  }

  Future<void> addProduct(ProductsCompanion product) async {
    await db.into(db.products).insert(product);
    await syncService.enqueueMutation(
      action: 'INSERT',
      tableName: 'products',
      recordId: product.id.value,
      payloadJson: product.toString(),
    );
  }

  Future<void> updateProduct(ProductsCompanion product) async {
    await (db.update(db.products)..where((tbl) => tbl.id.equals(product.id.value))).write(product);
    await syncService.enqueueMutation(
      action: 'UPDATE',
      tableName: 'products',
      recordId: product.id.value,
      payloadJson: product.toString(),
    );
  }

  Future<void> deleteProduct(String id) async {
    await (db.update(db.products)..where((tbl) => tbl.id.equals(id))).write(
      const ProductsCompanion(isActive: Value(false)),
    );
    await syncService.enqueueMutation(
      action: 'DELETE',
      tableName: 'products',
      recordId: id,
      payloadJson: '{"id": "$id", "is_active": false}',
    );
  }

  Future<String> exportToCsv(String businessId) async {
    final products = await getProducts(businessId: businessId);
    final rows = <List<dynamic>>[];
    rows.add(['SKU', 'Barcode', 'Nama Produk', 'Harga Beli (HPP)', 'Harga Jual', 'Stok', 'Stok Min', 'Satuan']);

    for (final p in products) {
      rows.add([
        p.sku,
        p.barcode ?? '',
        p.name,
        p.buyPrice,
        p.sellPrice,
        p.currentStock,
        p.minStock,
        p.unit,
      ]);
    }
    return const ListToCsvConverter().convert(rows);
  }

  Future<int> importFromCsv(String csvString, String businessId, String branchId) async {
    final rows = const CsvToListConverter().convert(csvString);
    if (rows.length <= 1) return 0;

    int importedCount = 0;
    // Skip header row
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;

      final sku = row[0].toString().trim();
      final barcode = row[1].toString().trim();
      final name = row[2].toString().trim();
      final buyPrice = double.tryParse(row[3].toString()) ?? 0.0;
      final sellPrice = double.tryParse(row[4].toString()) ?? 0.0;
      final stock = row.length > 5 ? (double.tryParse(row[5].toString()) ?? 0.0) : 0.0;
      final minStock = row.length > 6 ? (double.tryParse(row[6].toString()) ?? 5.0) : 5.0;
      final unit = row.length > 7 ? row[7].toString().trim() : 'pcs';

      if (name.isEmpty) continue;

      final id = _uuid.v4();
      await addProduct(
        ProductsCompanion.insert(
          id: id,
          businessId: businessId,
          branchId: Value(branchId),
          name: name,
          sku: sku.isNotEmpty ? sku : 'SKU-$id',
          barcode: Value(barcode.isNotEmpty ? barcode : null),
          buyPrice: Value(buyPrice),
          sellPrice: Value(sellPrice),
          currentStock: Value(stock),
          minStock: Value(minStock),
          unit: Value(unit.isNotEmpty ? unit : 'pcs'),
        ),
      );
      importedCount++;
    }
    return importedCount;
  }
}

