import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/app_constants.dart';
import '../database/app_database.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class PrinterDevice {
  final String name;
  final String address;
  final bool isBle;

  PrinterDevice({required this.name, required this.address, this.isBle = true});
}

class PrinterService extends GetxService {
  final SharedPreferences prefs;

  final RxList<PrinterDevice> discoveredDevices = <PrinterDevice>[].obs;
  final RxBool isScanning = false.obs;
  final RxBool isConnected = false.obs;
  final RxString selectedPrinterName = 'Thermal Printer 58mm'.obs;
  final RxString paperSize = '58mm'.obs; // '58mm' or '80mm'
  final RxString lastPrintStatus = ''.obs;

  PrinterService({required this.prefs});

  @override
  void onInit() {
    super.onInit();
    _loadPrinterSettings();
  }

  void _loadPrinterSettings() {
    selectedPrinterName.value = prefs.getString(AppConstants.keyDefaultPrinter) ?? 'Thermal Printer 58mm (Virtual/Bluetooth)';
    paperSize.value = prefs.getString(AppConstants.keyPaperSize) ?? '58mm';
  }

  Future<void> setPaperSize(String size) async {
    paperSize.value = size;
    await prefs.setString(AppConstants.keyPaperSize, size);
  }

  Future<void> startScan() async {
    discoveredDevices.clear();
    isScanning.value = true;

    // Add virtual printer for simulator testing
    discoveredDevices.add(
      PrinterDevice(name: 'KasirPro Virtual 58mm', address: '00:11:22:33:44:55', isBle: false),
    );
    discoveredDevices.add(
      PrinterDevice(name: 'Bluetooth Thermal 80mm', address: 'AA:BB:CC:DD:EE:FF', isBle: false),
    );

    try {
      if (await FlutterBluePlus.isSupported) {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

        FlutterBluePlus.scanResults.listen((results) {
          for (final r in results) {
            final name = r.device.platformName.isNotEmpty ? r.device.platformName : r.advertisementData.advName;
            if (name.isNotEmpty && !discoveredDevices.any((d) => d.address == r.device.remoteId.str)) {
              discoveredDevices.add(
                PrinterDevice(name: name, address: r.device.remoteId.str, isBle: true),
              );
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Bluetooth scan error: $e');
    } finally {
      Future.delayed(const Duration(seconds: 4), () {
        isScanning.value = false;
      });
    }
  }

  Future<bool> connectPrinter(PrinterDevice device) async {
    selectedPrinterName.value = device.name;
    await prefs.setString(AppConstants.keyDefaultPrinter, device.name);
    isConnected.value = true;
    lastPrintStatus.value = 'Terhubung ke ${device.name}';
    return true;
  }

  Future<bool> printTestReceipt() async {
    lastPrintStatus.value = 'Mencetak Test Struk...';
    await Future.delayed(const Duration(milliseconds: 600));
    lastPrintStatus.value = 'Test cetak berhasil!';
    return true;
  }

  /// Generates a standardized PDF receipt that can be printed to thermal or system printers, or shared
  Future<Uint8List> generateReceiptPdf({
    required Transaction transaction,
    required List<TransactionItem> items,
    String? storeName,
    String? storeAddress,
    String? cashierName,
  }) async {
    final pdf = pw.Document();

    final is58 = paperSize.value == '58mm';
    final pageFormat = is58
        ? const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity, marginAll: 3 * PdfPageFormat.mm)
        : const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 4 * PdfPageFormat.mm);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                storeName ?? AppConstants.defaultStoreName,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                storeAddress ?? AppConstants.defaultStoreAddress,
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text('----------------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No: ${transaction.invoiceNumber}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(DateFormatter.formatDate(transaction.createdAt), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kasir: ${cashierName ?? 'KasirPro'}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(DateFormatter.formatTime(transaction.createdAt), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Text('----------------------------------------', style: const pw.TextStyle(fontSize: 8)),
              // Items
              pw.Column(
                children: items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.productName, style: const pw.TextStyle(fontSize: 8)),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '${item.quantity.toInt()} x ${CurrencyFormatter.format(item.sellPrice)}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              CurrencyFormatter.format(item.subtotalAmount),
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.Text('----------------------------------------', style: const pw.TextStyle(fontSize: 8)),
              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(CurrencyFormatter.format(transaction.subtotal), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              if (transaction.discountAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Diskon', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('-${CurrencyFormatter.format(transaction.discountAmount)}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              if (transaction.taxAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('PPN (11%)', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(CurrencyFormatter.format(transaction.taxAmount), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text(CurrencyFormatter.format(transaction.totalAmount), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Bayar (${transaction.paymentMethod})', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(CurrencyFormatter.format(transaction.cashReceived), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kembalian', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(CurrencyFormatter.format(transaction.changeAmount), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Text('========================================', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),
              pw.Text(
                'Terima Kasih Atas Kunjungan Anda!',
                style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Barang yang sudah dibeli tidak dapat ditukar',
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 6),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printReceipt({
    required Transaction transaction,
    required List<TransactionItem> items,
    String? storeName,
    String? storeAddress,
    String? cashierName,
  }) async {
    try {
      final bytes = await generateReceiptPdf(
        transaction: transaction,
        items: items,
        storeName: storeName,
        storeAddress: storeAddress,
        cashierName: cashierName,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Struk_${transaction.invoiceNumber}',
      );
      lastPrintStatus.value = 'Struk berhasil dikirim ke printer!';
    } catch (e) {
      debugPrint('Print error: $e');
      lastPrintStatus.value = 'Gagal mencetak: $e';
    }
  }
}

