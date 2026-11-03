import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../controllers/product_controller.dart';

class ProductFormView extends GetView<ProductController> {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk Baru'),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nama Produk
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk *',
                hintText: 'Contoh: Minyak Goreng Bimoli 2L',
              ),
              validator: (v) => Validators.requiredField(v, 'Nama produk'),
            ),
            const SizedBox(height: 14),

            // Barcode & Scan Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Barcode',
                      hintText: 'Contoh: 899100100201',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.toNamed(AppRoutes.barcodeScanner);
                    if (result != null && result is String) {
                      controller.barcodeController.text = result;
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    minimumSize: const Size(100, 48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // SKU
            TextFormField(
              controller: controller.skuController,
              decoration: const InputDecoration(
                labelText: 'SKU (Kode Unik Produk) *',
                hintText: 'Contoh: MYK-BML-2L',
              ),
              validator: (v) => Validators.requiredField(v, 'SKU'),
            ),
            const SizedBox(height: 14),

            // Kategori Dropdown
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.formCategoryId.value.isNotEmpty ? controller.formCategoryId.value : null,
                decoration: const InputDecoration(labelText: 'Kategori Produk'),
                items: controller.categories.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.formCategoryId.value = val;
                },
              ),
            ),
            const SizedBox(height: 14),

            // Pricing Row: Buy Price (HPP) & Sell Price
            Row(
              children: [
                if (controller.authService.canEditHpp)
                  Expanded(
                    child: TextFormField(
                      controller: controller.buyPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Beli (HPP) *',
                        prefixText: 'Rp ',
                      ),
                      validator: (v) => Validators.positiveNumber(v, 'Harga beli'),
                    ),
                  ),
                if (controller.authService.canEditHpp) const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controller.sellPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual *',
                      prefixText: 'Rp ',
                    ),
                    validator: (v) => Validators.positiveNumber(v, 'Harga jual'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stock & Min Stock & Unit
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok Saat Ini *'),
                    validator: (v) => Validators.positiveNumber(v, 'Stok'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: controller.minStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Batas Min Stok *'),
                    validator: (v) => Validators.positiveNumber(v, 'Batas minimum'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.formUnit.value,
                      decoration: const InputDecoration(labelText: 'Satuan'),
                      items: controller.units.map((u) {
                        return DropdownMenuItem(value: u, child: Text(u));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.formUnit.value = val;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Deskripsi
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Produk (Opsional)',
                hintText: 'Keterangan tambahan...',
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => ElevatedButton(
                onPressed: controller.isFormSaving.value
                    ? null
                    : () async {
                        final ok = await controller.saveProduct();
                        if (ok) {
                          Get.back();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: controller.isFormSaving.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Simpan Perubahan' : 'Tambah Produk Sekarang',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

