import 'package:flutter/material.dart';
import 'dart:async';
import 'user.dart';
import 'streak.dart';
import 'pet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker Game',
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
            builder: (context) => const MyHomePage(title: 'Streakify')),
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
              'Habit Tracker Game',
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
  late String _currentDate;
  late String _today;
  int _selectedIndex = 0;
  int _streak = 0;
  int _petLevel = 1;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().toIso8601String().split('T')[0];
    _currentDate = _today;
    _taskHistory[_currentDate] = [];
  }

  void _submitTask(String taskText) {
  if (taskText.isNotEmpty) {
    setState(() {
      _taskHistory[_currentDate]!.add({'text': taskText, 'completed': false});
      _controller.clear();
    });
  }
}


  void _toggleTaskCompletion(int index) {
    setState(() {
      _taskHistory[_currentDate]![index]['completed'] =
          !_taskHistory[_currentDate]![index]['completed'];
      if (_taskHistory[_currentDate]!.every((task) => task['completed'])) {
        _streak++;
        _petLevel++;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

void _editTask(int index) {
  TextEditingController editController = TextEditingController(
    text: _taskHistory[_currentDate]![index]['text'],
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "Enter new task name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _taskHistory[_currentDate]![index]['text'] = editController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _selectedIndex == 0
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            DateTime previousDay = DateTime.parse(_currentDate)
                                .subtract(const Duration(days: 1));
                            _currentDate =
                                previousDay.toIso8601String().split('T')[0];
                            _taskHistory.putIfAbsent(_currentDate, () => []);
                          });
                        },
                      ),
                      Text(
                        _currentDate,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (_currentDate != _today) {
                            setState(() {
                              DateTime nextDay = DateTime.parse(_currentDate)
                                  .add(const Duration(days: 1));
                              _currentDate =
                                  nextDay.toIso8601String().split('T')[0];
                              _taskHistory.putIfAbsent(_currentDate, () => []);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Expanded(
  child: ListView.builder(
    itemCount: _taskHistory[_currentDate]?.length ?? 0,
    itemBuilder: (context, index) {
      return Dismissible(
        key: UniqueKey(), // Ensures unique identification for each item
        background: Container(
          color: Colors.blue, // Edit background
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        secondaryBackground: Container(
          color: Colors.red, // Delete background
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.horizontal, // Allow both left and right swipes
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            // Swipe Left - Delete Task
            setState(() {
              _taskHistory[_currentDate]!.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Task deleted")),
            );
          } else if (direction == DismissDirection.startToEnd) {
            // Swipe Right - Edit Task
            _editTask(index);
          }
        },
        child: ListTile(
          leading: Checkbox(
            shape: const CircleBorder(),
            checkColor: Colors.black,
            activeColor: Colors.white,
            value: _taskHistory[_currentDate]![index]['completed'],
            onChanged: (bool? value) {
              _toggleTaskCompletion(index);
            },
          ),
          title: Text(_taskHistory[_currentDate]![index]['text']),
        ),
      );
    },
  ),
),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                              hintText: "Enter a new task"),
                          onSubmitted: (value) => _submitTask(value),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => _submitTask(_controller.text)),
                    ],
                  ),
                ],
              ),
            )
          : _selectedIndex == 1
              ? const UserScreen()
              : _selectedIndex == 2
                  ? StreakScreen(streak: _streak)
                  : PetScreen(petLevel: _petLevel),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white70,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
          BottomNavigationBarItem(icon: Icon(Icons.whatshot), label: "Streak"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Garden"),
        ],
      ),
    );
  }
}
