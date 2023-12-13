import '../Controller/request_controller.dart';
import '../Controller/sqlite_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expense {
  static const String SQLiteTable = "expense";
  String desc;
  double amount;
  String dateTime;

  Expense(this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
      : desc = json['Desc'] as String? ?? '',
        amount = json['Amount'] != null
            ? (json['Amount'] is String
            ? double.tryParse(json['Amount']) ?? 0.0
            : json['Amount'].toDouble())
            : 0.0,
        dateTime = json['dateTime'] as String? ?? '';

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() => {'Desc': desc, 'Amount': amount, 'dateTime': dateTime};

  Future<bool> save() async {
    // Retrieve API address from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiAddress = prefs.getString('apiAddress') ?? "";

    // Save to local SQLite
    await SQLiteDB().insert(SQLiteTable, toJson());

    // API Operation with the retrieved API address
    RequestController req = RequestController(path: "/api/expenses.php", server: apiAddress);
    req.setBody(toJson());
    await req.post();

    if (req.status() == 200) {
      return true;
    } else {
      // If the API call fails, attempt to save to SQLite again
      if (await SQLiteDB().insert(SQLiteTable, toJson()) != 0) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<List<Expense>> loadAll() async {
    List<Expense> result = [];

    // Retrieve API address from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiAddress = prefs.getString('apiAddress') ?? "";

    RequestController req = RequestController(path: "/api/expenses.php", server: apiAddress);
    await req.get();

    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(Expense.fromJson(item));
      }
    } else {
      // If the API call fails, load from SQLite
      List<Map<String, dynamic>> resultFromSQLite = await SQLiteDB().queryAll(SQLiteTable);
      for (var item in resultFromSQLite) {
        result.add(Expense.fromJson(item));
      }
    }
    return result;
  }
}
