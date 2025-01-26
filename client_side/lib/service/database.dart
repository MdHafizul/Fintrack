import 'dart:convert';
import 'package:expensetracker/service/authService.dart';
import 'package:http/http.dart' as http;

class LocalStorageApi {
  static const String baseUrl = 'http://192.168.9.88:5000/api';

  // Fetch user data
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Update user data
  static Future<void> updateUserData(
      String userId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user data');
    }
  }

  // Delete user data
  static Future<void> deleteUserData(String userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user data');
    }
  }

  static Future<List<dynamic>> getTransactions() async {
    final token = await AuthService.getToken();
    final userId = await AuthService.getUserId();
    final incomeResponse = await http.get(
      Uri.parse('$baseUrl/income'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final expenseResponse = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (incomeResponse.statusCode == 200 && expenseResponse.statusCode == 200) {
      final incomeData = json.decode(incomeResponse.body)['data'];
      final expenseData = json.decode(expenseResponse.body)['data'];
      return [...incomeData, ...expenseData];
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  static Future<void> insert(String item, String amount, bool isIncome) async {
    final token = await AuthService.getToken();
    final userId = await AuthService.getUserId();
    final url = isIncome ? '$baseUrl/income' : '$baseUrl/expenses';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'user': userId,
        'amount': double.parse(amount),
        'description': item,
        'category': isIncome ? 'income' : 'expense',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create transaction');
    }
  }

  static Future<void> updateTransaction(
      String id, String item, String amount, bool isIncome) async {
    final token = await AuthService.getToken();
    final url = isIncome ? '$baseUrl/income/$id' : '$baseUrl/expenses/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'amount': double.parse(amount),
        'description': item,
        'category': isIncome ? 'income' : 'expense',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction');
    }
  }

  static Future<void> deleteTransaction(String id, bool isIncome) async {
    final token = await AuthService.getToken();
    final url = isIncome ? '$baseUrl/income/$id' : '$baseUrl/expenses/$id';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  }

  static Future<double> calculateIncome() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/income'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.fold(0.0, (sum, item) => sum + item['amount']);
    } else {
      throw Exception('Failed to calculate income');
    }
  }

  static Future<double> calculateExpense() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.fold(0.0, (sum, item) => sum + item['amount']);
    } else {
      throw Exception('Failed to calculate expenses');
    }
  }
}
