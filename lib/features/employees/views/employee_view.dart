import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../controllers/employee_controller.dart';

class EmployeeView extends GetView<EmployeeController> {
  const EmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Karyawan & Akses'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.employees.isEmpty) {
          return const Center(child: Text('Belum ada data karyawan'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: controller.employees.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final emp = controller.employees[index];
            return _buildEmployeeCard(context, emp);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          controller.prepareCreate();
          _openEmployeeFormDialog(context);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Karyawan'),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, User emp) {
    Color roleColor = AppColors.primary;
    if (emp.role == 'owner') roleColor = Colors.purple;
    if (emp.role == 'admin') roleColor = AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: roleColor.withValues(alpha: 0.15),
            child: Icon(Icons.person, color: roleColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(emp.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Telp: ${emp.phone ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  emp.role.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () {
                  controller.prepareEdit(emp);
                  _openEmployeeFormDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEmployeeFormDialog(BuildContext context) {
    final isEdit = controller.editingUser != null;

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
              Text(isEdit ? 'Edit Karyawan' : 'Tambah Karyawan Baru', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: controller.fullNameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap *', hintText: 'Contoh: Ahmad Kasir'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isEdit,
                decoration: const InputDecoration(labelText: 'Email Akun *', hintText: 'ahmad@kasirpro.id'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor HP / WhatsApp', hintText: '08123456789'),
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedRole.value,
                  decoration: const InputDecoration(labelText: 'Hak Akses / Role *'),
                  items: const [
                    DropdownMenuItem(value: 'cashier', child: Text('Kasir (Transaksi & Cetak Struk)')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin (Stok, Produk, Supplier)')),
                    DropdownMenuItem(value: 'owner', child: Text('Owner (Akses Penuh Seluruh Modul)')),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.selectedRole.value = val;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final ok = await controller.saveEmployee();
                  if (ok) Get.back();
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Daftarkan Karyawan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

