import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: user == null
              ? const Text('No user is logged in.')
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.account_circle,
                          color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 20),
                    Text("User ID: ${user.uid}",
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text("Email: ${user.email}",
                        style: const TextStyle(fontSize: 16)),
                    const Text("User Level: 0", style: TextStyle(fontSize: 1)),
                  ],
                ),
        ),
      ),
    );
  }
}
