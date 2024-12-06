import 'package:flutter/material.dart';
import 'screens/dashboard_page.dart';
import 'screens/history_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador Financeiro',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => DashboardPage(),
        '/history': (context) => HistoryPage(),
      },
    );
  }
}
