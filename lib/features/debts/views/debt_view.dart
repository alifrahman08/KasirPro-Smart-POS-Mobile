import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/debt_controller.dart';

class DebtView extends GetView<DebtController> {
  const DebtView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hutang & Piutang'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Hutang Pelanggan'),
              Tab(text: 'Hutang ke Supplier'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCustomerDebtsTab(context),
            _buildSupplierPayablesTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDebtsTab(BuildContext context) {
    return Column(
      children: [
        // Summary Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceVariant,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Hutang Pelanggan Aktif', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('Piutang yang belum dilunasi', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                ],
              ),
              Obx(
                () => Text(
                  CurrencyFormatter.format(controller.totalActiveCustomerDebt),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error),
                ),
              ),
            ],
          ),
        ),

        // Debt Items
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (controller.customerDebts.isEmpty) {
              return const Center(child: Text('Tidak ada catatan hutang pelanggan'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.customerDebts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final debt = controller.customerDebts[index];
                return _buildDebtCard(debt, onPay: () => _openPaymentDialog(context, debt.id, debt.remainingDebt, isCustomer: true));
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSupplierPayablesTab(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceVariant,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Hutang ke Supplier', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('Tagihan faktur pembelian aktif', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                ],
              ),
              Obx(
                () => Text(
                  CurrencyFormatter.format(controller.totalActiveSupplierPayable),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (controller.supplierReceivables.isEmpty) {
              return const Center(child: Text('Tidak ada catatan hutang ke supplier'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.supplierReceivables.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rec = controller.supplierReceivables[index];
                return _buildReceivableCard(rec, onPay: () => _openPaymentDialog(context, rec.id, rec.remainingBill, isCustomer: false));
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDebtCard(Debt debt, {required VoidCallback onPay}) {
    final isPaid = debt.status == 'PAID' || debt.remainingDebt <= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(debt.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.successContainer : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  debt.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sisa Hutang: ${CurrencyFormatter.format(debt.remainingDebt)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.error)),
                  Text('Total: ${CurrencyFormatter.format(debt.totalDebt)} (Dibayar: ${CurrencyFormatter.format(debt.paidAmount)})',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              if (!isPaid)
                ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Bayar Cicilan', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Jatuh Tempo: ${DateFormatter.formatDate(debt.dueDate)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivableCard(Receivable rec, {required VoidCallback onPay}) {
    final isPaid = rec.status == 'PAID' || rec.remainingBill <= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rec.purchaseReference, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.successContainer : AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rec.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sisa Tagihan: ${CurrencyFormatter.format(rec.remainingBill)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.warning)),
                  Text('Total Faktur: ${CurrencyFormatter.format(rec.totalBill)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              if (!isPaid)
                ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Bayar Tagihan', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Jatuh Tempo: ${DateFormatter.formatDate(rec.dueDate)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  void _openPaymentDialog(BuildContext context, String id, double remaining, {required bool isCustomer}) {
    controller.paymentAmountController.text = remaining.toInt().toString();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCustomer ? 'Pembayaran Hutang Pelanggan' : 'Pelunasan Tagihan Supplier',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sisa saldo: ${CurrencyFormatter.format(remaining)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.paymentAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal Pembayaran *',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.paymentNotesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Contoh: Transfer Bank / Tunai di kasir',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool ok = false;
                if (isCustomer) {
                  ok = await controller.payCustomerDebt(id);
                } else {
                  ok = await controller.paySupplierReceivable(id);
                }
                if (ok) Get.back();
              },
              child: const Text('Konfirmasi & Simpan Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}

