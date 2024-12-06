import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/format_utils.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<TransactionModel> transactions = [];
  Map<String, double> monthlyBalances = {};

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final db = DatabaseHelper.instance;
    final data = await db.getTransactions();

    // Calcula o saldo mensal
    final Map<String, double> balances = {};
    for (var transaction in data) {
      final date = DateTime.parse(transaction.date);
      final monthYear = "${getMonthName(date.month)} ${date.year}";
      if (!balances.containsKey(monthYear)) {
        balances[monthYear] = 0.0;
      }
      balances[monthYear] = balances[monthYear]! +
          (transaction.type == 'ganho'
              ? transaction.value
              : -transaction.value);
    }

    setState(() {
      transactions = data;
      monthlyBalances = balances;
    });
  }

  String getMonthName(int month) {
    const months = [
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro"
    ];
    return months[month - 1];
  }

  Future<void> deleteTransaction(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteTransaction(id);
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico"),
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Gráfico de Barras
          SizedBox(
            height: 250,
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: getBarGroups(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 &&
                                index < monthlyBalances.keys.length) {
                              return Text(
                                monthlyBalances.keys.toList()[index],
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              );
                            }
                            return Text("");
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),

          // Histórico de Transações
          Expanded(
            child: ListView(
              children: transactions.map((transaction) {
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
                                onPressed: () => Navigator.of(context).pop(),
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
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> getBarGroups() {
    final List<BarChartGroupData> groups = [];
    int index = 0;

    for (var balance in monthlyBalances.values) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: balance,
              width: 20,
              color: balance >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      );
      index++;
    }

    return groups;
  }
}
