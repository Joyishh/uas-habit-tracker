import 'package:flutter/material.dart';
import 'package:ui_habit_tracker/widgets/habit_card.dart';
import 'package:ui_habit_tracker/screens/home/habit_detail_screen.dart';
import 'package:ui_habit_tracker/screens/home/add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: const Text('My Habit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HabitDetailScreen(),
                ),
              );
            },
            child: HabitCard(
              title: 'Lari Mingguan',
              description: 'Lari tiap hari minggu pagi',
              color: Colors.blue,
            ),
          ),
          HabitCard(
            title: 'Ngoding Project',
            description: 'Progress Capstone, UAS, dan Sprint',
            color: Colors.green,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff27548A),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHabitScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
