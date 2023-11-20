import 'package:flutter/material.dart';
import 'dailyexpenses.dart';

void main(){
  runApp(DailyExpensesApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const title = 'Daily Expenses';

    return MaterialApp(
      title: 'title',
      home: Scaffold(
        appBar: AppBar (
          title: const Text(title),
    ),
      body : ListView(
        children: <Widget>[
          ListTile(
            leading : Icon(Icons.attach_money),
            title: Text('Groceries - \RM150.00'),
          ),
         ListTile(
           leading : Icon(Icons.shopping_cart),
          title: Text('Clothing - \RM39.00'),
         ),
         ListTile(
           leading : Icon(Icons.local_dining),
           title: Text('Dinner - \RM7.00'),
         ),
        ],
      ),
      ),
    );
  }
}





