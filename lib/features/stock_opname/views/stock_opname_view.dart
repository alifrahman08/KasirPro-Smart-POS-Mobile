import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../controllers/stock_opname_controller.dart';

class StockOpnameView extends GetView<StockOpnameController> {
  const StockOpnameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Opname Fisik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            tooltip: 'Scan Barcode Hitung',
            onPressed: controller.scanBarcodeToCount,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner & Discrepancy counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bandingkan stok sistem dengan stok fisik rak',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: controller.discrepancyCount > 0 ? AppColors.warningContainer : AppColors.successContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${controller.discrepancyCount} Selisih',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: controller.discrepancyCount > 0 ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items Table
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.rows.isEmpty) {
                return const Center(child: Text('Tidak ada produk untuk di-opname'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                itemCount: controller.rows.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final row = controller.rows[index];
                  final diff = row.difference;

                  return Row(
                    children: [
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              'Sistem: ${row.product.currentStock.toInt()} ${row.product.unit}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      // Physical count input
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: row.controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            suffixText: row.product.unit,
                            suffixStyle: const TextStyle(fontSize: 10),
                          ),
                          onChanged: (val) => controller.updatePhysicalCount(index, val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Difference indicator
                      SizedBox(
                        width: 50,
                        child: Text(
                          diff == 0 ? '0' : (diff > 0 ? '+$diff' : '$diff'),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: diff == 0
                                ? AppColors.textTertiary
                                : (diff > 0 ? AppColors.success : AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      final ok = await controller.saveStockOpname();
                      if (ok) Get.back();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: controller.isSaving.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Selesaikan & Sesuaikan Stok Sistem',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

