import 'package:intl/intl.dart';

/// Currency, date and number formatting helpers.
class Formatters {
  Formatters._();

  static final NumberFormat _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final NumberFormat _currencyPaise =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, h:mm a');

  static String price(num value) =>
      value == value.roundToDouble() ? _currency.format(value) : _currencyPaise.format(value);

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String dateFromMillis(int millis) =>
      _date.format(DateTime.fromMillisecondsSinceEpoch(millis));

  static String discountPercent(num mrp, num price) {
    if (mrp <= 0 || price >= mrp) return '';
    final percent = ((mrp - price) / mrp * 100).round();
    return '$percent%';
  }

  static String compactCount(int count) => NumberFormat.compact().format(count);
}
