import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/branch_repository.dart';
import '../../../data/repositories/employee_repository.dart';

class EmployeeController extends GetxController {
  final EmployeeRepository employeeRepository = Get.find<EmployeeRepository>();
  final BranchRepository branchRepository = Get.find<BranchRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<User> employees = <User>[].obs;
  final RxList<Branch> branches = <Branch>[].obs;
  final RxBool isLoading = false.obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final RxString selectedRole = 'cashier'.obs;
  final RxString selectedBranchId = ''.obs;
  User? editingUser;

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
    loadBranches();
  }

  Future<void> loadEmployees() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final result = await employeeRepository.getEmployees(businessId);
      employees.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBranches() async {
    final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
    final b = await branchRepository.getBranches(businessId);
    branches.value = b;
    if (b.isNotEmpty && selectedBranchId.value.isEmpty) {
      selectedBranchId.value = b.first.id;
    }
  }

  void prepareCreate() {
    editingUser = null;
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    selectedRole.value = 'cashier';
  }

  void prepareEdit(User u) {
    editingUser = u;
    fullNameController.text = u.fullName;
    emailController.text = u.email;
    phoneController.text = u.phone ?? '';
    selectedRole.value = u.role;
    selectedBranchId.value = u.branchId ?? (branches.isNotEmpty ? branches.first.id : '');
  }

  Future<bool> saveEmployee() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar('Data Belum Lengkap', 'Nama dan Email wajib diisi.');
      return false;
    }

    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;

      if (editingUser == null) {
        await employeeRepository.addEmployee(
          businessId: businessId,
          fullName: name,
          email: email,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
          role: selectedRole.value,
          branchId: selectedBranchId.value.isNotEmpty ? selectedBranchId.value : null,
        );
        Get.snackbar('Berhasil', 'Karyawan berhasil didaftarkan');
      } else {
        await employeeRepository.updateEmployee(
          id: editingUser!.id,
          fullName: name,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
          role: selectedRole.value,
          branchId: selectedBranchId.value.isNotEmpty ? selectedBranchId.value : null,
        );
        Get.snackbar('Berhasil', 'Data karyawan diperbarui');
      }

      await loadEmployees();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }
}

