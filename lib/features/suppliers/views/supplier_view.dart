import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/supplier_controller.dart';

class SupplierView extends GetView<SupplierController> {
  const SupplierView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pemasok / Supplier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadSuppliers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (val) {
                controller.searchQuery.value = val;
                controller.loadSuppliers();
              },
              decoration: const InputDecoration(
                hintText: 'Cari nama supplier atau kontak...',
                prefixIcon: Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.suppliers.isEmpty) {
                return const Center(child: Text('Tidak ada supplier ditemukan'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: controller.suppliers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final s = controller.suppliers[index];
                  return _buildSupplierCard(context, s);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          controller.prepareCreate();
          _openFormDialog(context);
        },
        icon: const Icon(Icons.business),
        label: const Text('Tambah Supplier'),
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, Supplier s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Kontak: ${s.phone ?? '-'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Alamat: ${s.address ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text('Total Beli: ${CurrencyFormatter.format(s.totalPurchased)}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    if (s.activePayable > 0)
                      Text('Hutang: ${CurrencyFormatter.format(s.activePayable)}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (val) {
              if (val == 'edit') {
                controller.prepareEdit(s);
                _openFormDialog(context);
              } else if (val == 'delete') {
                controller.deleteSupplier(s.id);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  void _openFormDialog(BuildContext context) {
    final isEdit = controller.editingSupplier != null;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? 'Edit Supplier' : 'Tambah Supplier Baru', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Nama Perusahaan / Supplier *', hintText: 'Contoh: PT Indofood'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon / Kontak', hintText: '021-5551234'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressController,
                decoration: const InputDecoration(labelText: 'Alamat Kantor / Gudang', hintText: 'Kawasan Industri...'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final ok = await controller.saveSupplier();
                  if (ok) Get.back();
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Supplier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

