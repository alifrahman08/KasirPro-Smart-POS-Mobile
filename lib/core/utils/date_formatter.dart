import 'package:intl/intl.dart';

class DateFormatter {
  static DateFormat get _dateTimeFormat {
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm');
    }
  }

  static DateFormat get _dateFormat {
    try {
      return DateFormat('dd/MM/yyyy', 'id_ID');
    } catch (_) {
      return DateFormat('dd/MM/yyyy');
    }
  }

  static DateFormat get _dateFullFormat {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    } catch (_) {
      return DateFormat('EEEE, dd MMMM yyyy');
    }
  }

  static DateFormat get _timeFormat {
    try {
      return DateFormat('HH:mm', 'id_ID');
    } catch (_) {
      return DateFormat('HH:mm');
    }
  }

  static DateFormat get _monthYearFormat {
    try {
      return DateFormat('MMMM yyyy', 'id_ID');
    } catch (_) {
      return DateFormat('MMMM yyyy');
    }
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return _dateTimeFormat.format(dateTime.toLocal());
    } catch (_) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return _dateFormat.format(dateTime.toLocal());
    } catch (_) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  static String formatDateFull(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return _dateFullFormat.format(dateTime.toLocal());
    } catch (_) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return _timeFormat.format(dateTime.toLocal());
    } catch (_) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  static String formatMonthYear(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return _monthYearFormat.format(dateTime.toLocal());
    } catch (_) {
      return '${dateTime.month}/${dateTime.year}';
    }
  }
}

