import 'package:flutter/material.dart';
import 'dart:async';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Habit Tracker Game'),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Habit Tracker Game')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 150), // Ensure you have this image in assets
            const SizedBox(height: 20),
            const Text(
              'Habit Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _tasks = [];
  bool _showTextField = false;
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tabs: one for tasks, one for calendar
  }

  void _addTask() {
    setState(() {
      _showTextField = true;
    });
  }

  void _submitTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add({'text': _controller.text, 'completed': false});
        _controller.clear();
        _showTextField = false;
      });
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Task Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(_tasks[index]['text']),
                        value: _tasks[index]['completed'],
                        onChanged: (bool? value) {
                          _toggleTaskCompletion(index);
                        },
                      );
                    },
                  ),
                ),
                if (_showTextField)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: 'Enter task',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: _submitTask,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showTextField = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Calendar Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selectedDay, focusedDay) {
                // Handle the day selection
                print('Selected Day: $selectedDay');
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
