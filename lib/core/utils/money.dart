import 'package:intl/intl.dart';

class MoneyFormat {
  static final _format = NumberFormat.currency(locale: 'en_US', symbol: 'S/ ');

  static String soles(num amount) => _format.format(amount);
  static String cents(int amount) => soles(amount / 100);
}
