import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalStorageApi {
  static const String baseUrl = 'http://192.168.9.130:5000/api';

  static Future<List<dynamic>> getTransactions() async {
    final incomeResponse = await http.get(Uri.parse('$baseUrl/income'));
    final expenseResponse = await http.get(Uri.parse('$baseUrl/expenses'));

    if (incomeResponse.statusCode == 200 && expenseResponse.statusCode == 200) {
      final incomeData = json.decode(incomeResponse.body)['data'];
      final expenseData = json.decode(expenseResponse.body)['data'];
      return [...incomeData, ...expenseData];
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  static Future<void> insert(String item, String amount, bool isIncome) async {
    final url = isIncome ? '$baseUrl/income' : '$baseUrl/expenses';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user': '6714c46bd7068ecf740aa2b7', // Replace with actual user ID TODO: MAKE IT DYNAMIC
        'amount': double.parse(amount),
        'description': item,
        'category': isIncome ? 'income' : 'expense',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create transaction');
    }
  }

  static Future<double> calculateIncome() async {
    final response = await http.get(Uri.parse('$baseUrl/income'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.fold(0.0, (sum, item) => sum + item['amount']);
    } else {
      throw Exception('Failed to calculate income');
    }
  }

  static Future<double> calculateExpense() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.fold(0.0, (sum, item) => sum + item['amount']);
    } else {
      throw Exception('Failed to calculate expenses');
    }
  }
}