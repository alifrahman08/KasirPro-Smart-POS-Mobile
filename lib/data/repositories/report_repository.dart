import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/database/app_database.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class TopProductSummary {
  final String productName;
  final int totalQty;
  final double totalRevenue;

  TopProductSummary({
    required this.productName,
    required this.totalQty,
    required this.totalRevenue,
  });
}

class FinancialReportSummary {
  final double omzet;
  final double hpp;
  final double grossProfit;
  final double expenses;
  final double netProfit;
  final int transactionCount;
  final double averageOrderValue;
  final List<TopProductSummary> topProducts;
  final DateTime startDate;
  final DateTime endDate;

  FinancialReportSummary({
    required this.omzet,
    required this.hpp,
    required this.grossProfit,
    required this.expenses,
    required this.netProfit,
    required this.transactionCount,
    required this.averageOrderValue,
    required this.topProducts,
    required this.startDate,
    required this.endDate,
  });
}

class ReportRepository {
  final AppDatabase db;

  ReportRepository({required this.db});

  Future<FinancialReportSummary> getFinancialReport({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Fetch completed transactions in date range
    final transactions = await (db.select(db.transactions)
          ..where((tbl) =>
              tbl.businessId.equals(businessId) &
              tbl.status.equals('COMPLETED') &
              tbl.createdAt.isBiggerOrEqualValue(startDate) &
              tbl.createdAt.isSmallerOrEqualValue(endDate)))
        .get();

    double totalOmzet = 0.0;
    for (final tx in transactions) {
      totalOmzet += tx.totalAmount;
    }

    // 2. Fetch transaction items to calculate exact HPP and top products
    final txIds = transactions.map((t) => t.id).toList();
    double totalHpp = 0.0;
    final Map<String, (int, double)> productAggregation = {};

    if (txIds.isNotEmpty) {
      final items = await (db.select(db.transactionItems)..where((tbl) => tbl.transactionId.isIn(txIds))).get();

      for (final item in items) {
        final itemHpp = item.buyPrice * item.quantity;
        totalHpp += itemHpp;

        final current = productAggregation[item.productName] ?? (0, 0.0);
        productAggregation[item.productName] = (
          current.$1 + item.quantity.toInt(),
          current.$2 + item.subtotalAmount,
        );
      }
    }

    // 3. Fetch operational expenses in date range
    final expensesList = await (db.select(db.expenses)
          ..where((tbl) =>
              tbl.businessId.equals(businessId) &
              tbl.expenseDate.isBiggerOrEqualValue(startDate) &
              tbl.expenseDate.isSmallerOrEqualValue(endDate)))
        .get();

    double totalExpenses = 0.0;
    for (final exp in expensesList) {
      totalExpenses += exp.amount;
    }

    // 4. Calculations
    final grossProfit = totalOmzet - totalHpp;
    final netProfit = grossProfit - totalExpenses;
    final txCount = transactions.length;
    final aov = txCount > 0 ? (totalOmzet / txCount) : 0.0;

    // Top products sorted by quantity
    final topList = productAggregation.entries.map((e) {
      return TopProductSummary(
        productName: e.key,
        totalQty: e.value.$1,
        totalRevenue: e.value.$2,
      );
    }).toList()
      ..sort((a, b) => b.totalQty.compareTo(a.totalQty));

    return FinancialReportSummary(
      omzet: totalOmzet,
      hpp: totalHpp,
      grossProfit: grossProfit,
      expenses: totalExpenses,
      netProfit: netProfit,
      transactionCount: txCount,
      averageOrderValue: aov,
      topProducts: topList.take(5).toList(),
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<String> exportReportToCsv(FinancialReportSummary summary) async {
    final rows = <List<dynamic>>[];
    rows.add(['Laporan Keuangan KasirPro']);
    rows.add(['Periode', '${DateFormatter.formatDate(summary.startDate)} s/d ${DateFormatter.formatDate(summary.endDate)}']);
    rows.add([]);
    rows.add(['Metrik', 'Nilai (IDR)']);
    rows.add(['Total Omzet Penjualan', summary.omzet]);
    rows.add(['Total HPP (Harga Pokok Penjualan)', summary.hpp]);
    rows.add(['Laba Kotor (Gross Profit)', summary.grossProfit]);
    rows.add(['Total Biaya Operasional', summary.expenses]);
    rows.add(['Laba Bersih (Net Profit)', summary.netProfit]);
    rows.add(['Total Transaksi', summary.transactionCount]);
    rows.add(['Rata-rata Transaksi (AOV)', summary.averageOrderValue]);
    rows.add([]);
    rows.add(['Produk Terlaris', 'Jumlah Terjual', 'Total Omzet']);
    for (final p in summary.topProducts) {
      rows.add([p.productName, p.totalQty, p.totalRevenue]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<Uint8List> generateReportPdf(FinancialReportSummary summary, String storeName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(storeName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Laporan Keuangan & Laba Bersih', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Periode: ${DateFormatter.formatDate(summary.startDate)} - ${DateFormatter.formatDate(summary.endDate)}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Divider(thickness: 1, height: 20),
              pw.Text('Ringkasan Finansial', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildPdfMetricRow('Total Omzet Penjualan', CurrencyFormatter.format(summary.omzet)),
              _buildPdfMetricRow('Total HPP (Harga Pokok)', CurrencyFormatter.format(summary.hpp)),
              _buildPdfMetricRow('Laba Kotor (Gross Profit)', CurrencyFormatter.format(summary.grossProfit)),
              _buildPdfMetricRow('Pengeluaran Operasional', CurrencyFormatter.format(summary.expenses)),
              _buildPdfMetricRow('LABA BERSIH (NET PROFIT)', CurrencyFormatter.format(summary.netProfit), isBold: true),
              _buildPdfMetricRow('Jumlah Transaksi', '${summary.transactionCount} Transaksi'),
              _buildPdfMetricRow('Rata-rata Keranjang (AOV)', CurrencyFormatter.format(summary.averageOrderValue)),
              pw.SizedBox(height: 20),
              pw.Text('5 Produk Terlaris', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Nama Produk', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Terjual', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total Omzet', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...summary.topProducts.map((p) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(p.productName)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${p.totalQty} item')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(CurrencyFormatter.format(p.totalRevenue))),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(),
              pw.Text('Dicetak secara otomatis oleh KasirPro Smart POS Mobile pada ${DateFormatter.formatDateTime(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfMetricRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}

