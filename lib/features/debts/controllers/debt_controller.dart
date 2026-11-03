import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/debt_repository.dart';

class DebtController extends GetxController {
  final DebtRepository debtRepository = Get.find<DebtRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<Debt> customerDebts = <Debt>[].obs;
  final RxList<Receivable> supplierReceivables = <Receivable>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedStatusFilter = 'ALL'.obs; // ALL, UNPAID, PARTIAL, PAID

  // Payment dialog form
  final paymentAmountController = TextEditingController();
  final paymentNotesController = TextEditingController();
  final RxString selectedPaymentMethod = 'CASH'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  Future<void> loadDebts() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final status = selectedStatusFilter.value == 'ALL' ? null : selectedStatusFilter.value;

      final debts = await debtRepository.getDebts(businessId, status: status);
      customerDebts.value = debts;

      final recs = await debtRepository.getReceivables(businessId, status: status);
      supplierReceivables.value = recs;
    } finally {
      isLoading.value = false;
    }
  }

  double get totalActiveCustomerDebt {
    return customerDebts.fold(0.0, (sum, d) => sum + d.remainingDebt);
  }

  double get totalActiveSupplierPayable {
    return supplierReceivables.fold(0.0, (sum, r) => sum + r.remainingBill);
  }

  Future<bool> payCustomerDebt(String debtId) async {
    final amount = double.tryParse(paymentAmountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar('Nominal Tidak Valid', 'Masukkan jumlah pembayaran yang valid.');
      return false;
    }

    try {
      await debtRepository.addDebtPayment(
        debtId: debtId,
        amount: amount,
        paymentMethod: selectedPaymentMethod.value,
        notes: paymentNotesController.text.trim().isNotEmpty ? paymentNotesController.text.trim() : 'Pembayaran Cicilan',
      );

      Get.snackbar('Pembayaran Berhasil', 'Pembayaran hutang pelanggan berhasil dicatat.');
      paymentAmountController.clear();
      paymentNotesController.clear();

      await loadDebts();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }

  Future<bool> paySupplierReceivable(String receivableId) async {
    final amount = double.tryParse(paymentAmountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar('Nominal Tidak Valid', 'Masukkan jumlah pembayaran yang valid.');
      return false;
    }

    try {
      await debtRepository.addReceivablePayment(
        receivableId: receivableId,
        amount: amount,
        paymentMethod: selectedPaymentMethod.value,
        notes: paymentNotesController.text.trim().isNotEmpty ? paymentNotesController.text.trim() : 'Pembayaran Cicilan ke Supplier',
      );

      Get.snackbar('Pembayaran Berhasil', 'Pembayaran hutang ke supplier berhasil dicatat.');
      paymentAmountController.clear();
      paymentNotesController.clear();

      await loadDebts();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }
}

