import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ui_habit_tracker/widgets/calendar_habit_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_habit_tracker/services/habit_service.dart';
import 'package:ui_habit_tracker/services/habit_entries_service.dart';
import 'package:ui_habit_tracker/models/habits.dart';
import 'package:ui_habit_tracker/models/habit_entries.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isLoading = true;
  String? _error;

  // Map<Date, List<Habits>>: tanggal -> habits yang seharusnya dikerjakan
  Map<DateTime, List<Habits>> _habitsPerDay = {};
  // Map<Date, List<HabitEntries>>: tanggal -> entries yang sudah dikerjakan
  Map<DateTime, List<HabitEntries>> _entriesPerDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchData();
  }

  // Helper untuk normalisasi tanggal
  DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token found');
      final habits = await HabitService().getAllHabits(token);
      final now = _focusedDay;
      final entries = await HabitEntriesService().getEntriesByMonthYear(
        month: now.month,
        year: now.year,
        token: token,
      );
      // Mapping habits ke tanggal sesuai algoritma
      final Map<DateTime, List<Habits>> habitsPerDay = {};
      for (final habit in habits) {
        for (int i = 1; i <= DateUtils.getDaysInMonth(now.year, now.month); i++) {
          final date = dateOnly(DateTime(now.year, now.month, i));
          if (_isHabitScheduledOn(habit, date)) {
            habitsPerDay.putIfAbsent(date, () => []).add(habit);
          }
        }
      }
      // Mapping entries ke tanggal
      final Map<DateTime, List<HabitEntries>> entriesPerDay = {};
      for (final entry in entries) {
        final date = dateOnly(entry.entryDate);
        entriesPerDay.putIfAbsent(date, () => []).add(entry);
      }
      setState(() {
        _habitsPerDay = habitsPerDay;
        _entriesPerDay = entriesPerDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  bool _isHabitScheduledOn(Habits habit, DateTime date) {
    if (habit.frequencyType.toLowerCase() == 'daily') return true;
    if (habit.frequencyType.toLowerCase() == 'specific_days_of_week' || habit.frequencyType.toLowerCase() == 'weekly') {
      final allowedDays = (habit.daysOfWeek as List?)?.cast<int>() ?? [];
      final weekday = date.weekday == 7 ? 0 : date.weekday;
      return allowedDays.contains(weekday);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: \\$_error'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                          _fetchData();
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: const Color(0xFF27548A).withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF27548A),
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: true,
                          markersMaxCount: 3,
                          markerDecoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronVisible: true,
                          rightChevronVisible: true,
                        ),
                        calendarFormat: CalendarFormat.month,
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final habits = _habitsPerDay[dateOnly(date)] ?? [];
                            if (habits.isEmpty) return null;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: habits.take(3).map((habit) {
                                Color color;
                                try {
                                  color = Color(int.parse(habit.colorHex.replaceFirst('#', '0xff')));
                                } catch (_) {
                                  color = Colors.green;
                                }
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            ...(_habitsPerDay[dateOnly(_selectedDay ?? DateTime.now())] ?? []).map((habit) {
                              Color color;
                              try {
                                color = Color(int.parse(habit.colorHex.replaceFirst('#', '0xff')));
                              } catch (_) {
                                color = Colors.green;
                              }
                              // Cek apakah sudah completed pada hari itu
                              final entries = _entriesPerDay[dateOnly(_selectedDay ?? DateTime.now())] ?? [];
                              final isChecked = entries.any((e) => e.habitId == habit.id && e.status == 'completed');
                              return CalendarHabitCard(
                                dotColor: color,
                                title: habit.name,
                                isChecked: isChecked,
                                onCheck: null,
                              );
                            }).toList(),
                            if ((_habitsPerDay[dateOnly(_selectedDay ?? DateTime.now())] ?? []).isEmpty)
                              const Center(child: Text('No habit for this day')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
