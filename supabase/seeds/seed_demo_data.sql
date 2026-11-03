-- ==============================================================================
-- KASIRPRO: SMART POS MOBILE - SEED DEMO DATA
-- Realistic Indonesian UMKM Store Data (KasirPro Mart / Berkah Jaya)
-- ==============================================================================

-- 1. Demo Business
INSERT INTO businesses (id, name, slug, address, phone, currency, timezone, tax_rate)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'KasirPro Mart (Berkah Jaya)',
    'kasirpro-berkah-jaya',
    'Jl. Pasar Minggu No. 45, Jakarta Selatan',
    '081234567890',
    'IDR',
    'Asia/Jakarta',
    11.00
) ON CONFLICT (id) DO NOTHING;

-- 2. Demo Branches
INSERT INTO branches (id, business_id, name, address, phone, is_main)
VALUES 
(
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Cabang Utama (Pasar Minggu)',
    'Jl. Pasar Minggu No. 45, Jakarta Selatan',
    '081234567891',
    TRUE
),
(
    'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380b33',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Cabang 2 (Tebet Barat)',
    'Jl. Tebet Barat Raya No. 12, Jakarta Selatan',
    '081234567892',
    FALSE
) ON CONFLICT (id) DO NOTHING;

-- 3. Demo Profiles (Users)
INSERT INTO profiles (id, business_id, branch_id, email, full_name, phone, role)
VALUES
(
    'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c11',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
    'owner@kasirpro.id',
    'Hendra Gunawan (Owner)',
    '081288880001',
    'owner'
),
(
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380c22',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
    'admin@kasirpro.id',
    'Siti Rahma (Admin Operasional)',
    '081288880002',
    'admin'
),
(
    'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
    'kasir1@kasirpro.id',
    'Dimas Pratama (Kasir Shift Pagi)',
    '081288880003',
    'cashier'
),
(
    'c4eebc99-9c0b-4ef8-bb6d-6bb9bd380c44',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380b33',
    'kasir2@kasirpro.id',
    'Anisa Bella (Kasir Shift Siang)',
    '081288880004',
    'cashier'
) ON CONFLICT (id) DO NOTHING;

-- 4. Demo Categories
INSERT INTO categories (id, business_id, name, icon, color)
VALUES
('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sembako & Beras', 'shopping_basket', '#2D6A4F'),
('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Makanan Ringan & Mie', 'fastfood', '#D97706'),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Minuman & Susu', 'local_cafe', '#2563EB'),
('d4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Bumbu Dapur & Minyak', 'kitchen', '#059669'),
('d5eebc99-9c0b-4ef8-bb6d-6bb9bd380d55', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Kebutuhan Rumah Tangga', 'cleaning_services', '#7C3AED'),
('d6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Personal Care & Sabun', 'spa', '#DB2777')
ON CONFLICT (id) DO NOTHING;

-- 5. Demo Customers
INSERT INTO customers (id, business_id, name, phone, address, total_spend, active_debt)
VALUES
('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380e11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Bu Ratna (Warung Bu Ratna)', '081311112222', 'Jl. Masjid No. 8', 1250000.00, 350000.00),
('e2eebc99-9c0b-4ef8-bb6d-6bb9bd380e22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Pak Joko Santoso', '081322223333', 'Jl. Salak No. 14', 450000.00, 0.00),
('e3eebc99-9c0b-4ef8-bb6d-6bb9bd380e33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Ibu Nurhayati', '081333334444', 'Komplek Griya Indah C-4', 780000.00, 150000.00),
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380e44', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Pelanggan Umum (Walk-in)', '080000000000', 'Tunai Kasir', 2450000.00, 0.00)
ON CONFLICT (id) DO NOTHING;

-- 6. Demo Suppliers
INSERT INTO suppliers (id, business_id, name, phone, address, total_purchased, active_payable)
VALUES
('f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'PT Indofood Sukses Makmur', '021-5551234', 'Kawasan Industri Pulogadung', 8500000.00, 1500000.00),
('f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'CV Sumber Beras Nusantara', '021-5555678', 'Pasar Induk Cipinang No. 22', 12000000.00, 2000000.00),
('f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'PT Unilever Indonesia Dist.', '021-5559999', 'BSD City Tangerang', 6200000.00, 0.00)
ON CONFLICT (id) DO NOTHING;

-- 7. Demo Products (22+ Realistic UMKM Retail Items)
INSERT INTO products (id, business_id, branch_id, category_id, supplier_id, name, sku, barcode, description, buy_price, sell_price, current_stock, min_stock, unit)
VALUES
('p01ebc99-9c0b-4ef8-bb6d-6bb9bd380001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'Beras Pandan Wangi Premium 5kg', 'BRS-PW-05K', '899100100101', 'Beras pulen wangi asli Cianjur kemasan 5kg', 65000.00, 76000.00, 35.0, 10.0, 'sak'),
('p02ebc99-9c0b-4ef8-bb6d-6bb9bd380002', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'Beras Rojolele Super 5kg', 'BRS-RJ-05K', '899100100102', 'Beras putih bersih rasa gurih kemasan 5kg', 62000.00, 72500.00, 28.0, 10.0, 'sak'),
('p03ebc99-9c0b-4ef8-bb6d-6bb9bd380003', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Minyak Goreng Bimoli Pouch 2L', 'MYK-BML-2L', '899100100201', 'Minyak kelapa sawit murni kemasan 2 liter', 33500.00, 38500.00, 42.0, 15.0, 'pouch'),
('p04ebc99-9c0b-4ef8-bb6d-6bb9bd380004', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Minyak Goreng Tropical 2L', 'MYK-TRP-2L', '899100100202', 'Minyak goreng 2x penyaringan 2 liter', 34000.00, 39000.00, 18.0, 10.0, 'pouch'),
('p05ebc99-9c0b-4ef8-bb6d-6bb9bd380005', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Gula Pasir Gulaku Tebu 1kg', 'GLA-GLK-1K', '899100100301', 'Gula kristal putih manis alami 1kg', 15200.00, 18000.00, 60.0, 15.0, 'kg'),
('p06ebc99-9c0b-4ef8-bb6d-6bb9bd380006', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Tepung Terigu Segitiga Biru 1kg', 'TPG-SGB-1K', '899100100401', 'Tepung terigu serbaguna 1kg', 11000.00, 13500.00, 4.0, 10.0, 'kg'), -- Menipis
('p07ebc99-9c0b-4ef8-bb6d-6bb9bd380007', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Indomie Goreng Spesial 85g', 'MIE-IDM-GR', '899100100501', 'Mie instan goreng nomor 1 di Indonesia', 2800.00, 3500.00, 120.0, 24.0, 'bungkus'),
('p08ebc99-9c0b-4ef8-bb6d-6bb9bd380008', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Indomie Kuah Ayam Bawang 69g', 'MIE-IDM-AB', '899100100502', 'Mie rebus rasa kuah ayam bawang gurih', 2700.00, 3500.00, 95.0, 24.0, 'bungkus'),
('p09ebc99-9c0b-4ef8-bb6d-6bb9bd380009', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd2eebc99-9c0b-4ef8-bb6d-6bb9bd380d22', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Mie Sedaap Goreng 90g', 'MIE-SDP-GR', '899100100503', 'Mie goreng kriuk dengan taburan bawang renyah', 2750.00, 3500.00, 80.0, 20.0, 'bungkus'),
('p10ebc99-9c0b-4ef8-bb6d-6bb9bd380010', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Susu UHT Ultra Milk Full Cream 1L', 'SSU-ULT-1L', '899100100601', 'Susu sapi segar UHT kemasan 1000ml', 17500.00, 21500.00, 32.0, 10.0, 'kotak'),
('p11ebc99-9c0b-4ef8-bb6d-6bb9bd380011', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Susu UHT Ultra Milk Cokelat 1L', 'SSU-ULT-CK', '899100100602', 'Susu sapi segar UHT rasa coklat 1000ml', 17800.00, 22000.00, 25.0, 10.0, 'kotak'),
('p12ebc99-9c0b-4ef8-bb6d-6bb9bd380012', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Kopi Kapal Api Spesial Mix 10x24g', 'KPI-KPL-MX', '899100100701', 'Kopi hitam bubuk manis renceng isi 10 sachet', 12500.00, 15500.00, 50.0, 10.0, 'renceng'),
('p13ebc99-9c0b-4ef8-bb6d-6bb9bd380013', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Teh Celup Sosro Kotak Isi 25', 'TEH-SSR-25', '899100100801', 'Teh celup aroma melati asli Indonesia', 6500.00, 8500.00, 45.0, 10.0, 'kotak'),
('p14ebc99-9c0b-4ef8-bb6d-6bb9bd380014', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d33', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'Aqua Air Mineral Botol 600ml', 'AQU-BTL-60', '899100100901', 'Air mineral pegunungan murni 600ml', 2800.00, 4000.00, 96.0, 24.0, 'botol'),
('p15ebc99-9c0b-4ef8-bb6d-6bb9bd380015', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Kecap Manis Bango Refill 550ml', 'KCP-BNG-55', '899100101001', 'Kecap kedelai hitam mallika gurih manis', 21000.00, 25500.00, 30.0, 8.0, 'pouch'),
('p16ebc99-9c0b-4ef8-bb6d-6bb9bd380016', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd4eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Royco Kaldu Ayam 230g', 'RYC-AYM-23', '899100101101', 'Bumbu penyedap rasa ekstrak daging ayam', 8500.00, 11000.00, 2.0, 8.0, 'pouch'), -- Menipis
('p17ebc99-9c0b-4ef8-bb6d-6bb9bd380017', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd5eebc99-9c0b-4ef8-bb6d-6bb9bd380d55', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Sunlight Jeruk Nipis 650ml', 'SNL-JRK-65', '899100101201', 'Sabun cuci piring pembersih lemak 650ml', 13500.00, 16500.00, 40.0, 10.0, 'pouch'),
('p18ebc99-9c0b-4ef8-bb6d-6bb9bd380018', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd5eebc99-9c0b-4ef8-bb6d-6bb9bd380d55', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Rinso Molto Deterjen Bubuk 770g', 'RNS-MLT-77', '899100101301', 'Deterjen konsentrat pembersih noda pakaian', 23000.00, 27500.00, 22.0, 8.0, 'bungkus'),
('p19ebc99-9c0b-4ef8-bb6d-6bb9bd380019', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Lifebuoy Sabun Cair Total 10 400ml', 'LFB-C01-40', '899100101401', 'Sabun antibakteri perlindungan keluarga 400ml', 18500.00, 23000.00, 28.0, 8.0, 'pouch'),
('p20ebc99-9c0b-4ef8-bb6d-6bb9bd380020', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Pepsodent Pencegah Gigi Berlubang 190g', 'PPD-GGL-19', '899100101501', 'Pasta gigi perlindungan kalsium & mikro floride', 12000.00, 15000.00, 36.0, 10.0, 'kotak'),
('p21ebc99-9c0b-4ef8-bb6d-6bb9bd380021', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd6eebc99-9c0b-4ef8-bb6d-6bb9bd380d66', 'f3eebc99-9c0b-4ef8-bb6d-6bb9bd380f33', 'Sunsilk Black Shine Shampoo 160ml', 'SNS-BLK-16', '899100101601', 'Sampo rambut hitam berkilau urang aring', 19000.00, 24000.00, 19.0, 6.0, 'botol'),
('p22ebc99-9c0b-4ef8-bb6d-6bb9bd380022', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380d11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'Telur Ayam Negeri Fresh 1kg', 'TLR-AYM-1K', '899100101701', 'Telur ayam negeri segar kualitas pilihan isi 16', 26000.00, 30000.00, 0.0, 5.0, 'kg') -- Stok Habis
ON CONFLICT (id) DO NOTHING;

-- 8. Demo Initial Stock Movements
INSERT INTO stock_movements (business_id, branch_id, product_id, movement_type, previous_stock, quantity_changed, remaining_stock, reference_id, user_id, notes)
SELECT 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', id, 'PURCHASE', 0, current_stock, current_stock, 'PO-20261101-INIT', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 'Inisialisasi Stok Awal Toko'
FROM products WHERE business_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- 9. Demo Transactions
INSERT INTO transactions (id, business_id, branch_id, cashier_id, customer_id, invoice_number, subtotal, discount_amount, discount_percent, tax_amount, total_amount, payment_method, cash_received, change_amount, status, notes, created_at)
VALUES
('t1eebc99-9c0b-4ef8-bb6d-6bb9bd380t11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'e2eebc99-9c0b-4ef8-bb6d-6bb9bd380e22', 'INV-20261103-0001', 114500.00, 0.0, 0.0, 0.0, 114500.00, 'CASH', 120000.00, 5500.00, 'COMPLETED', 'Pelanggan reguler pagi', NOW() - INTERVAL '4 hour'),
('t2eebc99-9c0b-4ef8-bb6d-6bb9bd380t22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380e44', 'INV-20261103-0002', 43500.00, 0.0, 0.0, 0.0, 43500.00, 'QRIS', 43500.00, 0.00, 'COMPLETED', 'Pembayaran QRIS Statis', NOW() - INTERVAL '3 hour'),
('t3eebc99-9c0b-4ef8-bb6d-6bb9bd380t33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380e11', 'INV-20261103-0003', 190500.00, 5000.0, 0.0, 0.0, 185500.00, 'TRANSFER', 185500.00, 0.00, 'COMPLETED', 'Belanja warung Bu Ratna', NOW() - INTERVAL '2 hour')
ON CONFLICT (id) DO NOTHING;

-- 10. Demo Expenses
INSERT INTO expenses (id, business_id, branch_id, category, amount, expense_date, description, user_id)
VALUES
('x1eebc99-9c0b-4ef8-bb6d-6bb9bd380x11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'ELECTRICITY', 450000.00, CURRENT_DATE, 'Token Listrik PLN Toko 450k', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c11'),
('x2eebc99-9c0b-4ef8-bb6d-6bb9bd380x22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'OPERATIONAL', 85000.00, CURRENT_DATE, 'Beli Kantong Plastik & Kertas Struk Thermal 10 Roll', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380c22'),
('x3eebc99-9c0b-4ef8-bb6d-6bb9bd380x33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'WATER', 120000.00, CURRENT_DATE - INTERVAL '2 day', 'Tagihan Air PDAM Bulan Berjalan', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380c11')
ON CONFLICT (id) DO NOTHING;

-- 11. Demo Customer Debts
INSERT INTO debts (id, business_id, customer_id, invoice_number, total_debt, paid_amount, remaining_debt, due_date, status)
VALUES
('h1eebc99-9c0b-4ef8-bb6d-6bb9bd380h11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380e11', 'INV-20261028-0099', 500000.00, 150000.00, 350000.00, CURRENT_DATE + INTERVAL '5 day', 'PARTIAL'),
('h2eebc99-9c0b-4ef8-bb6d-6bb9bd380h22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e3eebc99-9c0b-4ef8-bb6d-6bb9bd380e33', 'INV-20261030-0112', 150000.00, 0.00, 150000.00, CURRENT_DATE + INTERVAL '10 day', 'UNPAID')
ON CONFLICT (id) DO NOTHING;

-- 12. Demo Supplier Receivables (Hutang ke Supplier)
INSERT INTO receivables (id, business_id, supplier_id, purchase_reference, total_bill, paid_amount, remaining_bill, due_date, status)
VALUES
('r1eebc99-9c0b-4ef8-bb6d-6bb9bd380r11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380f11', 'PO-20261025-IND', 3500000.00, 2000000.00, 1500000.00, CURRENT_DATE + INTERVAL '7 day', 'PARTIAL'),
('r2eebc99-9c0b-4ef8-bb6d-6bb9bd380r22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380f22', 'PO-20261026-BRS', 5000000.00, 3000000.00, 2000000.00, CURRENT_DATE + INTERVAL '14 day', 'PARTIAL')
ON CONFLICT (id) DO NOTHING;

