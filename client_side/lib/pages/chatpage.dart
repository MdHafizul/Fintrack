import 'package:expensetracker/pages/settingsPage.dart';
import 'package:expensetracker/pages/statisticpage.dart';
import 'package:expensetracker/pages/homepagetest.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/service/database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];
  int _selectedIndex = 1;
  List<dynamic> _transactions = [];
  double _income = 0.0;
  double _expense = 0.0;
  String apiKey = dotenv.env['API_KEY'] ?? 'default_value';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Simulated fetching of local data (replace with your implementation)
    final transactions = await LocalStorageApi.getTransactions();
    final income = await LocalStorageApi.calculateIncome();
    final expense = await LocalStorageApi.calculateExpense();

    setState(() {
      _transactions = transactions;
      _income = income;
      _expense = expense;
    });

    _summarizeData();
  }

  void _summarizeData() {
    String summary = 'Summary:\n';
    summary += 'Total Income: \$${_income.toStringAsFixed(2)}\n';
    summary += 'Total Expense: \$${_expense.toStringAsFixed(2)}\n';
    summary += 'Transactions:\n';
    for (var transaction in _transactions) {
      summary +=
          '${transaction['description'] ?? 'Unknown'}: \$${transaction['amount'] ?? '0.0'} (${transaction['category'] ?? 'Unknown'})\n';
    }

    setState(() {
      _messages.add({'user': '', 'response': summary});
    });
  }

  void _sendMessage() async {
    print('Message sent: ${_messageController.text}');
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({'user': _messageController.text, 'response': '...'});
      });

      // Include income and expense data in the AI request
      final response = await _getAIResponse(
          _messageController.text, _income, _expense, _transactions);

      setState(() {
        _messages[_messages.length - 1]['response'] =
            response.isNotEmpty ? response : 'Failed to fetch a response.';
        _messageController.clear(); // Clear the input field
      });
    }
  }

  Future<String> _getAIResponse(String message, double income, double expense,
      List<dynamic> transactions) async {
    print('Fetching AI response for: $message');
    const String apiKey = 'AIzaSyAqN0Io32xKYRm8C7tYJFg5ah4cmNH7qGo';
    const String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

    // Create a summary message for the AI to process
    String summaryMessage = '''
    Income: \$${income.toStringAsFixed(2)}
    Expense: \$${expense.toStringAsFixed(2)}
    Transactions:
    ''';

    // Add transactions details to the summary
    for (var transaction in transactions) {
      summaryMessage += '''
      ${transaction['description'] ?? 'Unknown'}: \$${transaction['amount'] ?? '0.0'} (${transaction['category'] ?? 'Unknown'})
    ''';
    }

    // Combine user message with summary
    String fullMessage = '$summaryMessage\n\n$message';

    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': fullMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Parse the response correctly based on the actual structure
        final String? aiResponse =
            responseData['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return aiResponse ?? 'No response received';
      } else {
        return 'Failed to get response: ${response.statusCode} - ${response.body}';
      }
    } catch (error) {
      return 'An error occurred: $error';
    }
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homepagetest()),
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result;
        });
      }
    } else if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Chatpage()),
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result;
        });
      }
    } else if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StatisticPage()),
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result;
        });
      }
    } else if (index == 3) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result;
        });
      }
    }
    {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/loginpagebg.png"),
          _buildChatInterface(context),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.chat, 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.bar_chart, 2),
            _buildNavItem(Icons.settings, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                    message['user']!, message['response']!);
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String? userMessage, String? aiResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userMessage != null && userMessage.isNotEmpty)
          _messageBubble(userMessage, Colors.white),
        if (aiResponse != null && aiResponse.isNotEmpty)
          _messageBubble(aiResponse, Colors.grey[200]!),
      ],
    );
  }

  Widget _messageBubble(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: const Color(0xFF438883),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(icon),
      color: isSelected ? const Color(0xFF429690) : Colors.grey,
      iconSize: isSelected ? 36 : 28,
    );
  }
}
