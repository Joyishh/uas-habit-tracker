import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_habit_tracker/services/habit_service.dart';
import 'package:ui_habit_tracker/models/habits.dart';
import 'package:ui_habit_tracker/widgets/habit_card.dart';
import 'package:ui_habit_tracker/screens/home/habit_detail_screen.dart';
import 'package:ui_habit_tracker/screens/home/add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Habits>> _habitsFuture;
  final HabitService _habitService = HabitService();

  // Tambahkan state untuk selection mode dan selected habits
  bool _selectionMode = false;
  Set<String> _selectedHabitIds = {};

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Habits>> _fetchHabits() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    return _habitService.getAllHabits(token);
  }

  @override
  void initState() {
    super.initState();
    _habitsFuture = _fetchHabits();
  }

  void _toggleSelection(String habitId) {
    setState(() {
      if (_selectedHabitIds.contains(habitId)) {
        _selectedHabitIds.remove(habitId);
        if (_selectedHabitIds.isEmpty) _selectionMode = false;
      } else {
        _selectedHabitIds.add(habitId);
        _selectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedHabitIds.clear();
    });
  }

  Future<void> _deleteSelectedHabits(List<Habits> habits) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habits'),
        content: Text(
            'Delete ${_selectedHabitIds.length} selected habit(s)? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        for (final habit
            in habits.where((h) => _selectedHabitIds.contains(h.id))) {
          try {
            await _habitService.deleteHabit(habit, token);
          } catch (_) {}
        }
        setState(() {
          _selectionMode = false;
          _selectedHabitIds.clear();
          _habitsFuture = _fetchHabits();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedHabitIds.length} selected')
            : const Text('My Habit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final habits = await _habitsFuture;
                    await _deleteSelectedHabits(habits);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                ),
              ]
            : null,
      ),
      body: FutureBuilder<List<Habits>>(
        future: _habitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No habits found'));
          }
          final habits = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isSelected = _selectedHabitIds.contains(habit.id);
              return GestureDetector(
                onLongPress: () => _toggleSelection(habit.id),
                onTap: () async {
                  if (_selectionMode) {
                    _toggleSelection(habit.id);
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitDetailScreen(habit: habit),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _habitsFuture = _fetchHabits();
                      });
                    }
                  }
                },
                child: Stack(
                  children: [
                    HabitCard(
                      title: habit.name,
                      description: habit.description,
                      color:
                          Color(int.parse(habit.colorHex.replaceFirst('#', '0xff'))),
                    ),
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.check_circle,
                                  color: Colors.blue, size: 28),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff27548A),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHabitScreen(),
            ),
          );
          if (result == true) {
            setState(() {
              _habitsFuture = _fetchHabits();
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
