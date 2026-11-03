import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/repositories/product_repository.dart';

class BarcodeScannerController extends GetxController {
  final ProductRepository productRepository = Get.find<ProductRepository>();

  late MobileScannerController scannerController;
  final RxBool isTorchOn = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString lastScannedCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void toggleTorch() {
    scannerController.toggleTorch();
    isTorchOn.value = !isTorchOn.value;
  }

  void switchCamera() {
    scannerController.switchCamera();
    isFrontCamera.value = !isFrontCamera.value;
  }

  Future<void> onBarcodeScanned(String barcode) async {
    if (isProcessing.value || barcode.trim().isEmpty) return;

    isProcessing.value = true;
    lastScannedCode.value = barcode.trim();

    try {
      final product = await productRepository.getProductByBarcode(barcode.trim());
      if (product != null) {
        Get.back(result: product);
      } else {
        Get.defaultDialog(
          title: 'Barcode Tidak Ditemukan',
          middleText: 'Barcode "$barcode" belum terdaftar di produk manapun. Daftarkan produk baru?',
          textConfirm: 'Daftar Baru',
          textCancel: 'Scan Ulang',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // close dialog
            Get.back(result: barcode); // return barcode string to create form
          },
          onCancel: () {
            isProcessing.value = false;
          },
        );
      }
    } catch (e) {
      isProcessing.value = false;
    }
  }

  void submitManualBarcode(String code) {
    if (code.trim().isNotEmpty) {
      onBarcodeScanned(code.trim());
    }
  }
}

