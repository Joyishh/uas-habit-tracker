import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/habits.dart';

class HabitService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  Future<List<Habits>> getAllHabits(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/habit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Habits.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load habits');
    }
  }

  Future<Habits> createHabit(Habits habit, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(habit.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Habits.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create habit');
    }
  }

  Future<Habits> updateHabit(Habits habit, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/habit/${habit.id}'),
      headers: {
        'Authorization' : 'Bearer $token',
        'Content-Type': 'application/json'
        },
      body: jsonEncode(habit.toJson()),
    );
    if (response.statusCode == 200) {
      return Habits.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update habit');
    }
  }

  Future<void> deleteHabit(Habits habit, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/habit/${habit.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete habit');
    }
  }
}