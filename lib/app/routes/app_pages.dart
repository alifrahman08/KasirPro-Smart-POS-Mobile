import 'package:get/get.dart';
import '../../features/authentication/views/login_view.dart';
import '../../features/barcode/controllers/barcode_scanner_controller.dart';
import '../../features/barcode/views/barcode_scanner_view.dart';
import '../../features/branches/controllers/branch_controller.dart';
import '../../features/branches/views/branch_view.dart';
import '../../features/cashier/controllers/cashier_controller.dart';
import '../../features/cashier/views/cashier_view.dart';
import '../../features/customers/controllers/customer_controller.dart';
import '../../features/customers/views/customer_view.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/debts/controllers/debt_controller.dart';
import '../../features/debts/views/debt_view.dart';
import '../../features/employees/controllers/employee_controller.dart';
import '../../features/employees/views/employee_view.dart';
import '../../features/expenses/controllers/expense_controller.dart';
import '../../features/expenses/views/expense_view.dart';
import '../../features/inventory/controllers/inventory_controller.dart';
import '../../features/inventory/views/inventory_view.dart';
import '../../features/notifications/controllers/notification_controller.dart';
import '../../features/notifications/views/notification_view.dart';
import '../../features/onboarding/views/landing_page_view.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/printer/views/printer_view.dart';
import '../../features/products/controllers/product_controller.dart';
import '../../features/products/views/product_form_view.dart';
import '../../features/products/views/product_list_view.dart';
import '../../features/reports/controllers/report_controller.dart';
import '../../features/reports/views/report_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/stock_opname/controllers/stock_opname_controller.dart';
import '../../features/stock_opname/views/stock_opname_view.dart';
import '../../features/suppliers/controllers/supplier_controller.dart';
import '../../features/suppliers/views/supplier_view.dart';
import '../../features/transactions/controllers/transaction_controller.dart';
import '../../features/transactions/views/transaction_detail_view.dart';
import '../../features/transactions/views/transaction_list_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.landing;

  static final routes = [
    GetPage(
      name: AppRoutes.landing,
      page: () => const LandingPageView(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
        Get.lazyPut<CashierController>(() => CashierController());
        Get.lazyPut<ProductController>(() => ProductController());
        Get.lazyPut<TransactionController>(() => TransactionController());
        Get.lazyPut<InventoryController>(() => InventoryController());
        Get.lazyPut<ReportController>(() => ReportController());
        Get.lazyPut<SupplierController>(() => SupplierController());
      }),
    ),
    GetPage(
      name: AppRoutes.cashier,
      page: () => const CashierView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CashierController>(() => CashierController());
      }),
    ),
    GetPage(
      name: AppRoutes.barcodeScanner,
      page: () => const BarcodeScannerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BarcodeScannerController>(() => BarcodeScannerController());
      }),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductController>(() => ProductController());
      }),
    ),
    GetPage(
      name: AppRoutes.productForm,
      page: () => const ProductFormView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductController>(() => ProductController());
      }),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TransactionController>(() => TransactionController());
      }),
    ),
    GetPage(
      name: AppRoutes.transactionDetail,
      page: () => const TransactionDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TransactionController>(() => TransactionController());
      }),
    ),
    GetPage(
      name: AppRoutes.inventory,
      page: () => const InventoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InventoryController>(() => InventoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.stockOpname,
      page: () => const StockOpnameView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StockOpnameController>(() => StockOpnameController());
      }),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportController>(() => ReportController());
      }),
    ),
    GetPage(
      name: AppRoutes.debts,
      page: () => const DebtView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DebtController>(() => DebtController());
      }),
    ),
    GetPage(
      name: AppRoutes.expenses,
      page: () => const ExpenseView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ExpenseController>(() => ExpenseController());
      }),
    ),
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomerController>(() => CustomerController());
      }),
    ),
    GetPage(
      name: AppRoutes.suppliers,
      page: () => const SupplierView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SupplierController>(() => SupplierController());
      }),
    ),
    GetPage(
      name: AppRoutes.employees,
      page: () => const EmployeeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeeController>(() => EmployeeController());
      }),
    ),
    GetPage(
      name: AppRoutes.branches,
      page: () => const BranchView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BranchController>(() => BranchController());
      }),
    ),
    GetPage(
      name: AppRoutes.printer,
      page: () => const PrinterView(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationController>(() => NotificationController());
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
    ),
  ];
}

