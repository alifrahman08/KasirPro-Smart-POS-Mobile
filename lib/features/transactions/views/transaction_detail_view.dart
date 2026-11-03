import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/transaction_controller.dart';

class TransactionDetailView extends GetView<TransactionController> {
  const TransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Cetak Ulang Struk',
            onPressed: controller.reprintReceipt,
          ),
        ],
      ),
      body: Obx(() {
        final tx = controller.selectedTransaction.value;
        if (tx == null) {
          return const Center(child: Text('Data transaksi tidak ditemukan'));
        }

        if (controller.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(tx.totalAmount),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(tx.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(DateFormatter.formatDateTime(tx.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Items Purchased Table
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daftar Produk Terjual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Divider(height: 18),
                  ...controller.selectedItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('${item.quantity.toInt()} x ${CurrencyFormatter.format(item.sellPrice)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.subtotalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 18),
                  _buildSummaryRow('Subtotal', CurrencyFormatter.format(tx.subtotal)),
                  if (tx.discountAmount > 0)
                    _buildSummaryRow('Diskon', '-${CurrencyFormatter.format(tx.discountAmount)}', color: AppColors.error),
                  if (tx.taxAmount > 0)
                    _buildSummaryRow('PPN (11%)', CurrencyFormatter.format(tx.taxAmount)),
                  const Divider(height: 14),
                  _buildSummaryRow('Total', CurrencyFormatter.format(tx.totalAmount), isBold: true),
                  _buildSummaryRow('Metode Pembayaran', tx.paymentMethod),
                  _buildSummaryRow('Uang Diterima', CurrencyFormatter.format(tx.cashReceived)),
                  _buildSummaryRow('Kembalian', CurrencyFormatter.format(tx.changeAmount)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: controller.reprintReceipt,
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Cetak Ulang Struk Thermal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

