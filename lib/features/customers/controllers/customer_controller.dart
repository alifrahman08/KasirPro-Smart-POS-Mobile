import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository customerRepository = Get.find<CustomerRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Form fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  Customer? editingCustomer;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final result = await customerRepository.getCustomers(businessId, searchQuery: searchQuery.value);
      customers.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void prepareCreate() {
    editingCustomer = null;
    nameController.clear();
    phoneController.clear();
    addressController.clear();
  }

  void prepareEdit(Customer c) {
    editingCustomer = c;
    nameController.text = c.name;
    phoneController.text = c.phone ?? '';
    addressController.text = c.address ?? '';
  }

  Future<bool> saveCustomer() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Nama Wajib', 'Masukkan nama pelanggan.');
      return false;
    }

    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;

      if (editingCustomer == null) {
        await customerRepository.addCustomer(
          businessId: businessId,
          name: name,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
          address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        );
        Get.snackbar('Berhasil', 'Pelanggan berhasil ditambahkan');
      } else {
        await customerRepository.updateCustomer(
          id: editingCustomer!.id,
          name: name,
          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
          address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        );
        Get.snackbar('Berhasil', 'Data pelanggan diperbarui');
      }

      await loadCustomers();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    await customerRepository.deleteCustomer(id);
    await loadCustomers();
    Get.snackbar('Dihapus', 'Pelanggan berhasil dinonaktifkan.');
  }
}

