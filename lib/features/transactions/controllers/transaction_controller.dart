import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/repositories/pos_repository.dart';

class TransactionController extends GetxController {
  final PosRepository posRepository = Get.find<PosRepository>();
  final AuthService authService = Get.find<AuthService>();
  final PrinterService printerService = Get.find<PrinterService>();

  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Detail view state
  final Rx<Transaction?> selectedTransaction = Rx<Transaction?>(null);
  final RxList<TransactionItem> selectedItems = <TransactionItem>[].obs;
  final RxBool isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      // If cashier, can optionally restrict to own transactions if configured
      final cashierId = authService.isCashier ? authService.currentUser.value?.id : null;

      final result = await posRepository.getRecentTransactions(
        businessId: businessId,
        cashierId: cashierId,
        limit: 100,
      );

      if (searchQuery.value.trim().isNotEmpty) {
        final q = searchQuery.value.trim().toLowerCase();
        transactions.value = result.where((t) => t.invoiceNumber.toLowerCase().contains(q)).toList();
      } else {
        transactions.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openTransactionDetail(Transaction tx) async {
    selectedTransaction.value = tx;
    isLoadingDetail.value = true;
    try {
      final items = await posRepository.getTransactionItems(tx.id);
      selectedItems.value = items;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> reprintReceipt() async {
    final tx = selectedTransaction.value;
    if (tx == null) return;

    await printerService.printReceipt(
      transaction: tx,
      items: selectedItems.toList(),
      storeName: AppConstants.defaultStoreName,
      storeAddress: AppConstants.defaultStoreAddress,
    );
  }
}

