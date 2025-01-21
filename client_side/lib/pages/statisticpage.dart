import 'package:flutter/material.dart';
import 'package:expensetracker/service/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  double _income = 0.0;
  double _expense = 0.0;
  List<dynamic> _transactions = [];
  List<Map<String, dynamic>> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final transactions = await LocalStorageApi.getTransactions();
    final double incomeData = await LocalStorageApi.calculateIncome();
    final double expenseData = await LocalStorageApi.calculateExpense();

    setState(() {
      _transactions = transactions;
      _income = incomeData;
      _expense = expenseData;
      _monthlyData =
          _processMonthlyData(transactions); // Pass transactions list
    });
  }

  List<Map<String, dynamic>> _processMonthlyData(List<dynamic> transactions) {
    Map<String, Map<String, double>> monthlyData = {};

    for (var transaction in transactions) {
      String month = DateFormat('yyyy-MM')
          .format(DateTime.parse(transaction['createdAt']));
      if (!monthlyData.containsKey(month)) {
        monthlyData[month] = {'income': 0.0, 'expense': 0.0};
      }

      // Update income or expense based on the transaction type
      if (transaction['category'] == 'income') {
        monthlyData[month]!['income'] =
            (monthlyData[month]!['income'] ?? 0) + transaction['amount'];
      } else if (transaction['category'] == 'expense') {
        monthlyData[month]!['expense'] =
            (monthlyData[month]!['expense'] ?? 0) + transaction['amount'];
      }

      print('Monthly Data: $monthlyData');
    }

    // Convert the map into a list
    return monthlyData.entries
        .map((entry) => {
              'month': entry.key,
              'income': entry.value['income']!,
              'expense': entry.value['expense']!,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        backgroundColor: const Color(0xFF429690),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Income: \$$_income',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Expense: \$$_expense',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildPieChart(),
              SizedBox(height: 20),
              _buildBarChart(),
              SizedBox(height: 20),
              SizedBox(
                height:
                    400, // Set a fixed height to avoid dynamic height issues
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    var transaction = _transactions[index];
                    return ListTile(
                      title: Text(transaction['description']),
                      subtitle: Text(transaction['category']),
                      trailing: Text('\$${transaction['amount']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: _income,
              title: 'Income',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: _expense,
              title: 'Expense',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_monthlyData.isEmpty) {
      return const Text('No data available for the bar chart.');
    }

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < _monthlyData.length; i++) {
      var monthData = _monthlyData[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthData['income'],
              color: Colors.green,
              width: 20,
            ),
            BarChartRodData(
              toY: monthData['expense'],
              color: Colors.red,
              width: 20,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: false), // Hide left axis labels
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  // Get the month name from the month number
                  String monthLabel = _monthlyData[value.toInt()]['month'];
                  DateTime date = DateFormat('yyyy-MM').parse(monthLabel);
                  return Text(DateFormat('MMM yyyy').format(date));
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false), // Hide the grid lines
        ),
      ),
    );
  }
}
