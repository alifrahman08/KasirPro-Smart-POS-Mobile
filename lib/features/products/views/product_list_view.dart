import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/product_controller.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog & Stok Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Ekspor CSV',
            onPressed: controller.exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (val) {
                controller.searchQuery.value = val;
                controller.loadProducts();
              },
              decoration: const InputDecoration(
                hintText: 'Cari nama produk, SKU, barcode...',
                prefixIcon: Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Stock Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => Row(
                children: [
                  _buildStockChip('Semua', 'ALL'),
                  const SizedBox(width: 8),
                  _buildStockChip('Stok Menipis', 'LOW', color: AppColors.warning),
                  const SizedBox(width: 8),
                  _buildStockChip('Stok Habis', 'OUT', color: AppColors.error),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada produk ditemukan',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadProducts,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: controller.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _buildProductItem(product);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (!controller.authService.canManageProducts) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            controller.prepareCreate();
            Get.toNamed(AppRoutes.productForm);
          },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Produk'),
        );
      }),
    );
  }

  Widget _buildStockChip(String label, String value, {Color? color}) {
    final isSelected = controller.selectedStockFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color?.withValues(alpha: 0.2) ?? AppColors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppColors.primaryDark) : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) {
        controller.selectedStockFilter.value = value;
        controller.loadProducts();
      },
    );
  }

  Widget _buildProductItem(Product product) {
    final isOutOfStock = product.currentStock <= 0;
    final isLowStock = product.currentStock > 0 && product.currentStock <= product.minStock;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon / Image placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU: ${product.sku} | Barcode: ${product.barcode ?? '-'}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      CurrencyFormatter.format(product.sellPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                    if (controller.authService.canViewProfits)
                      Text(
                        'HPP: ${CurrencyFormatter.format(product.buyPrice)}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Stock & Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? AppColors.errorContainer
                      : isLowStock
                          ? AppColors.warningContainer
                          : AppColors.successContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${product.currentStock.toInt()} ${product.unit}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock
                        ? AppColors.error
                        : isLowStock
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                ),
              ),
              if (controller.authService.canManageProducts)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                  onSelected: (val) {
                    if (val == 'edit') {
                      controller.prepareEdit(product);
                      Get.toNamed(AppRoutes.productForm);
                    } else if (val == 'delete') {
                      controller.deleteProduct(product);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Produk'),
                        ],
                      ),
                    ),
                    if (controller.authService.canDeleteProducts)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

