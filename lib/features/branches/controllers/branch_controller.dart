import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/branch_repository.dart';

class BranchController extends GetxController {
  final BranchRepository branchRepository = Get.find<BranchRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<Branch> branches = <Branch>[].obs;
  final RxBool isLoading = false.obs;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  Branch? editingBranch;

  @override
  void onInit() {
    super.onInit();
    loadBranches();
  }

  Future<void> loadBranches() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final result = await branchRepository.getBranches(businessId);
      branches.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void switchActiveBranch(Branch branch) {
    authService.switchBranch(branch.id, branch.name);
    Get.snackbar('Cabang Aktif Berubah', 'Saat ini beroperasi di: ${branch.name}', snackPosition: SnackPosition.BOTTOM);
  }

  void prepareCreate() {
    editingBranch = null;
    nameController.clear();
    addressController.clear();
    phoneController.clear();
  }

  void prepareEdit(Branch b) {
    editingBranch = b;
    nameController.text = b.name;
    addressController.text = b.address ?? '';
    phoneController.text = b.phone ?? '';
  }

  Future<bool> saveBranch() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Nama Wajib', 'Masukkan nama cabang.');
      return false;
    }

    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;

      if (editingBranch == null) {
        await branchRepository.addBranch(
          businessId: businessId,
          name: name,
          address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        );
        Get.snackbar('Berhasil', 'Cabang baru berhasil dibuat');
      } else {
        await branchRepository.updateBranch(
          id: editingBranch!.id,
          name: name,
          address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        );
        Get.snackbar('Berhasil', 'Data cabang berhasil diperbarui');
      }

      await loadBranches();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }
}

