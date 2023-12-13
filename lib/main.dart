import 'package:flutter/material.dart';
import 'dailyexpenses.dart';

void main() {
  String username = 'zahir'; // Replace with the actual username
  runApp(DailyExpensesApp(username: username));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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





