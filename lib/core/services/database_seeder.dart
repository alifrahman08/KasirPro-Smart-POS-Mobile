import 'package:drift/drift.dart';
import '../database/app_database.dart';

class DatabaseSeeder {
  final AppDatabase db;

  DatabaseSeeder(this.db);

  Future<void> seedIfEmpty() async {
    final existingCount = await (db.select(db.businesses)).get();
    if (existingCount.isNotEmpty) {
      return; // Already seeded
    }

    await db.transaction(() async {
      // 1. Business
      await db.into(db.businesses).insert(
            BusinessesCompanion.insert(
              id: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              name: 'KasirPro Mart (Berkah Jaya)',
              slug: 'kasirpro-berkah-jaya',
              address: const Value('Jl. Pasar Minggu No. 45, Jakarta Selatan'),
              phone: const Value('081234567890'),
              currency: const Value('IDR'),
              timezone: const Value('Asia/Jakarta'),
              taxRate: const Value(11.0),
            ),
          );

      // 2. Branches
      await db.into(db.branches).insert(
            BranchesCompanion.insert(
              id: 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              name: 'Cabang Utama (Pasar Minggu)',
              address: const Value('Jl. Pasar Minggu No. 45, Jakarta Selatan'),
              phone: const Value('081234567891'),
              isMain: const Value(true),
            ),
          );

      await db.into(db.branches).insert(
            BranchesCompanion.insert(
              id: 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380b33',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              name: 'Cabang 2 (Tebet Barat)',
              address: const Value('Jl. Tebet Barat Raya No. 12, Jakarta Selatan'),
              phone: const Value('081234567892'),
              isMain: const Value(false),
            ),
          );

      // 3. Users (Owner, Admin, Kasir 1, Kasir 2)
      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c11',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: const Value('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22'),
              email: 'owner@kasirpro.id',
              fullName: 'Hendra Gunawan (Owner)',
              phone: const Value('081288880001'),
              role: const Value('owner'),
            ),
          );

      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380c22',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: const Value('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22'),
              email: 'admin@kasirpro.id',
              fullName: 'Siti Rahma (Admin Operasional)',
              phone: const Value('081288880002'),
              role: const Value('admin'),
            ),
          );

      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: const Value('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22'),
              email: 'kasir1@kasirpro.id',
              fullName: 'Dimas Pratama (Kasir Shift Pagi)',
              phone: const Value('081288880003'),
              role: const Value('cashier'),
            ),
          );

      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: 'c4eebc99-9c0b-4ef8-bb6d-6bb9bd380c44',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: const Value('b2eebc99-9c0b-4ef8-bb6d-6bb9bd380b33'),
              email: 'kasir2@kasirpro.id',
              fullName: 'Anisa Bella (Kasir Shift Siang)',
              phone: const Value('081288880004'),
              role: const Value('cashier'),
            ),
          );

      // 4. Categories
      final categoriesData = [
        ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'Sembako & Beras', 'shopping_basket', '#2D6A4F'),
        ('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'Makanan Ringan & Mie', 'fastfood', '#D97706'),
        ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'Minuman & Susu', 'local_cafe', '#2563EB'),
        ('d4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'Bumbu Dapur & Minyak', 'kitchen', '#059669'),
        ('d5eebc99-9c0b-4ef8-bb6d-6bb9bd380d55', 'Kebutuhan Rumah Tangga', 'cleaning_services', '#7C3AED'),
        ('d6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'Personal Care & Sabun', 'spa', '#DB2777'),
      ];

      for (final cat in categoriesData) {
        await db.into(db.categories).insert(
              CategoriesCompanion.insert(
                id: cat.$1,
                businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                name: cat.$2,
                icon: Value(cat.$3),
                color: Value(cat.$4),
              ),
            );
      }

      // 5. Customers
      final customersData = [
        ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380e11', 'Bu Ratna (Warung Bu Ratna)', '081311112222', 'Jl. Masjid No. 8', 1250000.0, 350000.0),
        ('e2eebc99-9c0b-4ef8-bb6d-6bb9bd380e22', 'Pak Joko Santoso', '081322223333', 'Jl. Salak No. 14', 450000.0, 0.0),
        ('e3eebc99-9c0b-4ef8-bb6d-6bb9bd380e33', 'Ibu Nurhayati', '081333334444', 'Komplek Griya Indah C-4', 780000.0, 150000.0),
        ('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380e44', 'Pelanggan Umum (Walk-in)', '080000000000', 'Tunai Kasir', 2450000.0, 0.0),
      ];

      for (final c in customersData) {
        await db.into(db.customers).insert(
              CustomersCompanion.insert(
                id: c.$1,
                businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                name: c.$2,
                phone: Value(c.$3),
                address: Value(c.$4),
                totalSpend: Value(c.$5),
                activeDebt: Value(c.$6),
              ),
            );
      }

      // 6. Suppliers
      final suppliersData = [
        ('f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'PT Indofood Sukses Makmur', '021-5551234', 'Kawasan Industri Pulogadung', 8500000.0, 1500000.0),
        ('f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'CV Sumber Beras Nusantara', '021-5555678', 'Pasar Induk Cipinang No. 22', 12000000.0, 2000000.0),
        ('f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'PT Unilever Indonesia Dist.', '021-5559999', 'BSD City Tangerang', 6200000.0, 0.0),
      ];

      for (final s in suppliersData) {
        await db.into(db.suppliers).insert(
              SuppliersCompanion.insert(
                id: s.$1,
                businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                name: s.$2,
                phone: Value(s.$3),
                address: Value(s.$4),
                totalPurchased: Value(s.$5),
                activePayable: Value(s.$6),
              ),
            );
      }

      // 7. Products (22 Realistic Retail Items)
      final productsData = [
        ('p01ebc99-9c0b-4ef8-bb6d-6bb9bd380001', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'Beras Pandan Wangi Premium 5kg', 'BRS-PW-05K', '899100100101', 'Beras pulen wangi asli Cianjur kemasan 5kg', 65000.0, 76000.0, 35.0, 10.0, 'sak'),
        ('p02ebc99-9c0b-4ef8-bb6d-6bb9bd380002', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'Beras Rojolele Super 5kg', 'BRS-RJ-05K', '899100100102', 'Beras putih bersih rasa gurih kemasan 5kg', 62000.0, 72500.0, 28.0, 10.0, 'sak'),
        ('p03ebc99-9c0b-4ef8-bb6d-6bb9bd380003', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Minyak Goreng Bimoli Pouch 2L', 'MYK-BML-2L', '899100100201', 'Minyak kelapa sawit murni kemasan 2 liter', 33500.0, 38500.0, 42.0, 15.0, 'pouch'),
        ('p04ebc99-9c0b-4ef8-bb6d-6bb9bd380004', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Minyak Goreng Tropical 2L', 'MYK-TRP-2L', '899100100202', 'Minyak goreng 2x penyaringan 2 liter', 34000.0, 39000.0, 18.0, 10.0, 'pouch'),
        ('p05ebc99-9c0b-4ef8-bb6d-6bb9bd380005', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Gula Pasir Gulaku Tebu 1kg', 'GLA-GLK-1K', '899100100301', 'Gula kristal putih manis alami 1kg', 15200.0, 18000.0, 60.0, 15.0, 'kg'),
        ('p06ebc99-9c0b-4ef8-bb6d-6bb9bd380006', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Tepung Terigu Segitiga Biru 1kg', 'TPG-SGB-1K', '899100100401', 'Tepung terigu serbaguna 1kg', 11000.0, 13500.0, 4.0, 10.0, 'kg'), // Menipis
        ('p07ebc99-9c0b-4ef8-bb6d-6bb9bd380007', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Indomie Goreng Spesial 85g', 'MIE-IDM-GR', '899100100501', 'Mie instan goreng nomor 1 di Indonesia', 2800.0, 3500.0, 120.0, 24.0, 'bungkus'),
        ('p08ebc99-9c0b-4ef8-bb6d-6bb9bd380008', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Indomie Kuah Ayam Bawang 69g', 'MIE-IDM-AB', '899100100502', 'Mie rebus rasa kuah ayam bawang gurih', 2700.0, 3500.0, 95.0, 24.0, 'bungkus'),
        ('p09ebc99-9c0b-4ef8-bb6d-6bb9bd380009', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Mie Sedaap Goreng 90g', 'MIE-SDP-GR', '899100100503', 'Mie goreng kriuk dengan taburan bawang renyah', 2750.0, 3500.0, 80.0, 20.0, 'bungkus'),
        ('p10ebc99-9c0b-4ef8-bb6d-6bb9bd380010', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Susu UHT Ultra Milk Full Cream 1L', 'SSU-ULT-1L', '899100100601', 'Susu sapi segar UHT kemasan 1000ml', 17500.0, 21500.0, 32.0, 10.0, 'kotak'),
        ('p11ebc99-9c0b-4ef8-bb6d-6bb9bd380011', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Susu UHT Ultra Milk Cokelat 1L', 'SSU-ULT-CK', '899100100602', 'Susu sapi segar UHT rasa coklat 1000ml', 17800.0, 22000.0, 25.0, 10.0, 'kotak'),
        ('p12ebc99-9c0b-4ef8-bb6d-6bb9bd380012', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Kopi Kapal Api Spesial Mix 10x24g', 'KPI-KPL-MX', '899100100701', 'Kopi hitam bubuk manis renceng isi 10 sachet', 12500.0, 15500.0, 50.0, 10.0, 'renceng'),
        ('p13ebc99-9c0b-4ef8-bb6d-6bb9bd380013', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Teh Celup Sosro Kotak Isi 25', 'TEH-SSR-25', '899100100801', 'Teh celup aroma melati asli Indonesia', 6500.0, 8500.0, 45.0, 10.0, 'kotak'),
        ('p14ebc99-9c0b-4ef8-bb6d-6bb9bd380014', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Aqua Air Mineral Botol 600ml', 'AQU-BTL-60', '899100100901', 'Air mineral pegunungan murni 600ml', 2800.0, 4000.0, 96.0, 24.0, 'botol'),
        ('p15ebc99-9c0b-4ef8-bb6d-6bb9bd380015', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Kecap Manis Bango Refill 550ml', 'KCP-BNG-55', '899100101001', 'Kecap kedelai hitam mallika gurih manis', 21000.0, 25500.0, 30.0, 8.0, 'pouch'),
        ('p16ebc99-9c0b-4ef8-bb6d-6bb9bd380016', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Royco Kaldu Ayam 230g', 'RYC-AYM-23', '899100101101', 'Bumbu penyedap rasa ekstrak daging ayam', 8500.0, 11000.0, 2.0, 8.0, 'pouch'), // Menipis
        ('p17ebc99-9c0b-4ef8-bb6d-6bb9bd380017', 'd5eebc99-9c0b-4ef8-bb6d-6bb9bd380d55', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Sunlight Jeruk Nipis 650ml', 'SNL-JRK-65', '899100101201', 'Sabun cuci piring pembersih lemak 650ml', 13500.0, 16500.0, 40.0, 10.0, 'pouch'),
        ('p18ebc99-9c0b-4ef8-bb6d-6bb9bd380018', 'd5eebc99-9c0b-4ef8-bb6d-6bb9bd380d55', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Rinso Molto Deterjen Bubuk 770g', 'RNS-MLT-77', '899100101301', 'Deterjen konsentrat pembersih noda pakaian', 23000.0, 27500.0, 22.0, 8.0, 'bungkus'),
        ('p19ebc99-9c0b-4ef8-bb6d-6bb9bd380019', 'd6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Lifebuoy Sabun Cair Total 10 400ml', 'LFB-C01-40', '899100101401', 'Sabun antibakteri perlindungan keluarga 400ml', 18500.0, 23000.0, 28.0, 8.0, 'pouch'),
        ('p20ebc99-9c0b-4ef8-bb6d-6bb9bd380020', 'd6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Pepsodent Pencegah Gigi Berlubang 190g', 'PPD-GGL-19', '899100101501', 'Pasta gigi perlindungan kalsium & mikro floride', 12000.0, 15000.0, 36.0, 10.0, 'kotak'),
        ('p21ebc99-9c0b-4ef8-bb6d-6bb9bd380021', 'd6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Sunsilk Black Shine Shampoo 160ml', 'SNS-BLK-16', '899100101601', 'Sampo rambut hitam berkilau urang aring', 19000.0, 24000.0, 19.0, 6.0, 'botol'),
        ('p22ebc99-9c0b-4ef8-bb6d-6bb9bd380022', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'Telur Ayam Negeri Fresh 1kg', 'TLR-AYM-1K', '899100101701', 'Telur ayam negeri segar kualitas pilihan', 26000.0, 30000.0, 0.0, 5.0, 'kg'), // Habis
      ];

      for (final p in productsData) {
        await db.into(db.products).insert(
              ProductsCompanion.insert(
                id: p.$1,
                businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                branchId: const Value('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22'),
                categoryId: Value(p.$2),
                supplierId: Value(p.$3),
                name: p.$4,
                sku: p.$5,
                barcode: Value(p.$6),
                description: Value(p.$7),
                buyPrice: Value(p.$8),
                sellPrice: Value(p.$9),
                currentStock: Value(p.$10),
                minStock: Value(p.$11),
                unit: Value(p.$12),
              ),
            );

        // Initial Stock Movement Record
        await db.into(db.stockMovements).insert(
              StockMovementsCompanion.insert(
                id: 'sm_${p.$1}',
                businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                branchId: 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
                productId: p.$1,
                movementType: 'PURCHASE',
                previousStock: 0.0,
                quantityChanged: p.$10,
                remainingStock: p.$10,
                referenceId: const Value('PO-20261101-INIT'),
                userId: const Value('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c11'),
                notes: const Value('Inisialisasi Stok Awal Toko'),
              ),
            );
      }

      // 8. Sample Past Transactions
      final now = DateTime.now();

      // TX 1
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 't1eebc99-9c0b-4ef8-bb6d-6bb9bd380t11',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
              cashierId: 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33',
              customerId: const Value('e2eebc99-9c0b-4ef8-bb6d-6bb9bd380e22'),
              invoiceNumber: 'INV-20261103-0001',
              subtotal: const Value(114500.0),
              totalAmount: const Value(114500.0),
              paymentMethod: const Value('CASH'),
              cashReceived: const Value(120000.0),
              changeAmount: const Value(5500.0),
              createdAt: Value(now.subtract(const Duration(hours: 4))),
            ),
          );

      await db.into(db.transactionItems).insert(
            TransactionItemsCompanion.insert(
              id: 'ti_001_1',
              transactionId: 't1eebc99-9c0b-4ef8-bb6d-6bb9bd380t11',
              productId: 'p01ebc99-9c0b-4ef8-bb6d-6bb9bd380001',
              productName: 'Beras Pandan Wangi Premium 5kg',
              sku: const Value('BRS-PW-05K'),
              barcode: const Value('899100100101'),
              buyPrice: const Value(65000.0),
              sellPrice: const Value(76000.0),
              quantity: const Value(1.0),
              subtotalAmount: const Value(76000.0),
            ),
          );

      await db.into(db.transactionItems).insert(
            TransactionItemsCompanion.insert(
              id: 'ti_001_2',
              transactionId: 't1eebc99-9c0b-4ef8-bb6d-6bb9bd380t11',
              productId: 'p03ebc99-9c0b-4ef8-bb6d-6bb9bd380003',
              productName: 'Minyak Goreng Bimoli Pouch 2L',
              sku: const Value('MYK-BML-2L'),
              barcode: const Value('899100100201'),
              buyPrice: const Value(33500.0),
              sellPrice: const Value(38500.0),
              quantity: const Value(1.0),
              subtotalAmount: const Value(38500.0),
            ),
          );

      // TX 2 (QRIS)
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 't2eebc99-9c0b-4ef8-bb6d-6bb9bd380t22',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
              cashierId: 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33',
              customerId: const Value('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380e44'),
              invoiceNumber: 'INV-20261103-0002',
              subtotal: const Value(43500.0),
              totalAmount: const Value(43500.0),
              paymentMethod: const Value('QRIS'),
              cashReceived: const Value(43500.0),
              changeAmount: const Value(0.0),
              createdAt: Value(now.subtract(const Duration(hours: 3))),
            ),
          );

      // TX 3 (Transfer Bank)
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 't3eebc99-9c0b-4ef8-bb6d-6bb9bd380t33',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
              cashierId: 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33',
              customerId: const Value('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380e11'),
              invoiceNumber: 'INV-20261103-0003',
              subtotal: const Value(190500.0),
              discountAmount: const Value(5000.0),
              totalAmount: const Value(185500.0),
              paymentMethod: const Value('TRANSFER'),
              cashReceived: const Value(185500.0),
              changeAmount: const Value(0.0),
              createdAt: Value(now.subtract(const Duration(hours: 2))),
            ),
          );

      // 9. Expenses
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'x1eebc99-9c0b-4ef8-bb6d-6bb9bd380x11',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: const Value('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22'),
              category: 'ELECTRICITY',
              amount: 450000.0,
              description: 'Token Listrik PLN Toko 450k',
              userId: const Value('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c11'),
            ),
          );

      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'x2eebc99-9c0b-4ef8-bb6d-6bb9bd380x22',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              branchId: const Value('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22'),
              category: 'OPERATIONAL',
              amount: 85000.0,
              description: 'Beli Kantong Plastik & Kertas Struk Thermal 10 Roll',
              userId: const Value('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380c22'),
            ),
          );

      // 10. Customer Debts
      await db.into(db.debts).insert(
            DebtsCompanion.insert(
              id: 'h1eebc99-9c0b-4ef8-bb6d-6bb9bd380h11',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              customerId: 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380e11',
              invoiceNumber: 'INV-20261028-0099',
              totalDebt: 500000.0,
              paidAmount: const Value(150000.0),
              remainingDebt: 350000.0,
              dueDate: now.add(const Duration(days: 5)),
              status: const Value('PARTIAL'),
            ),
          );

      await db.into(db.debts).insert(
            DebtsCompanion.insert(
              id: 'h2eebc99-9c0b-4ef8-bb6d-6bb9bd380h22',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              customerId: 'e3eebc99-9c0b-4ef8-bb6d-6bb9bd380e33',
              invoiceNumber: 'INV-20261030-0112',
              totalDebt: 150000.0,
              paidAmount: const Value(0.0),
              remainingDebt: 150000.0,
              dueDate: now.add(const Duration(days: 10)),
              status: const Value('UNPAID'),
            ),
          );

      // 11. Supplier Receivables
      await db.into(db.receivables).insert(
            ReceivablesCompanion.insert(
              id: 'r1eebc99-9c0b-4ef8-bb6d-6bb9bd380r11',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              supplierId: 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11',
              purchaseReference: 'PO-20261025-IND',
              totalBill: 3500000.0,
              paidAmount: const Value(2000000.0),
              remainingBill: 1500000.0,
              dueDate: now.add(const Duration(days: 7)),
              status: const Value('PARTIAL'),
            ),
          );

      // 12. Notifications
      await db.into(db.notifications).insert(
            NotificationsCompanion.insert(
              id: 'notif_001',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              title: 'Peringatan Stok Menipis',
              message: 'Tepung Terigu Segitiga Biru 1kg tersisa 4 kg (di bawah batas minimum 10 kg).',
              type: const Value('STOCK_LOW'),
            ),
          );

      await db.into(db.notifications).insert(
            NotificationsCompanion.insert(
              id: 'notif_002',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              title: 'Stok Habis!',
              message: 'Telur Ayam Negeri Fresh 1kg stok telah habis (0 kg). Segera lakukan pemesanan ke supplier.',
              type: const Value('STOCK_OUT'),
            ),
          );

      await db.into(db.notifications).insert(
            NotificationsCompanion.insert(
              id: 'notif_003',
              businessId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
              title: 'Hutang Pelanggan Mendekati Jatuh Tempo',
              message: 'Warung Bu Ratna memiliki sisa hutang Rp 350.000 dengan jatuh tempo dalam 5 hari.',
              type: const Value('DEBT_DUE'),
            ),
          );
    });
  }
}

