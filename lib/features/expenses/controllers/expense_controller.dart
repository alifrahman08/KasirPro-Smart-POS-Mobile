import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository expenseRepository = Get.find<ExpenseRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<Expense> expenses = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategoryFilter = 'ALL'.obs;

  // Add Expense form
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedCategory = 'OPERATIONAL'.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final categories = [
    ('OPERATIONAL', 'Operasional'),
    ('ELECTRICITY', 'Listrik PLN'),
    ('WATER', 'Air PDAM'),
    ('RENT', 'Sewa Tempat'),
    ('SALARY', 'Gaji Karyawan'),
    ('TRANSPORT', 'Transportasi / BBM'),
    ('MAINTENANCE', 'Perawatan / Service'),
    ('OTHER', 'Lain-lain'),
  ];

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final category = selectedCategoryFilter.value == 'ALL' ? null : selectedCategoryFilter.value;
      final result = await expenseRepository.getExpenses(businessId: businessId, category: category);
      expenses.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  double get totalExpenseAmount {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<bool> saveExpense() async {
    final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar('Nominal Tidak Valid', 'Nominal pengeluaran harus lebih besar dari 0.');
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Keterangan Wajib', 'Masukkan keterangan pengeluaran.');
      return false;
    }

    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final branchId = authService.activeBranchId.value;
      final userId = authService.currentUser.value?.id;

      await expenseRepository.addExpense(
        businessId: businessId,
        branchId: branchId,
        category: selectedCategory.value,
        amount: amount,
        date: selectedDate.value,
        description: descriptionController.text.trim(),
        userId: userId,
      );

      Get.snackbar('Berhasil', 'Pengeluaran operasional berhasil dicatat.');
      amountController.clear();
      descriptionController.clear();
      selectedDate.value = DateTime.now();

      await loadExpenses();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }

  Future<void> deleteExpense(String id) async {
    await expenseRepository.deleteExpense(id);
    await loadExpenses();
    Get.snackbar('Dihapus', 'Data pengeluaran berhasil dihapus.');
  }
}

