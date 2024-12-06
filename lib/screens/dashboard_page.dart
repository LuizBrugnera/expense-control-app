import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Gráfico de Pizza
import '../widgets/add_transaction_dialog.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/format_utils.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double saldo = 1500.0;
  double gastosMes = 1305.0;
  double ganhosMes = 2300.0;
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final db = DatabaseHelper.instance;
    final data = await db.getTransactions();
    setState(() {
      transactions = data;
      gastosMes = data
          .where((item) => item.type == 'gasto')
          .fold(0.0, (sum, item) => sum + item.value);
      ganhosMes = data
          .where((item) => item.type == 'ganho')
          .fold(0.0, (sum, item) => sum + item.value);
      saldo = ganhosMes - gastosMes;
    });
  }

  Future<void> addTransaction(String name, double value, String type) async {
    final db = DatabaseHelper.instance;
    await db.insertTransaction(TransactionModel(
      name: name,
      value: value,
      type: type,
      date: DateTime.now().toIso8601String(),
    ));
    fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteTransaction(id);
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Saldo Atual
              Card(
                elevation: 2,
                child: ListTile(
                  title: Text("Saldo Atual"),
                  trailing: Text(
                    formatCurrency(saldo),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Ganhos e Gastos do Mês
              Row(
                children: [
                  // Gastos do Mês
                  Expanded(
                    child: Card(
                      color: Colors.red[50],
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Gastos do Mês",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              formatCurrency(gastosMes),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Ganhos do Mês
                  Expanded(
                    child: Card(
                      color: Colors.green[50],
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Ganhos do Mês",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              formatCurrency(ganhosMes),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Gráfico de Pizza
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Detalhamento de Gastos e Ganhos"),
                    ),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: getPieSections(),
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Histórico de Transações com Botão de Lixeira
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Histórico de Transações"),
                    ),
                    ...transactions.map((transaction) {
                      return ListTile(
                        title: Text(transaction.name),
                        subtitle: Text(formatDate(transaction.date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${transaction.type == 'gasto' ? '-' : '+'} ${formatCurrency(transaction.value)}",
                              style: TextStyle(
                                color: transaction.type == 'gasto'
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Excluir Transação"),
                                  content: Text(
                                      "Deseja excluir a transação '${transaction.name}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteTransaction(transaction.id!);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Excluir"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) =>
              AddTransactionDialog(onAddTransaction: addTransaction),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  List<PieChartSectionData> getPieSections() {
    final gastos = transactions
        .where((item) => item.type == 'gasto')
        .fold(0.0, (sum, item) => sum + item.value);
    final ganhos = transactions
        .where((item) => item.type == 'ganho')
        .fold(0.0, (sum, item) => sum + item.value);

    return [
      PieChartSectionData(
        value: gastos,
        color: Colors.red,
        title: "Gastos",
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: ganhos,
        color: Colors.green,
        title: "Ganhos",
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }
}
