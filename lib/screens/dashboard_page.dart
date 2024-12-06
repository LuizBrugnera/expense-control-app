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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
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

              // Botões para Adicionar Gastos e Ganhos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botão de Adicionar Gasto
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Fundo do botão
                        foregroundColor: Colors.black, // Cor do texto
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AddTransactionDialog(
                          onAddTransaction: (name, value, type) =>
                              addTransaction(name, value, 'gasto'),
                        ),
                      ),
                      child: Text(
                        "Adicionar Gasto",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Botão de Adicionar Ganho
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Fundo do botão
                        foregroundColor: Colors.black, // Cor do texto
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AddTransactionDialog(
                          onAddTransaction: (name, value, type) =>
                              addTransaction(name, value, 'ganho'),
                        ),
                      ),
                      child: Text(
                        "Adicionar Ganho",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
