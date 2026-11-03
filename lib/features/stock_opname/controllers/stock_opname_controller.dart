import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/product_repository.dart';

class OpnameRowState {
  final Product product;
  final TextEditingController controller;
  final RxDouble physicalStock;

  OpnameRowState({required this.product, required this.controller, required double initialVal})
      : physicalStock = initialVal.obs;

  double get difference => physicalStock.value - product.currentStock;
}

class StockOpnameController extends GetxController {
  final InventoryRepository inventoryRepository = Get.find<InventoryRepository>();
  final ProductRepository productRepository = Get.find<ProductRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<OpnameRowState> rows = <OpnameRowState>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProductsForOpname();
  }

  Future<void> loadProductsForOpname() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final products = await productRepository.getProducts(businessId: businessId);

      rows.value = products.map((p) {
        final ctrl = TextEditingController(text: p.currentStock.toInt().toString());
        return OpnameRowState(
          product: p,
          controller: ctrl,
          initialVal: p.currentStock,
        );
      }).toList();
    } finally {
      isLoading.value = false;
    }
  }

  void updatePhysicalCount(int index, String value) {
    final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    rows[index].physicalStock.value = parsed;
    rows.refresh();
  }

  int get discrepancyCount {
    return rows.where((r) => r.difference != 0).length;
  }

  Future<void> scanBarcodeToCount() async {
    final result = await Get.toNamed(AppRoutes.barcodeScanner);
    if (result != null && result is Product) {
      final index = rows.indexWhere((r) => r.product.id == result.id);
      if (index >= 0) {
        rows[index].physicalStock.value++;
        rows[index].controller.text = rows[index].physicalStock.value.toInt().toString();
        rows.refresh();
        Get.snackbar(
          'Produk Dihitung',
          '${result.name} jumlah fisik ditambah menjadi ${rows[index].physicalStock.value.toInt()}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<bool> saveStockOpname() async {
    if (rows.isEmpty) return false;

    isSaving.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final branchId = authService.activeBranchId.value;
      final userId = authService.currentUser.value?.id;

      final opnameInputs = rows.map((r) {
        return OpnameItemInput(
          product: r.product,
          physicalStock: r.physicalStock.value,
        );
      }).toList();

      await inventoryRepository.performStockOpname(
        businessId: businessId,
        branchId: branchId,
        userId: userId,
        items: opnameInputs,
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'Stock Opname Rutin',
      );

      Get.snackbar(
        'Stock Opname Berhasil',
        'Data stok fisik berhasil diselaraskan dengan database.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), backgroundColor: Colors.red.shade700, colorText: Colors.white);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}

