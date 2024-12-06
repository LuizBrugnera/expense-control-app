import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final String name;
  final double value;
  final String type;
  final String date;

  TransactionTile({
    required this.name,
    required this.value,
    required this.type,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(name),
        subtitle: Text(date),
        trailing: Text(
          "${type == 'gasto' ? '-' : '+'}R\$ ${value.toStringAsFixed(2)}",
          style: TextStyle(
            color: type == 'gasto' ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
