import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/expense_controller.dart';

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Toko'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadExpenses,
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Expense Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pengeluaran Operasional', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('Mengurangi laba kotor menjadi laba bersih', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                  ],
                ),
                Obx(
                  () => Text(
                    CurrencyFormatter.format(controller.totalExpenseAmount),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(
              () => Row(
                children: [
                  _buildCategoryChip('Semua', 'ALL'),
                  const SizedBox(width: 8),
                  ...controller.categories.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(c.$2, c.$1),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Expenses List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.expenses.isEmpty) {
                return const Center(child: Text('Belum ada catatan pengeluaran'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: controller.expenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final exp = controller.expenses[index];
                  return _buildExpenseCard(exp);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openAddExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Catat Pengeluaran'),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = controller.selectedCategoryFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) {
        controller.selectedCategoryFilter.value = value;
        controller.loadExpenses();
      },
    );
  }

  Widget _buildExpenseCard(Expense exp) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${exp.category} | ${DateFormatter.formatDate(exp.expenseDate)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${CurrencyFormatter.format(exp.amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.error),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                onPressed: () => controller.deleteExpense(exp.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openAddExpenseDialog(BuildContext context) {
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
              const Text('Catat Pengeluaran Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              // Category selector
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedCategory.value,
                  decoration: const InputDecoration(labelText: 'Kategori Biaya *'),
                  items: controller.categories.map((c) {
                    return DropdownMenuItem(value: c.$1, child: Text(c.$2));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedCategory.value = val;
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Biaya (IDR) *',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan Pengeluaran *',
                  hintText: 'Contoh: Bayar tagihan listrik bulan Mei',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final ok = await controller.saveExpense();
                  if (ok) Get.back();
                },
                child: const Text('Simpan Pengeluaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

