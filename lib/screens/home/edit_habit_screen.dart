import 'package:flutter/material.dart';
import 'package:ui_habit_tracker/widgets/frequency_selector.dart';
import 'package:ui_habit_tracker/widgets/day_selector.dart';
import 'package:ui_habit_tracker/widgets/color_picker.dart';
import 'package:ui_habit_tracker/models/habits.dart';
import 'package:ui_habit_tracker/services/habit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditHabitScreen extends StatefulWidget {
  final Habits habit;
  const EditHabitScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
    late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _frequency;
  late Set<String> _selectedDays;
  late int _selectedColor;

  final List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];
  final List<Color> _colors = [
    Colors.green, Colors.yellow, Colors.red, Colors.orange, Colors.cyan, Colors.blue, Colors.pink
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.name);
    _descController = TextEditingController(text: widget.habit.description);
    _frequency = widget.habit.frequencyType.toLowerCase() == 'specific_days_of_week' ? 'Weekly' : widget.habit.frequencyType[0].toUpperCase() + widget.habit.frequencyType.substring(1).toLowerCase();
    _selectedDays = (widget.habit.daysOfWeek is List && widget.habit.daysOfWeek != null)
        ? (widget.habit.daysOfWeek as List).map((e) => _days[e as int]).toSet()
        : <String>{};
    _selectedColor = _colorIndexFromHex(widget.habit.colorHex);
  }

  static int _colorIndexFromHex(String hex) {
    const colorHexes = ['#4CAF50', '#FFEB3B', '#F44336', '#FF9800', '#00BCD4', '#2196F3', '#E91E63'];
    final idx = colorHexes.indexWhere((h) => h.toLowerCase() == hex.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
                onPressed: () async {
                  // Validasi
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Title cannot be empty')),
                    );
                    return;
                  }
                  if (_frequency == 'Weekly' && _selectedDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one day for weekly habit')),
                    );
                    return;
                  }
                  // Ambil token
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');
                  if (token == null) return;
                  // Siapkan data habit baru
                  final updatedHabit = Habits(
                    id: widget.habit.id,
                    userId: widget.habit.userId,
                    name: _titleController.text.trim(),
                    description: _descController.text.trim(),
                    colorHex: '#${_colors[_selectedColor].value.toRadixString(16).substring(2)}',
                    frequencyType: _frequency == 'Weekly' ? 'specific_days_of_week' : _frequency.toLowerCase(),
                    daysOfWeek: _frequency == 'Weekly' ? _selectedDays.map((d) => _days.indexOf(d)).toList() : null,
                    createdAt: widget.habit.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  try {
                    await HabitService().updateHabit(updatedHabit, token);
                    if (!mounted) return;
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update habit: $e')),
                    );
                  }
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
