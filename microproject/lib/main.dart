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
      theme: ThemeData.light(),
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 250),
            const SizedBox(height: 20),
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

  void _showTaskInputDialog() {
    TextEditingController taskController = TextEditingController();
    TextEditingController targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: "Task Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Target (Numeric)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _submitTask(taskController.text, targetController.text);
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showProgressDialog(int index) {
    TextEditingController progressController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Achieved Progress"),
          content: TextField(
            controller: progressController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Progress made"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _taskHistory[_currentDate]![index]['achieved'] =
                      int.tryParse(progressController.text) ?? 0;
                  _taskHistory[_currentDate]![index]['completed'] = true;
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

  void _submitTask(String taskText, dynamic targetText) {
    int? target = int.tryParse(targetText);
    if (taskText.isNotEmpty && target != null && target > 0) {
      setState(() {
        DateTime todayDate = DateTime.parse(_today);
        for (int i = 0; i < 365; i++) {
          String futureDate =
              todayDate.add(Duration(days: i)).toIso8601String().split('T')[0];
          _taskHistory.putIfAbsent(futureDate, () => []);
          _taskHistory[futureDate]!.add({
            'text': taskText,
            'completed': false,
            'streakIncremented': false,
            'target': target,
            'achieved': 0
          });
        }
        _controller.clear();
      });

      // Check if the streak should be decremented because a new task was added
      if (_taskHistory[_currentDate]!.any((task) => !task['completed'])) {
        if (_taskHistory[_currentDate]!
            .any((task) => task['streakIncremented'])) {
          setState(() {
            _streak--;
            _petLevel--;
            for (var task in _taskHistory[_currentDate]!) {
              task['streakIncremented'] = false;
            }
          });
        }
      }
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      if (_taskHistory.containsKey(_currentDate) &&
          index < _taskHistory[_currentDate]!.length) {
        _taskHistory[_currentDate]![index]['completed'] =
            !_taskHistory[_currentDate]![index]['completed'];
      }
      if (_taskHistory[_currentDate]![index]['completed']) {
        _showProgressDialog(index);
      }

      int totalTasks = _taskHistory[_currentDate]!.length;
      int completedTasks =
          _taskHistory[_currentDate]!.where((task) => task['completed']).length;

      // Pet level logic based on task completion fraction
      int newPetLevel = 1;
      if (totalTasks > 0) {
        if (completedTasks >= (totalTasks * 1 / 4)) newPetLevel = 2;
        if (completedTasks >= (totalTasks * 2 / 4)) newPetLevel = 3;
        if (completedTasks >= (totalTasks * 3 / 4)) newPetLevel = 4;
      }

      _petLevel = newPetLevel;

      // Streak logic remains unchanged
      bool allTasksCompleted = completedTasks == totalTasks && totalTasks > 0;

      if (allTasksCompleted) {
        if (!_taskHistory[_currentDate]!
            .any((task) => task['streakIncremented'])) {
          _streak++;
          for (var task in _taskHistory[_currentDate]!) {
            task['streakIncremented'] = true;
          }
        }
      } else {
        if (_taskHistory[_currentDate]!
            .any((task) => task['streakIncremented'])) {
          _streak--;
          for (var task in _taskHistory[_currentDate]!) {
            task['streakIncremented'] = false;
          }
        }
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
                  _taskHistory[_currentDate]![index]['text'] =
                      editController.text;
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
                      itemCount: _taskHistory[_currentDate]?.length ??
                          0, // Corrected this line
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key:
                              UniqueKey(), // Ensures unique identification for each item
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
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection
                              .horizontal, // Allow both left and right swipes
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              // Swipe Left - Delete Task
                              setState(() {
                                // Find task text before removing
                                String taskText =
                                    _taskHistory[_currentDate]![index]['text'];

                                // Remove from all future dates
                                DateTime todayDate =
                                    DateTime.parse(_currentDate);
                                for (int i = 0; i < 365; i++) {
                                  String futureDate = todayDate
                                      .add(Duration(days: i))
                                      .toIso8601String()
                                      .split('T')[0];
                                  _taskHistory[futureDate]?.removeWhere(
                                      (task) => task['text'] == taskText);
                                }
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Task deleted")),
                              );
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              // Swipe Right - Edit Task
                              _editTask(index);
                            }
                          },
                          child: ListTile(
                            leading: Checkbox(
                              shape: const CircleBorder(),
                              checkColor: Colors.black,
                              activeColor: Colors.white,
                              value: _taskHistory[_currentDate]![index]
                                  ['completed'],
                              onChanged: (bool? value) {
                                _toggleTaskCompletion(index);
                              },
                            ),
                            title: Text(
                                "${_taskHistory[_currentDate]![index]['text']} (Target: ${_taskHistory[_currentDate]![index]['target']}${_taskHistory[_currentDate]![index]['completed'] ? ", Achieved: ${_taskHistory[_currentDate]![index]['achieved']}" : ""})"),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.pink, // Background color
                          shape: BoxShape.circle, // Circular shape
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add,
                              size: 30, color: Colors.white),
                          onPressed: () => _showTaskInputDialog(),
                          padding: const EdgeInsets.all(
                              15), // Padding for larger tap area
                          constraints:
                              const BoxConstraints(), // Removes default constraints
                        ),
                      ),
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
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.black,
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
