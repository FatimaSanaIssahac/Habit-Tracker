import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.add_a_photo, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text("User ID: 12345", style: TextStyle(fontSize: 18)),
          const Text("User Name: Fatima", style: TextStyle(fontSize: 18)),
          const Text("User Level: 0", style: TextStyle(fontSize: 18)), // Level logic can be added later
        ],
      ),
    );
  }
}
