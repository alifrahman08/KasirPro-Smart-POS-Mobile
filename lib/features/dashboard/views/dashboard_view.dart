import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../cashier/views/cashier_view.dart';
import '../../inventory/views/inventory_view.dart';
import '../../products/views/product_list_view.dart';
import '../../reports/views/report_view.dart';
import '../../settings/views/settings_view.dart';
import '../../suppliers/views/supplier_view.dart';
import '../../transactions/views/transaction_list_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = controller.authService.userRole.value;

      List<Widget> pages;
      List<NavigationDestination> destinations;

      if (role == 'owner') {
        pages = [
          _buildOwnerHome(context),
          const TransactionListView(),
          const ProductListView(),
          const ReportView(),
          const SettingsView(),
        ];
        destinations = const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ];
      } else if (role == 'admin') {
        pages = [
          _buildAdminHome(context),
          const ProductListView(),
          const InventoryView(),
          const SupplierView(),
          const SettingsView(),
        ];
        destinations = const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.warehouse_outlined), selectedIcon: Icon(Icons.warehouse), label: 'Stok'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: 'Supplier'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ];
      } else {
        // Cashier role
        pages = [
          _buildCashierHome(context),
          const CashierView(),
          const TransactionListView(),
          const SettingsView(),
        ];
        destinations = const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Kasir POS'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ];
      }

      final currentIndex = controller.selectedNavIndex.value;
      final safeIndex = currentIndex < pages.length ? currentIndex : 0;

      return Scaffold(
        body: IndexedStack(
          index: safeIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: safeIndex,
          onDestinationSelected: controller.onNavIndexChanged,
          destinations: destinations,
        ),
      );
    });
  }

  // 1. OWNER HOME
  Widget _buildOwnerHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.defaultStoreName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Obx(
              () => Text(
                '${controller.authService.activeBranchName.value} • Owner: ${controller.authService.currentUser.value?.fullName ?? 'Hendra'}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadDashboardMetrics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadDashboardMetrics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Penjualan Hari Ini & Laba Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PENJUALAN HARI INI', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      CurrencyFormatter.format(controller.todaySales.value),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Keuntungan Bersih', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Obx(
                            () => Text(
                              CurrencyFormatter.format(controller.todayProfit.value),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Transaksi', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Obx(
                            () => Text(
                              '${controller.todayTransactionsCount.value} Transaksi',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Hutang & Piutang Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.debts),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline, size: 14, color: AppColors.error),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Hutang Pelanggan',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(controller.totalCustomerDebt.value),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.debts),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.warning),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Hutang ke Supplier',
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(controller.totalSupplierPayable.value),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warning),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions Menu Grid
            const Text('Menu Operasional & Manajemen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              children: [
                _buildActionTile('Kasir POS', Icons.point_of_sale, AppColors.primary, () => Get.toNamed(AppRoutes.cashier)),
                _buildActionTile('Scan', Icons.qr_code_scanner, AppColors.secondary, () => Get.toNamed(AppRoutes.barcodeScanner)),
                _buildActionTile('Stok', Icons.warehouse, Colors.teal, () => Get.toNamed(AppRoutes.inventory)),
                _buildActionTile('Opname', Icons.checklist, Colors.indigo, () => Get.toNamed(AppRoutes.stockOpname)),
                _buildActionTile('Pengeluaran', Icons.receipt_long, Colors.redAccent, () => Get.toNamed(AppRoutes.expenses)),
                _buildActionTile('Pelanggan', Icons.people_alt_outlined, Colors.blueGrey, () => Get.toNamed(AppRoutes.customers)),
                _buildActionTile('Supplier', Icons.local_shipping, Colors.deepOrange, () => Get.toNamed(AppRoutes.suppliers)),
                _buildActionTile('Karyawan', Icons.badge_outlined, Colors.purple, () => Get.toNamed(AppRoutes.employees)),
              ],
            ),

            const SizedBox(height: 20),

            // Transaksi Terakhir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transaksi Terbaru Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                TextButton(
                  onPressed: () => controller.selectedNavIndex.value = 1,
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(() {
              if (controller.recentTransactions.isEmpty) {
                return const Center(child: Text('Belum ada transaksi'));
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.recentTransactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final tx = controller.recentTransactions[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${tx.paymentMethod} • ${DateFormatter.formatTime(tx.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(tx.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // 2. ADMIN HOME
  Widget _buildAdminHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.defaultStoreName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Obx(
              () => Text(
                'Admin Operasional • ${controller.authService.activeBranchName.value}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Admin Overview Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Produk', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.totalProductsCount.value}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stok Perlu Restock', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.lowStockCount.value} Produk',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text('Aktivitas Operasional Harian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildBigActionCard('Penerimaan Stok', 'Input barang dari supplier', Icons.add_shopping_cart, AppColors.primary, () => Get.toNamed(AppRoutes.inventory)),
              _buildBigActionCard('Stock Opname', 'Verifikasi stok fisik rak', Icons.checklist, AppColors.secondary, () => Get.toNamed(AppRoutes.stockOpname)),
              _buildBigActionCard('Kelola Produk', 'Tambah & edit harga', Icons.inventory_2_outlined, Colors.teal, () => controller.selectedNavIndex.value = 1),
              _buildBigActionCard('Pemasok / Supplier', 'Daftar vendor toko', Icons.local_shipping_outlined, Colors.deepOrange, () => controller.selectedNavIndex.value = 3),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.cashier),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Buka Kasir POS Penjualan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  // 3. KASIR HOME
  Widget _buildCashierHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.defaultStoreName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Obx(
              () => Text(
                'Kasir: ${controller.authService.currentUser.value?.fullName ?? 'Dimas'}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Status Printer',
            onPressed: () => Get.toNamed(AppRoutes.printer),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Shift summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RINGKASAN SHIFT KASIR HARI INI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 6),
                Obx(
                  () => Text(
                    CurrencyFormatter.format(controller.todaySales.value),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '${controller.todayTransactionsCount.value} Transaksi Selesai',
                    style: const TextStyle(fontSize: 13, color: AppColors.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Big POS launch CTA
          ElevatedButton.icon(
            onPressed: () => controller.selectedNavIndex.value = 1,
            icon: const Icon(Icons.shopping_cart_checkout, size: 24),
            label: const Text('Mulai Transaksi Baru (Kasir)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.barcodeScanner),
            icon: const Icon(Icons.qr_code_scanner, size: 20),
            label: const Text('Pindai Barcode Produk'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const SizedBox(height: 24),

          // Printer status indicator
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.print, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Printer Struk Thermal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Obx(() => Text(controller.printerService.selectedPrinterName.value, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.printer),
                  child: const Text('Ubah'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBigActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

