import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTimeFormatter = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

  /// Format angka ke Rupiah standar: Rp 150.000
  static String formatRupiah(num amount) {
    return _currencyFormatter.format(amount);
  }

  /// Format angka tanpa simbol: 150.000
  static String formatNumber(num amount) {
    return NumberFormat.decimalPattern('id_ID').format(amount);
  }

  /// Format tanggal standar Indonesia: 29 Agu 2026
  static String formatDate(DateTime dateTime) {
    try {
      return _dateFormatter.format(dateTime);
    } catch (_) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format tanggal dan waktu: 29 Agu 2026 14:30
  static String formatDateTime(DateTime dateTime) {
    try {
      return _dateTimeFormatter.format(dateTime);
    } catch (_) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    }
  }
}
