import 'package:flutter/material.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(String, double, String) onAddTransaction;

  AddTransactionDialog({required this.onAddTransaction});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String _type = 'gasto';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Adicionar Transação"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Nome"),
          ),
          TextField(
            controller: _valueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Valor"),
          ),
          DropdownButton<String>(
            value: _type,
            items: [
              DropdownMenuItem(value: 'gasto', child: Text("Gasto")),
              DropdownMenuItem(value: 'ganho', child: Text("Ganho")),
            ],
            onChanged: (value) {
              setState(() {
                _type = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAddTransaction(
              _nameController.text,
              double.parse(_valueController.text),
              _type,
            );
            Navigator.of(context).pop();
          },
          child: Text("Adicionar"),
        ),
      ],
    );
  }
}
