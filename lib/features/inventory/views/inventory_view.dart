import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventaris & Stok'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Peringatan & Tindakan'),
              Tab(text: 'Riwayat Audit Stok'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.assignment_turned_in_outlined),
              tooltip: 'Stock Opname',
              onPressed: () => Get.toNamed(AppRoutes.stockOpname),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildActionsTab(context),
            _buildAuditHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openStockAdjustmentDialog(context, 'PURCHASE'),
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Stok Masuk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openStockAdjustmentDialog(context, 'ADJUSTMENT_MINUS'),
                icon: const Icon(Icons.remove_shopping_cart, size: 18),
                label: const Text('Stok Keluar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.stockOpname),
          icon: const Icon(Icons.checklist, size: 18),
          label: const Text('Mulai Stock Opname Fisik'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 24),

        // Section: Peringatan Stok Menipis & Habis
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Peringatan Stok Perlu Restock',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.lowStockProducts.length} Produk',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Obx(() {
          if (controller.lowStockProducts.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.success, size: 40),
                  SizedBox(height: 8),
                  Text('Semua stok aman!', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Tidak ada produk yang berada di bawah stok minimum.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.lowStockProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final prod = controller.lowStockProducts[index];
              final isZero = prod.currentStock <= 0;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isZero ? AppColors.error : AppColors.warning),
                ),
                child: Row(
                  children: [
                    Icon(
                      isZero ? Icons.error_outline : Icons.warning_amber_rounded,
                      color: isZero ? AppColors.error : AppColors.warning,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Batas Min: ${prod.minStock.toInt()} ${prod.unit}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isZero ? 'HABIS (0)' : '${prod.currentStock.toInt()} ${prod.unit}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isZero ? AppColors.error : AppColors.warning,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                          onPressed: () {
                            controller.selectedProduct.value = prod;
                            _openStockAdjustmentDialog(context, 'PURCHASE');
                          },
                          child: const Text('+ Restock', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildAuditHistoryTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.stockMovements.isEmpty) {
        return const Center(child: Text('Belum ada histori pergerakan stok'));
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.stockMovements.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final sm = controller.stockMovements[index];
          final isPositive = sm.quantityChanged > 0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.successContainer : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sm.movementType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sm.notes ?? 'Perubahan Stok',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      'Ref: ${sm.referenceId ?? '-'} | ${DateFormatter.formatDateTime(sm.createdAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${sm.quantityChanged.toInt()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    'Sisa: ${sm.remainingStock.toInt()}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  void _openStockAdjustmentDialog(BuildContext context, String type) {
    controller.selectedMovementType.value = type;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type == 'PURCHASE' ? 'Stok Masuk (Pembelian)' : 'Stok Keluar / Penyesuaian',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              // Product Dropdown
              Obx(() {
                return DropdownButtonFormField<Product>(
                  initialValue: controller.selectedProduct.value,
                  decoration: const InputDecoration(labelText: 'Pilih Produk *'),
                  items: controller.lowStockProducts.isNotEmpty
                      ? controller.lowStockProducts.map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList()
                      : null,
                  onChanged: (p) => controller.selectedProduct.value = p,
                );
              }),
              const SizedBox(height: 12),
              TextField(
                controller: controller.qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah Barang *', hintText: 'Contoh: 10'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.referenceController,
                decoration: const InputDecoration(labelText: 'No. Surat Jalan / Faktur', hintText: 'PO-XXXX'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.notesController,
                decoration: const InputDecoration(labelText: 'Catatan', hintText: 'Keterangan penyesuaian...'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final ok = await controller.submitStockAdjustment();
                  if (ok) Get.back();
                },
                child: const Text('Simpan Penyesuaian Stok'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

