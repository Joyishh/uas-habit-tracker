import 'package:flutter/material.dart';
import 'package:ui_habit_tracker/widgets/frequency_selector.dart';
import 'package:ui_habit_tracker/widgets/day_selector.dart';
import 'package:ui_habit_tracker/widgets/color_picker.dart';

class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({Key? key}) : super(key: key);

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final TextEditingController _titleController = TextEditingController(text: 'Lari Mingguan');
  final TextEditingController _descController = TextEditingController(text: 'Lari tiap hari minggu pagi');
  String _frequency = 'Weekly';
  final List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];
  final Set<String> _selectedDays = {'Sunday'};
  final List<Color> _colors = [
    Colors.green, Colors.yellow, Colors.red, Colors.orange, Colors.cyan, Colors.blue, Colors.pink
  ];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: const Text('Edit Habit'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Nama Habit',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF163B4D)),
                ),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description (Optional)',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF163B4D)),
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
            ),
            const SizedBox(height: 24),
            const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            FrequencySelector(
              selected: _frequency,
              options: const ['Daily', 'Weekly'],
              onChanged: (val) => setState(() => _frequency = val),
            ),
            const SizedBox(height: 8),
            if (_frequency == 'Weekly') ...[
              const Text('Target Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              DaySelector(
                days: _days,
                selectedDays: _selectedDays,
                onDayToggled: (day) {
                  setState(() {
                    if (_selectedDays.contains(day)) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ColorPicker(
              colors: _colors,
              selectedIndex: _selectedColor,
              onColorSelected: (i) => setState(() => _selectedColor = i),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Simpan perubahan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF183B4E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
