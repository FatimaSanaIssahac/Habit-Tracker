import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GraphScreen extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> taskHistory;

  const GraphScreen({super.key, required this.taskHistory});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late String selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void navigateDay(int offset) {
    DateTime current = DateFormat('yyyy-MM-dd').parse(selectedDate);
    DateTime newDate = current.add(Duration(days: offset));
    setState(() {
      selectedDate = DateFormat('yyyy-MM-dd').format(newDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>>? tasks = widget.taskHistory[selectedDate];
    return Scaffold(
      appBar: AppBar(title: const Text("Progress Graphs")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => navigateDay(-1),
                ),
                Text(
                  "Date: $selectedDate",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => navigateDay(1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            tasks == null || tasks.isEmpty
                ? const Center(
                    child: Text("No Data Available",
                        style: TextStyle(fontSize: 16)))
                : Expanded(
                    child: ListView(
                      children: tasks.map((task) {
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['text'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  height: 200,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                                toY: task['target'].toDouble(),
                                                color: Colors.blue,
                                                width: 16),
                                            BarChartRodData(
                                                toY:
                                                    task['achieved'].toDouble(),
                                                color: Colors.green,
                                                width: 16),
                                          ],
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: true),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: true),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}