import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class AppFormat {
  static String date(String stringDate) {
    DateTime dateTime = DateTime.parse(stringDate);
    return DateFormat('d MMM yyyy', 'en_US').format(dateTime);
  }

  static String dateMonth(String stringDate) {
    DateTime dateTime = DateTime.parse(stringDate);
    return DateFormat('d MMM', 'en_US').format(dateTime);
  }

  static String currency(double number) {
    return NumberFormat.currency(
      decimalDigits: 0,
      locale: 'en_US', // Menggunakan format yang benar untuk locale
      symbol: 'Rp ',
    ).format(number);
  }

  static String generateReservationId() {
    return randomNumeric(
        8); // Menghasilkan string acak dengan panjang 8 karakter
  }
}
