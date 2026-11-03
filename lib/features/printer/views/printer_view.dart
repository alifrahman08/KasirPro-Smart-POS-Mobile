import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/services/printer_service.dart';

class PrinterView extends StatelessWidget {
  const PrinterView({super.key});

  @override
  Widget build(BuildContext context) {
    final printerService = Get.find<PrinterService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Bluetooth Thermal'),
        actions: [
          Obx(
            () => printerService.isScanning.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Cari Ulang Device',
                    onPressed: printerService.startScan,
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Selected Printer Card
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
                    const Text('Printer Aktif', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: printerService.isConnected.value ? AppColors.successContainer : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          printerService.isConnected.value ? 'Terhubung' : 'Siap Digunakan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: printerService.isConnected.value ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Text(
                    printerService.selectedPrinterName.value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 14),
                // Paper Size Selector
                Row(
                  children: [
                    const Text('Ukuran Kertas Roll:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 14),
                    Obx(
                      () => ChoiceChip(
                        label: const Text('58mm (Standar POS)'),
                        selected: printerService.paperSize.value == '58mm',
                        onSelected: (_) => printerService.setPaperSize('58mm'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => ChoiceChip(
                        label: const Text('80mm (Lebar)'),
                        selected: printerService.paperSize.value == '80mm',
                        onSelected: (_) => printerService.setPaperSize('80mm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => printerService.printTestReceipt(),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Uji Test Print Struk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                Obx(() {
                  if (printerService.lastPrintStatus.value.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      printerService.lastPrintStatus.value,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontStyle: FontStyle.italic),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Discovered Bluetooth Devices
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Perangkat Bluetooth Ditemukan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: printerService.startScan,
                child: const Text('Pindai Device'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Obx(() {
            if (printerService.discoveredDevices.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.bluetooth_searching, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tekan "Pindai Device" untuk mencari printer Bluetooth'),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: printerService.discoveredDevices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final dev = printerService.discoveredDevices[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.print_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dev.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('MAC: ${dev.address}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () => printerService.connectPrinter(dev),
                        child: const Text('Sambungkan', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

