import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../controllers/branch_controller.dart';

class BranchView extends GetView<BranchController> {
  const BranchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Multi-Cabang'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.branches.isEmpty) {
          return const Center(child: Text('Belum ada data cabang'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: controller.branches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final branch = controller.branches[index];
            final isActiveBranch = controller.authService.activeBranchId.value == branch.id;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActiveBranch ? AppColors.primary : AppColors.border,
                  width: isActiveBranch ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActiveBranch ? AppColors.primaryContainer : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.storefront, color: isActiveBranch ? AppColors.primaryDark : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (branch.isMain) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Pusat', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(branch.address ?? '-', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Telp: ${branch.phone ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  if (!isActiveBranch)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () => controller.switchActiveBranch(branch),
                      child: const Text('Pilih', style: TextStyle(fontSize: 12)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          controller.prepareCreate();
          _openBranchFormDialog(context);
        },
        icon: const Icon(Icons.add_business),
        label: const Text('Tambah Cabang'),
      ),
    );
  }

  void _openBranchFormDialog(BuildContext context) {
    final isEdit = controller.editingBranch != null;

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
              Text(isEdit ? 'Edit Cabang' : 'Tambah Cabang Baru', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Nama Cabang *', hintText: 'Contoh: Cabang Kemang'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressController,
                decoration: const InputDecoration(labelText: 'Alamat Lengkap Cabang', hintText: 'Jl. Kemang Raya No. 10'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon Cabang', hintText: '08123456789'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final ok = await controller.saveBranch();
                  if (ok) Get.back();
                },
                child: Text(isEdit ? 'Simpan Cabang' : 'Buat Cabang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

