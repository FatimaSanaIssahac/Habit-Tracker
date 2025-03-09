import 'package:flutter/material.dart';

class PetScreen extends StatelessWidget {
  final int petLevel;

  const PetScreen({super.key, required this.petLevel});

  // Function to get pet image based on mood/level
  String getPetImage() {
    if (petLevel < 2) {
      return 'assets/sad_pet.gif';
    } else if (petLevel < 3) {
      return 'assets/neutral_pet.gif';
    } else {
      return 'assets/happy_pet.gif';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated size change as level increases
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            width: 100 + petLevel * 5, // Increases size with level
            height: 100 + petLevel * 5,
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: petLevel > 1 ? 1.0 : 0.5, // Fades in as level increases
              child: Image.asset(getPetImage()), // Pet image changes with level
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "🐾 Pet Level: $petLevel",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
