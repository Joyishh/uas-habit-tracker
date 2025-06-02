import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_habit_tracker/models/habit_entries.dart';
import 'package:ui_habit_tracker/models/habits.dart';
import 'package:ui_habit_tracker/screens/home/edit_habit_screen.dart';
import 'package:ui_habit_tracker/services/habit_service.dart';
import 'package:ui_habit_tracker/services/habit_entries_service.dart';
import 'package:ui_habit_tracker/widgets/color_picker.dart';
import 'package:ui_habit_tracker/widgets/day_selector.dart';
import 'package:ui_habit_tracker/widgets/frequency_selector.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habits habit;
  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habits _habit;
  bool _isLoading = true;
  List<HabitEntries> _entries = [];
  bool _alreadyCheckinToday = false;
  bool _canCheckinToday = true;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _fetchHabit();
    _fetchEntriesAndCheckStatus();
  }

  Future<void> _fetchEntriesAndCheckStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    try {
      final entries = await HabitEntriesService().getEntriesForHabit(
        habitId: _habit.id,
        token: token,
      );
      setState(() {
        _entries = entries;
      });
      _updateCheckinStatus();
    } catch (_) {}
  }

  void _updateCheckinStatus() {
    print('[DEBUG][CALL] _updateCheckinStatus called. _habit.daysOfWeek: \\${_habit.daysOfWeek}');
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);
    final weekday = now.weekday == 7 ? 0 : now.weekday;
    final allowedDays = (_habit.daysOfWeek as List?)?.cast<int>() ?? [];
    print('[DEBUG] Today: $todayStr, weekday: $weekday, allowedDays: $allowedDays');
    _alreadyCheckinToday = _entries.any((e) => e.entryDate.toIso8601String().substring(0, 10) == todayStr);
    if (_habit.frequencyType.toLowerCase() == 'daily') {
      _canCheckinToday = !_alreadyCheckinToday;
    } else if (_habit.frequencyType.toLowerCase() == 'specific_days_of_week' || _habit.frequencyType.toLowerCase() == 'weekly') {
      final isTargetDay = allowedDays.contains(weekday);
      print('[DEBUG] isTargetDay: $isTargetDay, alreadyCheckinToday: $_alreadyCheckinToday');
      if (!isTargetDay) {
        _canCheckinToday = false;
      } else {
        _canCheckinToday = !_alreadyCheckinToday;
      }
    } else {
      _canCheckinToday = !_alreadyCheckinToday;
    }
    print('[DEBUG] _canCheckinToday: $_canCheckinToday');
    setState(() {});
  }

  Future<void> _fetchHabit() async {
    setState(() { _isLoading = true; });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final habits = await HabitService().getAllHabits(token);
        final updated = habits.firstWhere((h) => h.id == _habit.id, orElse: () => _habit);
        setState(() {
          _habit = updated;
        });
        _updateCheckinStatus(); // Pastikan selalu update status setelah update habit
      } catch (_) {}
    }
    setState(() { _isLoading = false; });
  }

  void _onCheckIn() async {
    if (!_canCheckinToday) return; // Guard: jangan kirim request jika tidak boleh check-in
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated')),
      );
      return;
    }
    try {
      final now = DateTime.now();
      final dateStr = now.toIso8601String().substring(0, 10); // yyyy-MM-dd
      await HabitEntriesService().checkInHabit(
        habitId: _habit.id,
        date: dateStr,
        token: token,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in successful!')),
      );
      // Update local state & fetch entries to refresh status
      await _fetchEntriesAndCheckStatus();
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('unique_habit_entry_per_day')) {
        errorMsg = 'You have already checked in for today!';
        // Langsung update state agar tombol berubah
        setState(() {
          _alreadyCheckinToday = true;
          _canCheckinToday = false;
        });
        // Refresh entries to update UI
        await _fetchEntriesAndCheckStatus();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check-in: $errorMsg')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: const Text('Details My Habit', style: TextStyle(fontWeight: FontWeight.w600),),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF183B4E)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: _habit),
                ),
              );
              // Tambahkan pop dengan result true jika ada perubahan
              if (result == true) {
                await _fetchHabit();
                Navigator.pop(context, true); // trigger refresh HomeScreen
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Habit
                  const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: _habit.name),
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
                    controller: TextEditingController(text: _habit.description),
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
                  const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                  const SizedBox(height: 8),
                  FrequencySelector(
                    selected: _habit.frequencyType.toLowerCase() == 'specific_days_of_week' ? 'weekly' : _habit.frequencyType.toLowerCase(),
                    options: const ['daily', 'weekly'],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 8),
                  // Target Day hanya tampil jika weekly
                  if (_habit.frequencyType.toLowerCase() == 'weekly' || _habit.frequencyType.toLowerCase() == 'specific_days_of_week') ...[
                    const Text('Target Day', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                    SizedBox(height: 8),
                    DaySelector(
                      days: const ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
                      selectedDays: _habit.daysOfWeek != null && _habit.daysOfWeek is List
                        ? (_habit.daysOfWeek as List).map((e) => _dayNameFromIndex(e)).toSet()
                        : <String>{},
                      onDayToggled: (_) {}, // dummy, tidak interaktif
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Color
                  const Text('Color', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                  const SizedBox(height: 8),
                  ColorPicker(
                    colors: const [
                      Colors.green, Colors.yellow, Colors.red, Colors.orange, Colors.cyan, Colors.blue, Colors.pink
                    ],
                    selectedIndex: _colorIndexFromHex(_habit.colorHex),
                    onColorSelected: (_) {}, // dummy, tidak interaktif
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Builder(
                      builder: (context) {
                        print('[DEBUG][BUILD] _canCheckinToday: [32m$_canCheckinToday[0m, _alreadyCheckinToday: $_alreadyCheckinToday');
                        return ElevatedButton(
                          onPressed: _canCheckinToday ? () {
                            _onCheckIn();
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canCheckinToday ? const Color(0xFF183B4E) : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          ),
                          child: Text(
                            _habit.frequencyType.toLowerCase() == 'daily'
                              ? (_alreadyCheckinToday ? 'Already check-in today' : 'Check-in')
                              : (_habit.frequencyType.toLowerCase() == 'specific_days_of_week' || _habit.frequencyType.toLowerCase() == 'weekly')
                                ? (!_isTargetDayForWeekly() ? 'Not available for today' : (_alreadyCheckinToday ? 'Already check-in today' : 'Check-in'))
                                : 'Check-in',
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper untuk konversi index hari ke nama hari
  static String _dayNameFromIndex(dynamic index) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    if (index is int && index >= 0 && index < days.length) {
      return days[index];
    }
    return '';
  }

  // Helper untuk konversi hex warna ke index ColorPicker
  static int _colorIndexFromHex(String hex) {
    const colorHexes = ['#4CAF50', '#FFEB3B', '#F44336', '#FF9800', '#00BCD4', '#2196F3', '#E91E63'];
    final idx = colorHexes.indexWhere((h) => h.toLowerCase() == hex.toLowerCase());
    return idx >= 0 ? idx : 0;
  }

  // Helper untuk cek apakah hari ini adalah target day (untuk weekly/specific_days_of_week)
  bool _isTargetDayForWeekly() {
    if (!(_habit.frequencyType.toLowerCase() == 'specific_days_of_week' || _habit.frequencyType.toLowerCase() == 'weekly')) return true;
    final now = DateTime.now();
    final weekday = now.weekday == 7 ? 0 : now.weekday;
    final allowedDays = (_habit.daysOfWeek as List?)?.cast<int>() ?? [];
    return allowedDays.contains(weekday);
  }
}
