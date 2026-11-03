# KasirPro — Smart POS Mobile

> **"Kelola Toko Lebih Mudah, Bisnis Lebih Terarah."**  
> Aplikasi manajemen stok, kasir pintar (POS), transaksi penjualan, keuangan, dan operasional UMKM berbasis mobile.

KasirPro dirancang sebagai aplikasi Flutter tingkat produksi (*production-oriented*) dengan arsitektur bersih (*Clean Architecture*), manajemen state menggunakan **GetX**, penyimpanan lokal berkinerja tinggi menggunakan **SQLite (Drift)**, serta dukungan sinkronisasi cloud **Supabase PostgreSQL** lengkap dengan **Row Level Security (RLS)** dan fungsi transaksi atomik PostgreSQL.

---

## Daftar Isi

1. [Fitur Utama](#fitur-utama)
2. [Tech Stack](#tech-stack)
3. [Arsitektur Proyek](#arsitektur-proyek)
4. [User Roles & Hak Akses](#user-roles--hak-akses)
5. [Akun Demo Pengujian](#akun-demo-pengujian)
6. [Database Schema & Migrasi Supabase](#database-schema--migrasi-supabase)
7. [Sinkronisasi Cloud & Offline-First](#sinkronisasi-cloud--offline-first)
8. [Panduan Instalasi & Menjalankan Aplikasi](#panduan-instalasi--menjalankan-aplikasi)
9. [Menjalankan Automated Tests](#menjalankan-automated-tests)
10. [Instruksi Build Android APK](#instruksi-build-android-apk)
11. [Troubleshooting](#troubleshooting)

---

## Fitur Utama

- **Point of Sale (POS) Kasir Cepat**:
  - Pencarian produk instan berdasarkan nama, SKU, atau barcode.
  - Scan barcode langsung melalui kamera ponsel dengan retikel visual dan senter.
  - Keranjang dinamis dengan pengubah kuantitas, diskon item, diskon transaksi, dan pengaturan PPN (11%).
  - Pilihan metode pembayaran lengkap: **Tunai**, **QRIS (Dinamis)**, **Transfer Bank**, dan **Kartu Debit**.
  - Tombol nominal cepat (*quick cash chips*) dan kalkulator kembalian instan dengan validasi pencegah nominal kurang.
  - Pemrosesan transaksi atomik: pengurangan stok, pencatatan histori pergerakan stok, pembaruan total belanja pelanggan, dan nomor faktur unik (`INV-YYYYMMDD-XXXX`).
  - Proteksi anti-dobel transaksi (*anti-double-submit idempotency lock*).
- **Printer Thermal Bluetooth**:
  - Dukungan printer thermal ukuran roll **58mm** dan **80mm**.
  - Pindai perangkat Bluetooth (*BLE discovery*), pemasangan (*pairing*), dan penyimpanan printer default.
  - Pratinjau struk penjualan (*print preview*) dan cetak ulang (*reprint*) dari riwayat transaksi.
  - Generator struk PDF standar yang dapat dibagikan atau dicetak via sistem.
  - Simulator cetak virtual (*test print*) untuk pengujian tanpa perangkat fisik printer.
- **Katalog & Manajemen Produk**:
  - CRUD produk: Nama, SKU, Barcode, Kategori, Harga Beli (HPP), Harga Jual, Stok, Batas Minimum Stok, Satuan, dan Foto.
  - Validasi deteksi barcode duplikat dalam satu bisnis.
  - Filter kategori, filter stok menipis / habis, dan pengurutan harga/nama.
  - Fitur **Ekspor CSV** dan **Impor CSV** data produk massal.
- **Inventaris & Stock Opname**:
  - Pencatatan stok masuk (pembelian), stok keluar, dan retur.
  - **Stock Opname Fisik**: formulir perbandingan stok rak fisik vs stok sistem dengan deteksi selisih otomatis dan pemutakhiran stok instan.
  - Histori audit pergerakan stok lengkap (*Stock Movement Audit Trail*) mencatat tipe: `PURCHASE`, `SALE`, `ADJUSTMENT`, `STOCK_OPNAME`, `SALE_RETURN`, `PURCHASE_RETURN`.
- **Laporan Finansial & Laba Bersih**:
  - Metrik nyata: Total Omzet, Total HPP, Laba Kotor (*Gross Profit*), Biaya Operasional, dan **Laba Bersih (*Net Profit*)**.
  - Filter periode waktu: Hari Ini, Kemarin, 7 Hari Terakhir, Bulan Ini, Tahun Ini, dan Rentang Kustom.
  - Grafik visualisasi perbandingan menggunakan **FL Chart**.
  - Daftar 5 produk terlaris berdasarkan kuantitas dan pendapatan.
  - Ekspor laporan berformat **PDF resmi (A4)** dan file **CSV**.
- **Hutang & Piutang**:
  - **Hutang Pelanggan**: pencatatan sisa hutang per faktur, tanggal jatuh tempo, status (Belum Lunas, Cicilan, Lunas), dan riwayat cicilan.
  - **Piutang / Hutang Supplier**: pelacakan tagihan faktur pembelian dan riwayat pembayaran cicilan vendor.
- **Biaya Operasional (Expenses)**:
  - Pencatatan biaya: Listrik PLN, Air PDAM, Sewa Tempat, Gaji Karyawan, Transportasi/BBM, Pemeliharaan, dan Operasional lainnya.
  - Mempengaruhi perhitungan laba bersih secara riil tanpa mendistorsi omzet penjualan.
- **Pelanggan & Pemasok (Suppliers)**:
  - Kelola kontak, alamat, total belanja, dan saldo tagihan aktif.
- **Multi-Cabang & Manajemen Karyawan**:
  - Manajemen beberapa cabang toko dengan peralihan cabang aktif.
  - Penetapan peran (*role assignment*) untuk Owner, Admin, dan Kasir.

---

## Tech Stack

| Komponen | Teknologi |
| :--- | :--- |
| **Framework** | Flutter 3.38+ (Dart 3.10+) |
| **Design System** | Material 3 (Forest Green Theme) |
| **State Management** | GetX (Controllers, Bindings, Dependency Injection, Routing) |
| **Penyimpanan Lokal** | SQLite via **Drift** & `drift_flutter` + `sqlite3_flutter_libs` |
| **Cloud Backend** | **Supabase** (PostgreSQL, Row Level Security, Realtime, Auth) |
| **Hardware Integration** | `mobile_scanner` (Barcode Kamera) & `flutter_blue_plus` (Bluetooth Thermal) |
| **Dokumen & Cetak** | `pdf` & `printing` |
| **Visualisasi Grafik** | `fl_chart` |
| **Utilitas** | `intl`, `uuid`, `csv`, `shared_preferences`, `connectivity_plus` |

---

## Arsitektur Proyek

Struktur modular *Clean Architecture* berbasis fitur:

```
lib/
├── main.dart                                # Entrypoint aplikasi & inisialisasi layanan
├── app/
│   ├── bindings/initial_binding.dart        # Dependency injection global GetX
│   ├── constants/                           # AppColors, AppConstants
│   ├── routes/                              # AppRoutes & AppPages
│   └── theme/app_theme.dart                 # Material 3 Forest Green Theme
├── core/
│   ├── database/                            # Drift SQLite schema & tables
│   ├── services/                            # Auth, Sync, Printer, Seeder, Supabase
│   └── utils/                               # CurrencyFormatter, DateFormatter, Validators
├── data/
│   └── repositories/                        # Pos, Product, Inventory, Report, Debt, Expense, dll.
└── features/
    ├── authentication/views/                # LoginView & modal reset password
    ├── onboarding/views/                    # LandingPageView & OnboardingView
    ├── dashboard/views/                     # Role-based DashboardView (Owner, Admin, Kasir)
    ├── cashier/views/                       # CashierView, Cart Drawer, Payment Sheet
    ├── barcode/views/                       # BarcodeScannerView (kamera & manual input)
    ├── products/views/                      # ProductListView & ProductFormView
    ├── inventory/views/                     # InventoryView (Audit Trail & Peringatan Stok)
    ├── stock_opname/views/                  # StockOpnameView (Verifikasi Fisik Rak)
    ├── reports/views/                       # ReportView & visualisasi grafik fl_chart
    ├── debts/views/                         # DebtView (Hutang pelanggan & supplier)
    ├── expenses/views/                      # ExpenseView (Pencatatan pengeluaran operasional)
    ├── customers/views/                     # CustomerView
    ├── suppliers/views/                     # SupplierView
    ├── employees/views/                     # EmployeeView
    ├── branches/views/                      # BranchView (Multi-cabang)
    ├── printer/views/                       # PrinterView (Pengaturan Bluetooth Thermal)
    ├── notifications/views/                 # NotificationView
    └── settings/views/                      # SettingsView & Akun Demo Switcher
```

---

## User Roles & Hak Akses

| Fitur / Modul | Owner | Admin | Kasir |
| :--- | :---: | :---: | :---: |
| Transaksi POS Kasir | ✓ | ✓ | ✓ |
| Scan Barcode Kamera & Cetak Struk | ✓ | ✓ | ✓ |
| Melihat Katalog Produk & Stok | ✓ | ✓ | ✓ |
| Tambah & Edit Produk | ✓ | ✓ | ✗ |
| Edit Harga Pokok (HPP) | ✓ | ✓ | ✗ |
| Hapus Produk | ✓ | ✗ | ✗ |
| Penyesuaian Stok & Stock Opname | ✓ | ✓ | ✗ |
| Mengelola Pemasok / Supplier | ✓ | ✓ | ✗ |
| Mengelola Pelanggan | ✓ | ✓ | ✓ |
| Laporan Laba Bersih & HPP Sensitif | ✓ | ✗ | ✗ |
| Laporan Transaksi Kasir Miliknya | ✓ | ✓ | ✓ |
| Kelola Akun Karyawan & Hak Akses | ✓ | ✗ | ✗ |
| Kelola Multi-Cabang | ✓ | ✗ | ✗ |
| Pengaturan Printer & Cloud Sync | ✓ | ✓ | ✓ |

---

## Akun Demo Pengujian

Aplikasi telah dilengkapi **One-Click Demo Switcher** baik pada halaman Login maupun halaman Pengaturan. Anda dapat berpindah peran secara instan untuk menguji seluruh hak akses:

| Peran | Nama Pengguna | Alamat Email | Password |
| :--- | :--- | :--- | :--- |
| **Owner** | Hendra Gunawan | `owner@kasirpro.id` | `password123` |
| **Admin** | Siti Rahma | `admin@kasirpro.id` | `password123` |
| **Kasir 1** | Dimas Pratama | `kasir1@kasirpro.id` | `password123` |
| **Kasir 2** | Anisa Bella | `kasir2@kasirpro.id` | `password123` |

Data toko demo **KasirPro Mart (Berkah Jaya)** mencakup:
- 2 Cabang (Pasar Minggu & Tebet Barat)
- 22+ Produk ritel Indonesia (Beras, Minyak, Gula, Indomie, Susu Ultra, Kopi Kapal Api, Lifebuoy, dll.)
- Kategori lengkap, pelanggan riil, supplier, catatan hutang aktif, dan transaksi riil.

---

## Database Schema & Migrasi Supabase

Schema SQL produksi dan data seed telah disediakan pada:
1. `supabase/migrations/20261104_init_schema.sql`
   - Berisi pembuatan ekstensi `uuid-ossp`, ENUM custom (`user_role`, `stock_movement_type`, dll.).
   - 22 Tabel relasional dengan foreign key, indeks performa, dan constraint unik.
   - Kebijakan isolasi multi-tenant **Row Level Security (RLS)**.
   - Fungsi tersimpan (*Stored Procedure*) `process_pos_transaction` untuk pengurangan stok atomik dan pencatatan audit.
2. `supabase/seeds/seed_demo_data.sql`
   - Data awal lengkap untuk database cloud Supabase.

### Menjalankan Migrasi ke Supabase:
1. Masuk ke [Dashboard Supabase](https://supabase.com).
2. Buka menu **SQL Editor**.
3. Salin isi file `supabase/migrations/20261104_init_schema.sql` dan klik **Run**.
4. Salin isi file `supabase/seeds/seed_demo_data.sql` dan klik **Run**.

---

## Sinkronisasi Cloud & Offline-First

KasirPro menggunakan pendekatan **Offline-First**:
- **SQLite (Drift)**: Seluruh transaksi kasir, perubahan stok, dan data operasional langsung disimpan secara lokal di perangkat. Aplikasi dapat digunakan sepenuhnya tanpa koneksi internet.
- **Antrean Mutasi (`sync_queue`)**: Setiap transaksi offline dicatat ke dalam antrean lokal lengkap dengan *idempotency key* unik untuk menjamin tidak ada duplikasi data.
- **Sinkronisasi Latar Belakang**: Ketika koneksi internet terdeteksi aktif via `connectivity_plus`, `SyncService` otomatis memproses antrean ke cloud Supabase.
- Pengguna dapat memantau status sinkronisasi (*Offline*, *Online*, *Syncing*, *Synced*) serta menekan tombol **"Sinkronkan Sekarang"** di menu Pengaturan.

---

## Panduan Instalasi & Menjalankan Aplikasi

### Prasyarat
- Flutter SDK (versi 3.24 atau lebih baru)
- Dart SDK (versi 3.5 atau lebih baru)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Android SDK (API level 23 atau lebih tinggi)

### Langkah Menjalankan:
1. **Clone atau buka repositori:**
   ```bash
   cd "c:\Aplikasi manajemen stok dan kasir UMKM"
   ```

2. **Unduh dependensi pub:**
   ```bash
   flutter pub get
   ```

3. **(Opsional) Konfigurasi Supabase Cloud:**
   Salin file `.env.example` menjadi `.env` atau jalankan aplikasi dengan parameter `--dart-define`:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key
   ```
   *Catatan: Jika dijalankan tanpa parameter di atas, aplikasi secara otomatis berjalan dalam mode Offline-First berkinerja penuh dengan database lokal SQLite!*

4. **Jalankan aplikasi di Emulator / Device Android:**
   ```bash
   flutter run
   ```

---

## Menjalankan Automated Tests

Aplikasi memiliki pengujian unit menyeluruh untuk memvalidasi:
- Perhitungan subtotal keranjang, diskon item, diskon transaksi, dan PPN 11%.
- Validasi pencegahan transaksi kurang bayar (*underpayment prevention*).
- Rumus finansial: Omzet, HPP, Laba Kotor, dan Laba Bersih.
- Pelunasan cicilan hutang pelanggan.
- Matriks izin hak akses peran (*Role Permissions Matrix*).

Jalankan perintah pengujian:
```bash
flutter test
```

Hasil uji:
```text
00:00 +0: POS Cart & Calculations Unit Tests CartItem calculates subtotal, total HPP, and profit correctly
00:00 +1: POS Cart & Calculations Unit Tests Tax and Grand Total Calculations (PPN 11%)
00:00 +2: POS Cart & Calculations Unit Tests Validates underpayment prevention logic
00:00 +3: Financial Formulas Unit Tests Omzet, HPP, Gross Profit, and Net Profit accuracy
00:00 +4: Financial Formulas Unit Tests Customer Debt Partial Payment Calculation
00:00 +5: Role Permissions Matrix Tests Owner has full access
00:00 +6: Role Permissions Matrix Tests Admin has operational access without sensitive profit financials
00:00 +7: Role Permissions Matrix Tests Cashier is restricted from HPP and financial reports
00:00 +8: App Constants and Currency Formatter Widget Verification
00:00 +9: All tests passed!
```

---

## Instruksi Build Android APK

Untuk mengompilasi APK siap pasang di perangkat Android:

### 1. Build Debug APK:
```bash
flutter build apk --debug
```
File APK biner berada di:  
`build/app/outputs/flutter-apk/app-debug.apk`

### 2. Build Release APK:
```bash
flutter build apk --release
```
File APK rilis berada di:  
`build/app/outputs/flutter-apk/app-release.apk`

---

## Troubleshooting

1. **Kamera Barcode Scanner Meminta Izin:**
   - Pastikan izin kamera telah disetujui pada dialog Android.
   - Jika kamera tidak tersedia (misal di emulator PC), gunakan tombol **"Ketik Barcode Manual"** yang telah disediakan pada tampilan scanner.
2. **Printer Thermal Bluetooth Tidak Terdeteksi:**
   - Nyalakan Bluetooth dan Layanan Lokasi pada smartphone Android Anda.
   - Tekan tombol **"Pindai Device"** pada halaman printer.
   - Anda juga dapat menekan tombol **"Uji Test Print Struk"** untuk melakukan simulasi cetak struk virtual kapan saja.
3. **Database Drift / Kode Generasi:**
   - Jika Anda menambahkan tabel baru pada `tables.dart`, jalankan pembuat kode:
     ```bash
     flutter pub run build_runner build --delete-conflicting-outputs
     ```
