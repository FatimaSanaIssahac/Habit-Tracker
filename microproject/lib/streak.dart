import 'package:flutter/material.dart';

class StreakScreen extends StatelessWidget {
  final int streak;
  const StreakScreen({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "🔥 Streak: $streak days",
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
    );
  }
}
