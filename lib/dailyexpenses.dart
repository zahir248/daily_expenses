import 'package:flutter/material.dart';
import '../Model/expense.dart';
import '../Controller/request_controller.dart';

class DailyExpensesApp extends StatelessWidget {

  final String username;

  const DailyExpensesApp({required this.username});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseList(username: username),
    );
  }
}

class ExpenseList extends StatefulWidget {

  final String username; // Add this line

  ExpenseList({required this.username}); // Add this line

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {


  final List<Expense> expenses = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  double totalAmount = 0.0;

  void _addExpense() async {
    String description = descriptionController.text.trim();
    String amount = amountController.text.trim();
    if (amount.isNotEmpty && description.isNotEmpty) {
      Expense exp = Expense(double.parse(amount), description, txtDateController.text);
      if (await exp.save()) {
        setState(() {
          expenses.add(exp);
          descriptionController.clear();
          amountController.clear();
          calculateTotal();
        });
      } else {
        _showMessage("Failed to save Expenses data");
      }
    }
  }

  void calculateTotal() {
    totalAmount = 0;
    for (Expense ex in expenses) {
      totalAmount += ex.amount;
    }
    totalAmountController.text = totalAmount.toString();
  }

  void _removeExpense(int index) {
    totalAmount -= expenses[index].amount;
    setState(() {
      expenses.removeAt(index);
      totalAmountController.text = totalAmount.toString();
    });
  }

  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  void _editExpense(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) {
            setState(() {
              totalAmount += editedExpense.amount - expenses[index].amount;
              expenses[index] = editedExpense;
              totalAmountController.text = totalAmount.toString();
            });
          },
        ),
      ),
    );
  }

  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedDate != null && pickedTime != null) {
      setState(() {
        txtDateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
       _showMessage("Welcome ${widget.username}");

      RequestController req = RequestController(
        path: "/api/timezone/Asia/Kuala_Lumpur",
        server: "http://worldtimeapi.org");
      req.get().then((value) {
        dynamic res = req.result();
        txtDateController.text =
            res["datetime"].toString().substring(0,19).replaceAll('T', ' ');
        });
      expenses.addAll(await Expense.loadAll());

      setState(() {
        calculateTotal();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Spend: RM ${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add Expense'),
          ),
          Container(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(expenses[index].amount.toString()),
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onDismissed: (direction) {
              _removeExpense(index);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Item dismissed')));
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(expenses[index].desc),
                subtitle: Row(children: [
                  Text('Amount: ${expenses[index].amount}'),
                  const Spacer(),
                  Text('Date: ${expenses[index].dateTime}')
                ]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeExpense(index),
                ),
                onLongPress: () {
                  _editExpense(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}



class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    descController.text = widget.expense.desc;
    amountController.text = widget.expense.amount.toString();
    dateController.text = widget.expense.dateTime;
  }

  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedDate != null && pickedTime != null) {
      setState(() {
        dateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onSave(Expense(
                double.parse(amountController.text),
                descController.text,
                dateController.text,
              ));
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(DailyExpensesApp(username: 'zahir'));
}
