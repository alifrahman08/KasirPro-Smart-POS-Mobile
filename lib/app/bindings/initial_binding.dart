import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/app_database.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/printer_service.dart';
import '../../core/services/sync_service.dart';
import '../../data/repositories/branch_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/employee_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/pos_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/supplier_repository.dart';

class InitialBinding extends Bindings {
  final AppDatabase database;
  final SharedPreferences prefs;

  InitialBinding({required this.database, required this.prefs});

  @override
  void dependencies() {
    // 1. Core Services
    Get.put<AppDatabase>(database, permanent: true);
    Get.put<SharedPreferences>(prefs, permanent: true);

    final syncService = Get.put<SyncService>(SyncService(database), permanent: true);
    Get.put<AuthService>(AuthService(db: database, prefs: prefs), permanent: true);
    Get.put<PrinterService>(PrinterService(prefs: prefs), permanent: true);

    // 2. Repositories
    Get.put<ProductRepository>(ProductRepository(db: database, syncService: syncService), permanent: true);
    Get.put<CategoryRepository>(CategoryRepository(db: database, syncService: syncService), permanent: true);
    Get.put<PosRepository>(PosRepository(db: database, syncService: syncService), permanent: true);
    Get.put<InventoryRepository>(InventoryRepository(db: database, syncService: syncService), permanent: true);
    Get.put<ReportRepository>(ReportRepository(db: database), permanent: true);
    Get.put<DebtRepository>(DebtRepository(db: database, syncService: syncService), permanent: true);
    Get.put<ExpenseRepository>(ExpenseRepository(db: database, syncService: syncService), permanent: true);
    Get.put<CustomerRepository>(CustomerRepository(db: database, syncService: syncService), permanent: true);
    Get.put<SupplierRepository>(SupplierRepository(db: database, syncService: syncService), permanent: true);
    Get.put<EmployeeRepository>(EmployeeRepository(db: database, syncService: syncService), permanent: true);
    Get.put<BranchRepository>(BranchRepository(db: database, syncService: syncService), permanent: true);
    Get.put<NotificationRepository>(NotificationRepository(db: database), permanent: true);
  }
}

