import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository productRepository = Get.find<ProductRepository>();
  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();
  final AuthService authService = Get.find<AuthService>();
  final _uuid = const Uuid();

  // List State
  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryId = 'ALL'.obs;
  final RxString selectedStockFilter = 'ALL'.obs; // ALL, LOW, OUT
  final RxString selectedSortBy = 'NAME_ASC'.obs; // NAME_ASC, PRICE_ASC, PRICE_DESC, STOCK_ASC

  // Form State
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final stockController = TextEditingController();
  final minStockController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxString formCategoryId = ''.obs;
  final RxString formUnit = 'pcs'.obs;
  final RxString formImagePath = ''.obs;
  final RxBool isFormSaving = false.obs;

  Product? editingProduct;

  final units = ['pcs', 'kg', 'sak', 'pouch', 'kotak', 'botol', 'renceng', 'bungkus', 'pack'];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadProducts();
  }

  Future<void> loadCategories() async {
    final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
    final cats = await categoryRepository.getCategories(businessId);
    categories.value = cats;
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final result = await productRepository.getProducts(
        businessId: businessId,
        searchQuery: searchQuery.value,
        categoryId: selectedCategoryId.value == 'ALL' ? null : selectedCategoryId.value,
        stockFilter: selectedStockFilter.value,
        sortBy: selectedSortBy.value,
      );
      products.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void prepareCreate({String? initialBarcode}) {
    editingProduct = null;
    nameController.clear();
    skuController.text = 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    barcodeController.text = initialBarcode ?? '';
    buyPriceController.clear();
    sellPriceController.clear();
    stockController.text = '0';
    minStockController.text = '5';
    descriptionController.clear();
    formCategoryId.value = categories.isNotEmpty ? categories.first.id : '';
    formUnit.value = 'pcs';
    formImagePath.value = '';
  }

  void prepareEdit(Product product) {
    editingProduct = product;
    nameController.text = product.name;
    skuController.text = product.sku;
    barcodeController.text = product.barcode ?? '';
    buyPriceController.text = product.buyPrice.toInt().toString();
    sellPriceController.text = product.sellPrice.toInt().toString();
    stockController.text = product.currentStock.toInt().toString();
    minStockController.text = product.minStock.toInt().toString();
    descriptionController.text = product.description ?? '';
    formCategoryId.value = product.categoryId ?? (categories.isNotEmpty ? categories.first.id : '');
    formUnit.value = product.unit;
    formImagePath.value = product.imageUrl ?? '';
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked != null) {
      formImagePath.value = picked.path;
    }
  }

  Future<bool> saveProduct() async {
    if (!formKey.currentState!.validate()) return false;

    final barcode = barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      final isDup = await productRepository.isBarcodeDuplicate(
        barcode,
        excludeProductId: editingProduct?.id,
      );
      if (isDup) {
        Get.snackbar(
          'Barcode Duplikat',
          'Barcode "$barcode" sudah terdaftar pada produk lain!',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return false;
      }
    }

    isFormSaving.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final branchId = authService.activeBranchId.value;

      final buyPrice = double.tryParse(buyPriceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      final sellPrice = double.tryParse(sellPriceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      final stock = double.tryParse(stockController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      final minStock = double.tryParse(minStockController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 5.0;

      if (editingProduct == null) {
        // Create new product
        final id = _uuid.v4();
        await productRepository.addProduct(
          ProductsCompanion.insert(
            id: id,
            businessId: businessId,
            branchId: drift.Value(branchId),
            categoryId: drift.Value(formCategoryId.value.isNotEmpty ? formCategoryId.value : null),
            name: nameController.text.trim(),
            sku: skuController.text.trim(),
            barcode: drift.Value(barcode.isNotEmpty ? barcode : null),
            description: drift.Value(descriptionController.text.trim()),
            buyPrice: drift.Value(buyPrice),
            sellPrice: drift.Value(sellPrice),
            currentStock: drift.Value(stock),
            minStock: drift.Value(minStock),
            unit: drift.Value(formUnit.value),
            imageUrl: drift.Value(formImagePath.value.isNotEmpty ? formImagePath.value : null),
          ),
        );
        Get.snackbar('Berhasil', 'Produk berhasil ditambahkan', backgroundColor: Colors.green.shade700, colorText: Colors.white);
      } else {
        // Update product
        await productRepository.updateProduct(
          ProductsCompanion(
            id: drift.Value(editingProduct!.id),
            businessId: drift.Value(businessId),
            categoryId: drift.Value(formCategoryId.value.isNotEmpty ? formCategoryId.value : null),
            name: drift.Value(nameController.text.trim()),
            sku: drift.Value(skuController.text.trim()),
            barcode: drift.Value(barcode.isNotEmpty ? barcode : null),
            description: drift.Value(descriptionController.text.trim()),
            buyPrice: drift.Value(buyPrice),
            sellPrice: drift.Value(sellPrice),
            currentStock: drift.Value(stock),
            minStock: drift.Value(minStock),
            unit: drift.Value(formUnit.value),
            imageUrl: drift.Value(formImagePath.value.isNotEmpty ? formImagePath.value : null),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
        Get.snackbar('Berhasil', 'Produk berhasil diperbarui', backgroundColor: Colors.green.shade700, colorText: Colors.white);
      }

      await loadProducts();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), backgroundColor: Colors.red.shade700, colorText: Colors.white);
      return false;
    } finally {
      isFormSaving.value = false;
    }
  }

  Future<void> deleteProduct(Product product) async {
    if (!authService.canDeleteProducts) {
      Get.snackbar('Akses Ditolak', 'Hanya Owner yang berhak menghapus produk.');
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await productRepository.deleteProduct(product.id);
      await loadProducts();
      Get.snackbar('Produk Dihapus', '${product.name} telah dinonaktifkan.');
    }
  }

  Future<void> exportCsv() async {
    final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
    final csv = await productRepository.exportToCsv(businessId);
    Get.defaultDialog(
      title: 'Ekspor Produk CSV',
      content: SingleChildScrollView(
        child: Text(csv, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
      ),
      textConfirm: 'Tutup',
      onConfirm: () => Get.back(),
    );
  }
}

