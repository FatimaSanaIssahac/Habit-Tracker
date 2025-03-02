import 'package:flutter/material.dart';

class PetScreen extends StatelessWidget {
  final int petLevel;
  const PetScreen({super.key, required this.petLevel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "🐾 Pet Level: $petLevel",
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }
}
