import 'package:flutter/material.dart';
import 'dart:async';

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
      home: const SplashScreen(),
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
        MaterialPageRoute(
            builder: (context) =>
                const MyHomePage(title: 'Habit Tracker Game')),
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
            Image.asset('assets/logo.png', width: 150),
            const SizedBox(height: 20),
            const Text(
              'Habit Tracker',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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

class _MyHomePageState extends State<MyHomePage> {
  final Map<String, List<Map<String, dynamic>>> _taskHistory = {};
  final TextEditingController _controller = TextEditingController();
  bool _showTextField = false;
  late String _currentDate;
  late String _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().toIso8601String().split('T')[0];
    _currentDate = _today;
    _taskHistory[_currentDate] = [];
  }

  void _addTask() {
    setState(() {
      _showTextField = true;
    });
  }

  void _submitTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _taskHistory[_currentDate]!
            .add({'text': _controller.text, 'completed': false});
        _controller.clear();
        _showTextField = false;
      });
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _taskHistory[_currentDate]![index]['completed'] =
          !_taskHistory[_currentDate]![index]['completed'];
    });
  }

  void _loadPreviousDayTasks() {
    setState(() {
      DateTime previousDay =
          DateTime.parse(_currentDate).subtract(const Duration(days: 1));
      _currentDate = previousDay.toIso8601String().split('T')[0];
      _taskHistory.putIfAbsent(_currentDate, () => []);
    });
  }

  void _loadNextDayTasks() {
    if (_currentDate != _today) {
      setState(() {
        DateTime nextDay =
            DateTime.parse(_currentDate).add(const Duration(days: 1));
        _currentDate = nextDay.toIso8601String().split('T')[0];
        _taskHistory.putIfAbsent(_currentDate, () => []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Tasks for $_currentDate",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _taskHistory[_currentDate]?.length ?? 0,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_taskHistory[_currentDate]![index]['text']),
                    value: _taskHistory[_currentDate]![index]['completed'],
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _loadPreviousDayTasks,
                  child: const Text("Previous Day"),
                ),
                ElevatedButton(
                  onPressed: _currentDate != _today ? _loadNextDayTasks : null,
                  child: const Text("Next Day"),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
