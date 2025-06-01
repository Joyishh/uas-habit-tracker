import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/habit_service.dart';
import '../../services/habit_entries_service.dart';
import '../../models/habits.dart';
import '../../models/habit_entries.dart';
import '../../widgets/pie_chart_stats.dart';
import '../../widgets/progres_bar_stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedFilter = 'Weekly';

  Future<Map<String, dynamic>> _fetchStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');
    final habits = await HabitService().getAllHabits(token);
    // Ambil semua entries untuk semua habit
    final Map<String, List<HabitEntries>> entriesMap = {};
    for (final habit in habits) {
      final entries = await HabitEntriesService().getEntriesForHabit(habitId: habit.id, token: token);
      entriesMap[habit.id] = entries;
    }
    return {'habits': habits, 'entriesMap': entriesMap};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          print('[DEBUG][STATS] snapshot.data: \\${snapshot.data}');
          if (snapshot.data == null) {
            return const Center(child: Text('No data'));
          }
          if (!snapshot.data!.containsKey('habits') || !snapshot.data!.containsKey('entriesMap')) {
            return const Center(child: Text('Data format error: missing keys'));
          }
          final habitsRaw = snapshot.data!['habits'];
          final entriesMapRaw = snapshot.data!['entriesMap'];
          if (habitsRaw == null || entriesMapRaw == null) {
            return const Center(child: Text('Data null'));
          }
          if (habitsRaw is! List<Habits> || entriesMapRaw is! Map<String, List<HabitEntries>>) {
            return Center(child: Text('Data type error: habits=${habitsRaw.runtimeType}, entriesMap=${entriesMapRaw.runtimeType}'));
          }
          final habits = habitsRaw as List<Habits>;
          final entriesMap = entriesMapRaw as Map<String, List<HabitEntries>>;
          print('[DEBUG][STATS] habits.length: \\${habits.length}, entriesMap.keys: \\${entriesMap.keys}');

          // Hitung statistik per habit
          final now = DateTime.now();
          DateTime startDate;
          DateTime endDate;
          if (_selectedFilter == 'Weekly') {
            startDate = now.subtract(Duration(days: now.weekday - 1));
            endDate = startDate.add(const Duration(days: 6));
          } else {
            startDate = DateTime(now.year, now.month, 1);
            endDate = DateTime(now.year, now.month + 1, 0);
          }
          List<Map<String, dynamic>> statHabits = [];
          for (final habit in habits) {
            print('[DEBUG][STATS] habit: id=\\${habit.id}, name=\\${habit.name}, colorHex=\\${habit.colorHex}, freq=\\${habit.frequencyType}, daysOfWeek=\\${habit.daysOfWeek}');
            // Hitung target days
            int targetDays = 0;
            if (habit.frequencyType.toLowerCase() == 'daily') {
              targetDays = endDate.difference(startDate).inDays + 1;
            } else if (habit.frequencyType.toLowerCase() == 'weekly' || habit.frequencyType.toLowerCase() == 'specific_days_of_week') {
              final allowedDays = (habit.daysOfWeek as List?)?.cast<int>() ?? [];
              for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
                final d = startDate.add(Duration(days: i));
                final weekday = d.weekday == 7 ? 0 : d.weekday;
                if (allowedDays.contains(weekday)) targetDays++;
              }
            }
            // Hitung check-in
            final entries = entriesMap[habit.id] ?? [];
            int checkinCount = entries.where((e) => e.entryDate.isAfter(startDate.subtract(const Duration(days: 1))) && e.entryDate.isBefore(endDate.add(const Duration(days: 1)))).length;
            double percent = targetDays > 0 ? checkinCount / targetDays : 0;
            // Debug print untuk trace error
            print('[DEBUG][STATS] habit: id=${habit.id}, name=${habit.name}, colorHex=${habit.colorHex}');
            String colorHex = habit.colorHex.isNotEmpty ? habit.colorHex : '#2196F3';
            Color color;
            try {
              color = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
            } catch (e) {
              print('[DEBUG][STATS] color parse error: $e, colorHex=$colorHex');
              color = const Color(0xFF2196F3);
            }
            statHabits.add({
              'title': habit.name,
              'percent': percent,
              'color': color,
              'dotColor': color,
              'value': checkinCount.toDouble(),
            });
          }

          // Pie chart sections
          final pieSections = statHabits.map((h) => PieChartSectionData(
            color: h['color'],
            value: h['value'],
            title: '${h['title']}\n${h['value']}',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            radius: 120,
          )).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF27548A), width:2),
                          borderRadius: BorderRadius.circular(24),
                          color: const Color(0xFFE6FFF7),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(16),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27548A),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF27548A),
                            size: 28,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Weekly',
                              child: Text('Weekly'),
                            ),
                            DropdownMenuItem(
                              value: 'Monthly',
                              child: Text('Monthly'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedFilter = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: PieChartStats(sections: pieSections),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...statHabits.map(
                    (habit) => ProgressBarStats(
                      title: habit['title'] as String,
                      percent: habit['percent'] as double,
                      color: habit['color'] as Color,
                      dotColor: habit['dotColor'] as Color,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
