import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../database/app_database.dart';

class AuthService extends GetxService {
  final AppDatabase db;
  final SharedPreferences prefs;

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString userRole = 'owner'.obs; // 'owner', 'admin', 'cashier'
  final RxBool isLoggedIn = false.obs;
  final RxBool hasCompletedOnboarding = true.obs;
  final RxString activeBranchId = AppConstants.defaultBranchId.obs;
  final RxString activeBranchName = AppConstants.defaultBranchName.obs;

  AuthService({required this.db, required this.prefs});

  @override
  void onInit() {
    super.onInit();
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final onboarded = prefs.getBool(AppConstants.keyHasCompletedOnboarding) ?? true;
    hasCompletedOnboarding.value = onboarded;

    final sessionJson = prefs.getString(AppConstants.keyUserSession);
    if (sessionJson != null) {
      try {
        final data = jsonDecode(sessionJson) as Map<String, dynamic>;
        final user = await (db.select(db.users)..where((u) => u.id.equals(data['id']))).getSingleOrNull();
        if (user != null) {
          currentUser.value = user;
          userRole.value = user.role;
          isLoggedIn.value = true;
          return;
        }
      } catch (_) {}
    }

    // Default to Owner for instant preview if no session
    await loginAsDemo('owner');
  }

  // Permissions based on user role
  bool get isOwner => userRole.value == 'owner';
  bool get isAdmin => userRole.value == 'admin';
  bool get isCashier => userRole.value == 'cashier';

  bool get canViewProfits => isOwner;
  bool get canManageEmployees => isOwner;
  bool get canManageBranches => isOwner;
  bool get canManageProducts => isOwner || isAdmin;
  bool get canManageStock => isOwner || isAdmin;
  bool get canPerformCashierSale => true;
  bool get canEditHpp => isOwner || isAdmin;
  bool get canViewFinancialReports => isOwner;
  bool get canDeleteProducts => isOwner;
  bool get canDoStockOpname => isOwner || isAdmin;

  Future<void> loginAsDemo(String role) async {
    String email;
    switch (role) {
      case 'admin':
        email = AppConstants.demoAdminEmail;
        break;
      case 'cashier':
      case 'kasir':
        email = AppConstants.demoCashier1Email;
        break;
      case 'owner':
      default:
        email = AppConstants.demoOwnerEmail;
        break;
    }

    final user = await (db.select(db.users)..where((u) => u.email.equals(email))).getSingleOrNull();
    if (user != null) {
      currentUser.value = user;
      userRole.value = user.role;
      isLoggedIn.value = true;

      await prefs.setString(
        AppConstants.keyUserSession,
        jsonEncode({'id': user.id, 'email': user.email, 'role': user.role}),
      );
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    final user = await (db.select(db.users)..where((u) => u.email.equals(email.trim().toLowerCase()))).getSingleOrNull();
    if (user != null) {
      currentUser.value = user;
      userRole.value = user.role;
      isLoggedIn.value = true;

      await prefs.setString(
        AppConstants.keyUserSession,
        jsonEncode({'id': user.id, 'email': user.email, 'role': user.role}),
      );
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await prefs.remove(AppConstants.keyUserSession);
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  void switchBranch(String branchId, String branchName) {
    activeBranchId.value = branchId;
    activeBranchName.value = branchName;
  }
}

