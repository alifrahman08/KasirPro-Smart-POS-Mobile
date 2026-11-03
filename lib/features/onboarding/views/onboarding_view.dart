import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final storeNameController = TextEditingController(text: 'Berkah Jaya Mart');
  final storeAddressController = TextEditingController(text: 'Jl. Pasar Baru No. 10');
  String selectedCategory = 'Minimarket & Sembako';
  String selectedPrinterPaper = '58mm';

  final categories = [
    'Minimarket & Sembako',
    'Toko Kelontong',
    'Toko Pakaian & Fashion',
    'Toko Elektronik & Gadget',
    'Kuliner & F&B',
    'Retail UMKM Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup KasirPro (${_currentStep + 1}/4)', style: const TextStyle(fontSize: 15)),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentStep = page),
        children: [
          _buildStepWelcome(),
          _buildStepStoreInfo(),
          _buildStepCategoryCurrency(),
          _buildStepPrinterFinish(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              if (_currentStep < 3) {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              } else {
                // Complete onboarding
                final authService = Get.find<AuthService>();
                await authService.loginAsDemo('owner');
                Get.offAllNamed(AppRoutes.dashboard);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              _currentStep < 3 ? 'Lanjutkan' : 'Mulai Gunakan KasirPro',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepWelcome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: AppColors.primaryDark, size: 60),
          ),
          const SizedBox(height: 24),
          const Text('Selamat Datang di KasirPro!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Aplikasi kasir pintar dan manajemen inventaris stok yang siap mendampingi pertumbuhan bisnis UMKM Anda.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text('✓ Transaksi POS Cepat & Akurat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(height: 6),
                Text('✓ Manajemen Stok & Stock Opname Terpadu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(height: 6),
                Text('✓ Laporan Laba Bersih & Keuangan Nyata', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepStoreInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Usaha & Toko', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Masukkan nama toko dan alamat yang akan tercetak di struk penjualan.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          TextField(
            controller: storeNameController,
            decoration: const InputDecoration(labelText: 'Nama Toko / Usaha *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: storeAddressController,
            decoration: const InputDecoration(labelText: 'Alamat Toko Lengkap *'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCategoryCurrency() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori Usaha & Mata Uang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Pilih jenis usaha Anda untuk mempermudah konfigurasi sistem.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(labelText: 'Kategori Bisnis'),
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => selectedCategory = val);
            },
          ),
          const SizedBox(height: 16),
          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Mata Uang & Format',
              hintText: 'Rupiah (IDR / Rp) • Bahasa Indonesia',
              suffixIcon: Icon(Icons.lock_outline, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPrinterFinish() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Printer Struk & Siap Mulai', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Pilih lebar kertas roll thermal yang Anda gunakan:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('58mm (Kecil/Standar)')),
                  selected: selectedPrinterPaper == '58mm',
                  onSelected: (_) => setState(() => selectedPrinterPaper = '58mm'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('80mm (Lebar)')),
                  selected: selectedPrinterPaper == '80mm',
                  onSelected: (_) => setState(() => selectedPrinterPaper = '80mm'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Setup dasar selesai! Anda dapat langsung bertransaksi dan mengelola inventaris toko.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

