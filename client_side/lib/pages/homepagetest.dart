import 'package:expensetracker/pages/chatpage.dart';
import 'package:expensetracker/service/database.dart';
import 'package:expensetracker/pages/statisticpage.dart';
import 'package:expensetracker/pages/settingsPage.dart';
import 'package:expensetracker/widget/plus_button.dart';
import 'package:expensetracker/widget/top_card.dart';
import 'package:expensetracker/widget/transactions.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/service/authService.dart';
import 'package:expensetracker/pages/authentication/loginPage.dart';

class Homepagetest extends StatefulWidget {
  const Homepagetest({super.key});

  @override
  State<Homepagetest> createState() => _HomepagetestState();
}

class _HomepagetestState extends State<Homepagetest> {
  final _textcontrollerAMOUNT = TextEditingController();
  final _textcontrollerITEM = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isIncome = false;
  int _selectedIndex = 0;
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
  }

  void _enterTransaction() async {
    await LocalStorageApi.insert(
      _textcontrollerITEM.text,
      _textcontrollerAMOUNT.text,
      _isIncome,
    );
    _fetchData();
  }

  void _newTransaction() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'N E W  T R A N S A C T I O N',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Expense'),
                        Switch(
                          value: _isIncome,
                          onChanged: (newValue) {
                            setState(() {
                              _isIncome = newValue;
                            });
                          },
                        ),
                        Text('Income'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Amount?',
                              ),
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Enter an amount';
                                }
                                return null;
                              },
                              controller: _textcontrollerAMOUNT,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'For what?',
                            ),
                            controller: _textcontrollerITEM,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            'Enter',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _enterTransaction();
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateTransaction(
      String id, String item, String amount, bool isIncome) async {
    await LocalStorageApi.updateTransaction(id, item, amount, isIncome);
    _fetchData();
  }

  void _deleteTransaction(String id, bool isIncome) async {
    await LocalStorageApi.deleteTransaction(id, isIncome);
    _fetchData();
  }

  void _showUpdateDialog(String id, String item, String amount, bool isIncome) {
    _textcontrollerITEM.text = item;
    _textcontrollerAMOUNT.text = amount;
    _isIncome = isIncome;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Transaction'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  controller: _textcontrollerITEM,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  controller: _textcontrollerAMOUNT,
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Expense'),
                    Switch(
                      value: _isIncome,
                      onChanged: (newValue) {
                        setState(() {
                          _isIncome = newValue;
                        });
                      },
                    ),
                    Text('Income'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateTransaction(id, _textcontrollerITEM.text,
                      _textcontrollerAMOUNT.text, _isIncome);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) async {
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
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF429690),
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF429690),
                ),
                child: Center(
                  child: Text(
                    'FinTrack',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                iconColor: Colors.white,
                leading: const Icon(Icons.home),
                title:
                    const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                iconColor: Colors.white,
                leading: const Icon(Icons.settings),
                title: const Text('Settings',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                iconColor: Colors.white,
                leading: const Icon(Icons.logout),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: PlusButton(function: _newTransaction),
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
      body: Stack(
        children: [
          Image.asset("assets/images/homepagebg.png"),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                      color: Colors.white,
                      iconSize: 28,
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: TopCard(
                    balance: (_income - _expense).toString(),
                    income: _income.toString(),
                    expense: _expense.toString(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              var transaction = _transactions[index];
                              return MyTransaction(
                                id: transaction['_id'],
                                transactionName: transaction['description'],
                                money: transaction['amount'].toString(),
                                expenseOrIncome: transaction['category'],
                                onDelete: (id) => _deleteTransaction(
                                    id, transaction['category'] == 'income'),
                                onUpdate: (id) => _showUpdateDialog(
                                    id,
                                    transaction['description'],
                                    transaction['amount'].toString(),
                                    transaction['category'] == 'income'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
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
