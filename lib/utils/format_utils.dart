import 'package:intl/intl.dart';

String formatCurrency(double value) {
  return "R\$ ${value.toStringAsFixed(2)}";
}

String formatDate(String date) {
  final parsedDate = DateTime.parse(date);
  return DateFormat('dd/MM/yyyy').format(parsedDate);
}
