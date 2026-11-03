import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/report_repository.dart';

enum ReportPeriod {
  today,
  yesterday,
  last7Days,
  thisMonth,
  thisYear,
  custom,
}

class ReportController extends GetxController {
  final ReportRepository reportRepository = Get.find<ReportRepository>();
  final AuthService authService = Get.find<AuthService>();

  final Rx<ReportPeriod> selectedPeriod = ReportPeriod.thisMonth.obs;
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final Rx<FinancialReportSummary?> summary = Rx<FinancialReportSummary?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectPeriod(ReportPeriod.today);
  }

  void selectPeriod(ReportPeriod period) {
    selectedPeriod.value = period;
    final now = DateTime.now();

    switch (period) {
      case ReportPeriod.today:
        startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ReportPeriod.yesterday:
        final yest = now.subtract(const Duration(days: 1));
        startDate.value = DateTime(yest.year, yest.month, yest.day, 0, 0, 0);
        endDate.value = DateTime(yest.year, yest.month, yest.day, 23, 59, 59);
        break;
      case ReportPeriod.last7Days:
        final start = now.subtract(const Duration(days: 7));
        startDate.value = DateTime(start.year, start.month, start.day, 0, 0, 0);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ReportPeriod.thisMonth:
        startDate.value = DateTime(now.year, now.month, 1, 0, 0, 0);
        endDate.value = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case ReportPeriod.thisYear:
        startDate.value = DateTime(now.year, 1, 1, 0, 0, 0);
        endDate.value = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case ReportPeriod.custom:
        // Keep current custom dates
        break;
    }

    loadReport();
  }

  Future<void> loadReport() async {
    isLoading.value = true;
    try {
      final businessId = authService.currentUser.value?.businessId ?? AppConstants.defaultBusinessId;
      final result = await reportRepository.getFinancialReport(
        businessId: businessId,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      summary.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportPdf() async {
    final s = summary.value;
    if (s == null) return;

    final bytes = await reportRepository.generateReportPdf(s, AppConstants.defaultStoreName);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Laporan_Keuangan_KasirPro',
    );
  }

  Future<void> exportCsv() async {
    final s = summary.value;
    if (s == null) return;

    final csv = await reportRepository.exportReportToCsv(s);
    Get.defaultDialog(
      title: 'Ekspor CSV Laporan',
      content: SingleChildScrollView(
        child: Text(csv, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
      ),
      textConfirm: 'Tutup',
      onConfirm: () => Get.back(),
    );
  }
}

