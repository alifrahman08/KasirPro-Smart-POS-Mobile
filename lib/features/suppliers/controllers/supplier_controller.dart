import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/supplier_repository.dart';

class SupplierController extends GetxController {
  final SupplierRepository supplierRepository = Get.find<SupplierRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<Supplier> suppliers = <Supplier>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  Supplier? editingSupplier;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final result = await supplierRepository.getSuppliers(businessId, searchQuery: searchQuery.value);
      suppliers.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void prepareCreate() {
    editingSupplier = null;
    nameController.clear();
    phoneController.clear();
    addressController.clear();
  }

  void prepareEdit(Supplier s) {
    editingSupplier = s;
    nameController.text = s.name;
    phoneController.text = s.phone ?? '';
    addressController.text = s.address ?? '';
  }

  Future<bool> saveSupplier() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Nama Wajib', 'Masukkan nama supplier.');
      return false;
    }

    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;

      if (editingSupplier == null) {
        await supplierRepository.addSupplier(
          businessId: businessId,
          name: name,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
          address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        );
        Get.snackbar('Berhasil', 'Supplier berhasil ditambahkan');
      } else {
        await supplierRepository.updateSupplier(
          id: editingSupplier!.id,
          name: name,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
          address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        );
        Get.snackbar('Berhasil', 'Data supplier diperbarui');
      }

      await loadSuppliers();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }

  Future<void> deleteSupplier(String id) async {
    await supplierRepository.deleteSupplier(id);
    await loadSuppliers();
    Get.snackbar('Dihapus', 'Supplier berhasil dinonaktifkan.');
  }
}

