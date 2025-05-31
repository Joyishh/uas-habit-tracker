import 'package:flutter/material.dart';
import 'package:ui_habit_tracker/widgets/frequency_selector.dart';
import 'package:ui_habit_tracker/widgets/day_selector.dart';
import 'package:ui_habit_tracker/widgets/color_picker.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _frequency = 'Weekly';
  final List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];
  final Set<String> _selectedDays = {};
  final List<Color> _colors = [
    Color(0xFFBFFF5B), Color(0xFFFFFF5B), Color(0xFFFF5B5B), Color(0xFFFFC85B),
    Color(0xFF5BFFD7), Color(0xFF5B8BFF), Color(0xFFFF5BFF)
  ];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF163B4D),
        title: const Text('Add Habit', style: TextStyle(fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Nama Habit',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF163B4D)),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            ),
            const SizedBox(height: 18),
            const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            FrequencySelector(
              selected: _frequency,
              options: const ['Daily', 'Weekly'],
              onChanged: (val) => setState(() => _frequency = val),
            ),
            if (_frequency == 'Weekly') ...[
              const SizedBox(height: 8),
              const Text('Target Day', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
            ],
            const SizedBox(height: 18),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ColorPicker(
              colors: _colors,
              selectedIndex: _selectedColor,
              onColorSelected: (i) => setState(() => _selectedColor = i),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF163B4D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Add Habit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
