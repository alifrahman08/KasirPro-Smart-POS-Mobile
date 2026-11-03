import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadCustomers,
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
                controller.loadCustomers();
              },
              decoration: const InputDecoration(
                hintText: 'Cari nama atau telepon pelanggan...',
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

              if (controller.customers.isEmpty) {
                return const Center(child: Text('Tidak ada pelanggan ditemukan'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: controller.customers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final c = controller.customers[index];
                  return _buildCustomerCard(context, c);
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
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Tambah Pelanggan'),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer c) {
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
          CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              c.name.isNotEmpty ? c.name[0].toUpperCase() : 'P',
              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Telp: ${c.phone ?? '-'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Alamat: ${c.address ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text('Total Belanja: ${CurrencyFormatter.format(c.totalSpend)}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    if (c.activeDebt > 0)
                      Text('Hutang: ${CurrencyFormatter.format(c.activeDebt)}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (val) {
              if (val == 'edit') {
                controller.prepareEdit(c);
                _openFormDialog(context);
              } else if (val == 'delete') {
                controller.deleteCustomer(c.id);
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
    final isEdit = controller.editingCustomer != null;

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
              Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan Baru', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap *', hintText: 'Contoh: Bu Ratna'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon / WhatsApp', hintText: '08123456789'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressController,
                decoration: const InputDecoration(labelText: 'Alamat', hintText: 'Jl. Melati No. 12'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final ok = await controller.saveCustomer();
                  if (ok) Get.back();
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Pelanggan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

