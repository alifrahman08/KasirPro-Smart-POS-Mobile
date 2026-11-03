import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/cashier_controller.dart';

class CashierView extends GetView<CashierController> {
  const CashierView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kasir POS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Obx(
              () => Text(
                controller.authService.activeBranchName.value,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            tooltip: 'Scan Barcode',
            onPressed: controller.openBarcodeScanner,
          ),
          Obx(
            () => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => _openCartSheet(context),
                ),
                if (controller.totalItemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${controller.totalItemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Barcode Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari nama produk, SKU, atau barcode...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, size: 20, color: AppColors.primary),
                  onPressed: controller.openBarcodeScanner,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Categories Horizontal Chips
          SizedBox(
            height: 44,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Semua'),
                      selected: controller.selectedCategoryId.value == 'ALL',
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: controller.selectedCategoryId.value == 'ALL' ? AppColors.primaryDark : AppColors.textPrimary,
                        fontWeight: controller.selectedCategoryId.value == 'ALL' ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (_) => controller.filterByCategory('ALL'),
                    ),
                  ),
                  ...controller.categories.map((cat) {
                    final isSelected = controller.selectedCategoryId.value == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        onSelected: (_) => controller.filterByCategory(cat.id),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),

          const SizedBox(height: 8),

          // Products Catalog Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoadingProducts.value) {
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
                      const SizedBox(height: 4),
                      const Text(
                        'Coba kata kunci pencarian atau kategori lain',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.84,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return _buildProductCard(product);
                },
              );
            }),
          ),
        ],
      ),
      bottomSheet: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
            border: const Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.totalItemCount} Barang',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        CurrencyFormatter.format(controller.grandTotal),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openCartSheet(context),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('Lihat Keranjang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(160, 46),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(Product product) {
    final isOutOfStock = product.currentStock <= 0;
    final isLowStock = product.currentStock > 0 && product.currentStock <= product.minStock;

    return InkWell(
      onTap: () => controller.addToCart(product),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stock Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? AppColors.errorContainer
                        : isLowStock
                            ? AppColors.warningContainer
                            : AppColors.successContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOutOfStock
                        ? 'Habis'
                        : isLowStock
                            ? 'Sisa ${product.currentStock.toInt()}'
                            : 'Stok ${product.currentStock.toInt()}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock
                          ? AppColors.error
                          : isLowStock
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                  ),
                ),
                Text(
                  product.unit,
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
            const Spacer(),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.2),
            ),
            const SizedBox(height: 4),
            Text(
              product.sku,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              CurrencyFormatter.format(product.sellPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cart Sheet
  void _openCartSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Keranjang Belanja', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                    tooltip: 'Kosongkan Keranjang',
                    onPressed: () {
                      controller.clearCart();
                      Get.back();
                    },
                  ),
                ],
              ),
            ),

            // Cart Items List
            Expanded(
              child: Obx(() {
                if (controller.cartItems.isEmpty) {
                  return const Center(child: Text('Keranjang masih kosong'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${CurrencyFormatter.format(item.unitPrice)} / ${item.product.unit}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(item.subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Counter buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 22),
                              onPressed: () => controller.decrementQuantity(index),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
                              onPressed: () => controller.incrementQuantity(index),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              }),
            ),

            // Calculation Summary & Checkout button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(fontSize: 13)),
                        Obx(() => Text(CurrencyFormatter.format(controller.subtotal), style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('PPN (11%)', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 8),
                            Obx(
                              () => Switch.adaptive(
                                value: controller.isTaxEnabled.value,
                                activeTrackColor: AppColors.primary,
                                onChanged: (val) => controller.isTaxEnabled.value = val,
                              ),
                            ),
                          ],
                        ),
                        Obx(() => Text(CurrencyFormatter.format(controller.taxAmount), style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Obx(
                          () => Text(
                            CurrencyFormatter.format(controller.grandTotal),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _openPaymentDialog(context);
                      },
                      child: const Text('Pilih Metode Pembayaran'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Payment Dialog
  void _openPaymentDialog(BuildContext context) {
    controller.cashReceived.value = 0.0;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pembayaran Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 12),
            // Total display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Total Tagihan', style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 13)),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      CurrencyFormatter.format(controller.grandTotal),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            // Payment method selector
            Obx(
              () => Row(
                children: [
                  _buildPaymentChip('Tunai', 'CASH', Icons.payments_outlined),
                  const SizedBox(width: 8),
                  _buildPaymentChip('QRIS', 'QRIS', Icons.qr_code_2),
                  const SizedBox(width: 8),
                  _buildPaymentChip('Transfer', 'TRANSFER', Icons.account_balance_outlined),
                  const SizedBox(width: 8),
                  _buildPaymentChip('Debit', 'DEBIT', Icons.credit_card),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  if (controller.selectedPaymentMethod.value == 'CASH') {
                    return _buildCashPaymentSection();
                  } else if (controller.selectedPaymentMethod.value == 'QRIS') {
                    return _buildQrisPaymentSection();
                  } else {
                    return _buildTransferDebitPaymentSection();
                  }
                }),
              ),
            ),
            // Checkout execution button
            Obx(
              () => ElevatedButton(
                onPressed: controller.canCompletePayment && !controller.isProcessingPayment.value
                    ? () async {
                        final success = await controller.processCheckout();
                        if (success) {
                          Get.back(); // close payment sheet
                          _showSuccessReceiptDialog();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: controller.isProcessingPayment.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Selesaikan Pembayaran & Cetak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentChip(String label, String value, IconData icon) {
    final isSelected = controller.selectedPaymentMethod.value == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          controller.selectedPaymentMethod.value = value;
          if (value == 'CASH') {
            controller.cashReceived.value = 0.0;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.textPrimary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashPaymentSection() {
    final quickCashOptions = [
      controller.grandTotal,
      20000.0,
      50000.0,
      100000.0,
      200000.0,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nominal Uang Diterima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'Rp ',
            hintText: '0',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => controller.cashReceived.value = 0.0,
            ),
          ),
          onChanged: (val) {
            final parsed = CurrencyFormatter.parse(val);
            controller.cashReceived.value = parsed;
          },
        ),
        const SizedBox(height: 10),
        // Quick cash chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickCashOptions.map((amount) {
            final isExact = amount == controller.grandTotal;
            return ActionChip(
              label: Text(
                isExact ? 'Uang Pas' : CurrencyFormatter.format(amount),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              onPressed: () => controller.setQuickCash(amount),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Kembalian calculation
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kembalian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Obx(
                () => Text(
                  CurrencyFormatter.format(controller.changeAmount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.changeAmount >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQrisPaymentSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 120, color: AppColors.textPrimary),
                Text('QRIS Dinamis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Scan dengan GoPay, OVO, BCA, dll', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Tunjukkan QRIS kepada pelanggan untuk melakukan pembayaran.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTransferDebitPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catatan Bank / No. Referensi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Contoh: Transfer BCA a/n Budi / No. Kartu Mandiri',
          ),
          onChanged: (val) => controller.transactionNotes.value = val,
        ),
      ],
    );
  }

  void _showSuccessReceiptDialog() {
    final result = controller.lastCheckoutResult.value;
    if (result == null) return;

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.successContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 12),
            const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(result.transaction.invoiceNumber, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          CurrencyFormatter.format(result.transaction.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (result.transaction.paymentMethod == 'CASH') ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kembalian', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            CurrencyFormatter.format(result.transaction.changeAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                controller.printerService.printReceipt(
                  transaction: result.transaction,
                  items: result.items,
                  storeName: AppConstants.defaultStoreName,
                  storeAddress: AppConstants.defaultStoreAddress,
                  cashierName: controller.authService.currentUser.value?.fullName,
                );
              },
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Cetak Struk Thermal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Transaksi Baru'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

