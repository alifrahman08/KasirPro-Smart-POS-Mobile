import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/date_formatter.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final syncService = Get.find<SyncService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Bisnis & Sistem')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Store Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.primaryDark, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppConstants.defaultStoreName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        AppConstants.defaultStoreAddress,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          'Cabang: ${authService.activeBranchName.value}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Switch Demo Account Section (Essential for instant testing of all 3 roles!)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.switch_account, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Ganti Akun Demo Pengujian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Uji coba fitur KasirPro langsung dengan 3 role berbeda:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildRoleButton('Owner (Hendra)', 'owner', authService.userRole.value == 'owner', () async {
                        await authService.loginAsDemo('owner');
                        Get.snackbar('Role Diubah', 'Beralih ke Owner Hendra Gunawan');
                      }),
                      _buildRoleButton('Admin (Siti)', 'admin', authService.userRole.value == 'admin', () async {
                        await authService.loginAsDemo('admin');
                        Get.snackbar('Role Diubah', 'Beralih ke Admin Siti Rahma');
                      }),
                      _buildRoleButton('Kasir (Dimas)', 'cashier', authService.userRole.value == 'cashier', () async {
                        await authService.loginAsDemo('cashier');
                        Get.snackbar('Role Diubah', 'Beralih ke Kasir Dimas Pratama');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cloud Sync Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Sinkronisasi Cloud', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: syncService.syncState.value == SyncState.synced
                              ? AppColors.successContainer
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          syncService.syncState.value.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: syncService.syncState.value == SyncState.synced
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    'Antrean offline pending: ${syncService.pendingSyncCount.value} transaksi',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                Obx(
                  () => Text(
                    'Terakhir disinkronkan: ${syncService.lastSyncedAt.value != null ? DateFormatter.formatDateTime(syncService.lastSyncedAt.value) : 'Belum pernah'}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => syncService.syncPendingQueue(),
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Sinkronkan Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Operational Navigation Links
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.print_outlined,
                  title: 'Printer Bluetooth Thermal',
                  subtitle: 'Atur printer struk 58mm / 80mm',
                  onTap: () => Get.toNamed(AppRoutes.printer),
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.store_mall_directory_outlined,
                  title: 'Manajemen Multi-Cabang',
                  subtitle: 'Kelola dan pilih cabang aktif',
                  onTap: () => Get.toNamed(AppRoutes.branches),
                ),
                if (authService.canManageEmployees) ...[
                  const Divider(height: 1),
                  _buildSettingTile(
                    icon: Icons.people_outline,
                    title: 'Manajemen Karyawan',
                    subtitle: 'Kelola akun kasir, admin, hak akses',
                    onTap: () => Get.toNamed(AppRoutes.employees),
                  ),
                ],
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.notifications_none,
                  title: 'Pusat Notifikasi & Alarm',
                  subtitle: 'Stok menipis, hutang jatuh tempo',
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          OutlinedButton.icon(
            onPressed: authService.logout,
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const SizedBox(height: 16),
          const Center(
            child: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(String label, String role, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

