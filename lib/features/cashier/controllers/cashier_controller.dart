import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../data/repositories/product_repository.dart';

class CashierController extends GetxController {
  final ProductRepository productRepository = Get.find<ProductRepository>();
  final PosRepository posRepository = Get.find<PosRepository>();
  final CustomerRepository customerRepository = Get.find<CustomerRepository>();
  final AuthService authService = Get.find<AuthService>();
  final PrinterService printerService = Get.find<PrinterService>();

  // Products & Categories state
  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxString selectedCategoryId = 'ALL'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoadingProducts = false.obs;

  // Cart State
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  final RxDouble transactionDiscount = 0.0.obs;
  final RxBool isTaxEnabled = true.obs;
  final RxDouble taxRate = AppConstants.defaultTaxRate.obs;

  // Payment State
  final RxString selectedPaymentMethod = 'CASH'.obs; // CASH, QRIS, TRANSFER, DEBIT, EWALLET
  final RxDouble cashReceived = 0.0.obs;
  final RxString transactionNotes = ''.obs;
  final RxBool isProcessingPayment = false.obs;

  // Last checkout result for receipt preview
  final Rx<CheckoutResult?> lastCheckoutResult = Rx<CheckoutResult?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadProducts();
  }

  Future<void> loadCategories() async {
    final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
    final cats = await (posRepository.db.select(posRepository.db.categories)
          ..where((tbl) => tbl.businessId.equals(businessId))
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    categories.value = cats;
  }

  Future<void> loadProducts() async {
    isLoadingProducts.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final prods = await productRepository.getProducts(
        businessId: businessId,
        searchQuery: searchQuery.value,
        categoryId: selectedCategoryId.value == 'ALL' ? null : selectedCategoryId.value,
      );
      products.value = prods;
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void filterByCategory(String catId) {
    selectedCategoryId.value = catId;
    loadProducts();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    loadProducts();
  }

  // Cart Operations
  void addToCart(Product product) {
    if (product.currentStock <= 0) {
      Get.snackbar(
        'Stok Habis',
        '${product.name} saat ini stoknya habis.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (cartItems[index].quantity >= product.currentStock) {
        Get.snackbar(
          'Stok Terbatas',
          'Jumlah di keranjang sudah mencapai batas stok tersedia (${product.currentStock.toInt()}).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
        );
        return;
      }
      cartItems[index].quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel(product: product, quantity: 1));
    }
  }

  void incrementQuantity(int index) {
    final item = cartItems[index];
    if (item.quantity >= item.product.currentStock) {
      Get.snackbar(
        'Stok Terbatas',
        'Tidak dapat menambah lagi. Stok tersedia hanya ${item.product.currentStock.toInt()}.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    item.quantity++;
    cartItems.refresh();
  }

  void decrementQuantity(int index) {
    final item = cartItems[index];
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      cartItems.removeAt(index);
    }
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  void clearCart() {
    cartItems.clear();
    transactionDiscount.value = 0.0;
    cashReceived.value = 0.0;
    selectedCustomer.value = null;
    transactionNotes.value = '';
  }

  // Calculations
  int get totalItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalDiscount => transactionDiscount.value;

  double get taxAmount {
    if (!isTaxEnabled.value) return 0.0;
    final taxable = subtotal - totalDiscount;
    return taxable > 0 ? (taxable * (taxRate.value / 100.0)) : 0.0;
  }

  double get grandTotal {
    final total = subtotal - totalDiscount + taxAmount;
    return total > 0 ? total : 0.0;
  }

  double get changeAmount {
    if (selectedPaymentMethod.value != 'CASH') return 0.0;
    final change = cashReceived.value - grandTotal;
    return change > 0 ? change : 0.0;
  }

  bool get canCompletePayment {
    if (cartItems.isEmpty) return false;
    if (selectedPaymentMethod.value == 'CASH') {
      return cashReceived.value >= grandTotal;
    }
    return true; // Non-cash assumed exact payment
  }

  void setQuickCash(double amount) {
    cashReceived.value = amount;
  }

  void setExactCash() {
    cashReceived.value = grandTotal;
  }

  Future<void> openBarcodeScanner() async {
    final result = await Get.toNamed(AppRoutes.barcodeScanner);
    if (result != null) {
      if (result is Product) {
        addToCart(result);
        Get.snackbar(
          'Produk Ditambahkan',
          '${result.name} berhasil ditambahkan ke keranjang.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else if (result is String) {
        // Result is barcode string for non-existent product
        searchQuery.value = result;
        loadProducts();
      }
    }
  }

  Future<bool> processCheckout() async {
    if (!canCompletePayment) {
      Get.snackbar(
        'Nominal Kurang',
        'Uang yang diterima kurang dari total pembayaran!',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    isProcessingPayment.value = true;

    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final branchId = authService.activeBranchId.value;
      final cashierId = authService.currentUser.value?.id ?? 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380c33';

      final finalCashReceived = selectedPaymentMethod.value == 'CASH' ? cashReceived.value : grandTotal;
      final finalChange = selectedPaymentMethod.value == 'CASH' ? changeAmount : 0.0;

      final result = await posRepository.processTransaction(
        businessId: businessId,
        branchId: branchId,
        cashierId: cashierId,
        customerId: selectedCustomer.value?.id,
        cartItems: cartItems.toList(),
        subtotal: subtotal,
        discountAmount: totalDiscount,
        discountPercent: 0.0,
        taxAmount: taxAmount,
        totalAmount: grandTotal,
        paymentMethod: selectedPaymentMethod.value,
        cashReceived: finalCashReceived,
        changeAmount: finalChange,
        notes: transactionNotes.value.isNotEmpty ? transactionNotes.value : null,
      );

      lastCheckoutResult.value = result;

      // Refresh product list to show updated stocks
      await loadProducts();

      clearCart();

      return true;
    } catch (e) {
      Get.snackbar(
        'Transaksi Gagal',
        e.toString().replaceAll('Exception:', ''),
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }
}

