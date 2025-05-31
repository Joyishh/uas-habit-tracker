import 'package:flutter/material.dart';
import 'package:ui_habit_tracker/screens/home/edit_habit_screen.dart';
import 'package:ui_habit_tracker/widgets/frequency_selector.dart';
import 'package:ui_habit_tracker/widgets/day_selector.dart';
import 'package:ui_habit_tracker/widgets/color_picker.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: const Text('Details My Habit'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF183B4E)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditHabitScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Habit
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: 'Lari Mingguan',),
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF183B4E),
                    width: 2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF183B4E),
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            const SizedBox(height: 24),
            // Description
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: 'Lari tiap hari minggu pagi'),
              enabled: false,
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF183B4E),
                    width: 2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF183B4E),
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400 , color: Colors.black),
            ),
            const SizedBox(height: 24),
            // Frequency
            const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            FrequencySelector(
              selected: 'weekly',
              options: const ['daily', 'weekly'],
              onChanged: (_) {}, // dummy, tidak interaktif
            ),
            const SizedBox(height: 8),
            // Target Day hanya tampil jika weekly
            if ('weekly' == 'weekly') ...[
              const Text('Target Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 8),
              DaySelector(
                days: const ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
                selectedDays: const {'Sunday'},
                onDayToggled: (_) {}, // dummy, tidak interaktif
              ),
              const SizedBox(height: 24),
            ],
            // Color
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ColorPicker(
              colors: const [
                Colors.green, Colors.yellow, Colors.red, Colors.orange, Colors.cyan, Colors.blue, Colors.pink
              ],
              selectedIndex: 0, // hijau terpilih
              onColorSelected: (_) {}, // dummy, tidak interaktif
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF183B4E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text(
                  'Check-in',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
