import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageApi {
  static SharedPreferences? _preferences;

  static const String _transactionsKey = 'transactions';

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static List<List<String>> getTransactions() {
    final transactionsString = _preferences?.getStringList(_transactionsKey) ?? [];
    return transactionsString.map((e) => e.split('|')).toList();
  }

  static Future<void> insert(String item, String amount, bool isIncome) async {
    final transactions = getTransactions();
    final newTransaction = [item, amount, isIncome ? 'income' : 'expense'];
    transactions.add(newTransaction);

    // Convert each transaction to a string format for storage
    final transactionsString = transactions.map((e) => e.join('|')).toList();
    await _preferences?.setStringList(_transactionsKey, transactionsString);
  }

  static double calculateIncome() {
    final transactions = getTransactions();
    return transactions
        .where((transaction) => transaction[2] == 'income')
        .map((transaction) => double.parse(transaction[1]))
        .fold(0.0, (sum, amount) => sum + amount);
  }

  static double calculateExpense() {
    final transactions = getTransactions();
    return transactions
        .where((transaction) => transaction[2] == 'expense')
        .map((transaction) => double.parse(transaction[1]))
        .fold(0.0, (sum, amount) => sum + amount);
  }
}
