import 'package:expensetracker/pages/homepagetest.dart';
import 'package:expensetracker/pages/statisticpage.dart';
import 'package:expensetracker/service/database.dart';
import 'package:flutter/material.dart';
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
  int _selectedIndex = 1; // Set initial index to 1 for the chat page
  List<dynamic> _transactions = [];
  double _income = 0.0;
  double _expense = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
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
    summary += 'Total Income: \$$_income\n';
    summary += 'Total Expense: \$$_expense\n';
    summary += 'Transactions:\n';
    for (var transaction in _transactions) {
      summary +=
          '${transaction['description']}: \$${transaction['amount']} (${transaction['category']})\n';
    }

    setState(() {
      _messages.add({'user': '', 'response': summary});
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({'user': _messageController.text, 'response': '...'});
      });

      final response = await _getAIResponse(_messageController.text);

      setState(() {
        _messages[_messages.length - 1]['response'] = response;
        _messageController.clear(); // Clear the input field
      });
    }
  }

  Future<String> _getAIResponse(String message) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user': 'user_id', 'message': message}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data']['response'];
    } else {
      return 'Failed to get response from AI';
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
    }
    if (index == 1) {
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
    } else {
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
          Image.asset("assets/images/loginpagebg.png"), // Background image
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
            const SizedBox(width: 40), // Space for the notch
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

  Widget _buildMessageBubble(String userMessage, String aiResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
              userMessage,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
            aiResponse,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
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
      iconSize: isSelected ? 36 : 28, // Enlarge the selected icon
    );
  }
}
