import 'package:intl/intl.dart';

final _tomanFormat = NumberFormat.decimalPattern('fa');

String formatToman(int amount) => '${_tomanFormat.format(amount)} تومان';

String normalizeIranPhone(String dialCode, String digits) {
  final d = digits.replaceAll(RegExp(r'\D'), '');
  if (dialCode.contains('98')) {
    if (d.length == 10) return '0$d';
    if (d.length == 11 && d.startsWith('0')) return d;
  }
  if (d.startsWith('0')) return d;
  return '0$d';
}
