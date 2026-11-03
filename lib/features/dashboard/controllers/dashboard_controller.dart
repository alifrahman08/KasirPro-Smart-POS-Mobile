import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/repositories/debt_repository.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/report_repository.dart';

class DashboardController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final PosRepository posRepository = Get.find<PosRepository>();
  final ProductRepository productRepository = Get.find<ProductRepository>();
  final ReportRepository reportRepository = Get.find<ReportRepository>();
  final DebtRepository debtRepository = Get.find<DebtRepository>();
  final PrinterService printerService = Get.find<PrinterService>();

  final RxInt selectedNavIndex = 0.obs;

  // Real database metrics (no hardcoding!)
  final RxDouble todaySales = 0.0.obs;
  final RxDouble todayProfit = 0.0.obs;
  final RxInt todayTransactionsCount = 0.obs;
  final RxInt totalProductsCount = 0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxDouble totalCustomerDebt = 0.0.obs;
  final RxDouble totalSupplierPayable = 0.0.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardMetrics();
  }

  Future<void> loadDashboardMetrics() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // 1. Today financial report
      final rep = await reportRepository.getFinancialReport(
        businessId: businessId,
        startDate: startOfToday,
        endDate: endOfToday,
      );
      todaySales.value = rep.omzet;
      todayProfit.value = rep.netProfit;
      todayTransactionsCount.value = rep.transactionCount;

      // 2. Product and low stock metrics
      final allProds = await productRepository.getProducts(businessId: businessId);
      totalProductsCount.value = allProds.length;
      lowStockCount.value = allProds.where((p) => p.currentStock <= p.minStock).length;

      // 3. Debts & Receivables metrics
      final debts = await debtRepository.getDebts(businessId);
      totalCustomerDebt.value = debts.fold(0.0, (sum, d) => sum + d.remainingDebt);

      final recs = await debtRepository.getReceivables(businessId);
      totalSupplierPayable.value = recs.fold(0.0, (sum, r) => sum + r.remainingBill);

      // 4. Recent transactions
      final recent = await posRepository.getRecentTransactions(
        businessId: businessId,
        limit: 5,
      );
      recentTransactions.value = recent;
    } finally {
      isLoading.value = false;
    }
  }

  void onNavIndexChanged(int index) {
    selectedNavIndex.value = index;
  }
}

