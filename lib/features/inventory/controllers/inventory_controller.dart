import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/product_repository.dart';

class InventoryController extends GetxController {
  final InventoryRepository inventoryRepository = Get.find<InventoryRepository>();
  final ProductRepository productRepository = Get.find<ProductRepository>();
  final AuthService authService = Get.find<AuthService>();

  final RxList<StockMovement> stockMovements = <StockMovement>[].obs;
  final RxList<Product> lowStockProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;

  // Quick Adjustment Form
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  final qtyController = TextEditingController();
  final notesController = TextEditingController();
  final referenceController = TextEditingController();
  final RxString selectedMovementType = 'PURCHASE'.obs; // PURCHASE, ADJUSTMENT, SALE_RETURN, PURCHASE_RETURN

  @override
  void onInit() {
    super.onInit();
    loadInventoryData();
  }

  Future<void> loadInventoryData() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final movements = await inventoryRepository.getStockMovements(businessId);
      stockMovements.value = movements;

      final lowStock = await productRepository.getProducts(
        businessId: businessId,
        stockFilter: 'LOW',
      );
      final outStock = await productRepository.getProducts(
        businessId: businessId,
        stockFilter: 'OUT',
      );
      lowStockProducts.value = [...outStock, ...lowStock];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitStockAdjustment() async {
    final prod = selectedProduct.value;
    if (prod == null) {
      Get.snackbar('Pilih Produk', 'Silakan pilih produk yang akan disesuaikan stoknya.');
      return false;
    }

    final qty = double.tryParse(qtyController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    if (qty <= 0) {
      Get.snackbar('Jumlah Tidak Valid', 'Jumlah penyesuaian stok harus lebih besar dari 0.');
      return false;
    }

    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final branchId = authService.activeBranchId.value;
      final userId = authService.currentUser.value?.id;

      double finalQtyChange = qty;
      if (selectedMovementType.value == 'PURCHASE_RETURN' || selectedMovementType.value == 'ADJUSTMENT_MINUS') {
        finalQtyChange = -qty;
      }

      await inventoryRepository.adjustStock(
        businessId: businessId,
        branchId: branchId,
        productId: prod.id,
        quantityChange: finalQtyChange,
        movementType: selectedMovementType.value == 'ADJUSTMENT_MINUS' ? 'ADJUSTMENT' : selectedMovementType.value,
        userId: userId,
        referenceId: referenceController.text.trim().isNotEmpty ? referenceController.text.trim() : null,
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'Penyesuaian Manual',
      );

      Get.snackbar('Berhasil', 'Stok ${prod.name} berhasil diperbarui!');
      qtyController.clear();
      notesController.clear();
      referenceController.clear();
      selectedProduct.value = null;

      await loadInventoryData();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    }
  }
}

