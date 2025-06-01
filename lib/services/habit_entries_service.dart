import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/habit_entries.dart';

class HabitEntriesService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  Future<void> checkInHabit({
    required String habitId,
    required String date,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habit/$habitId/check-in'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'date': date}),
    );
    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to check-in habit');
    }
    return;
  }

  Future<List<HabitEntries>> getEntriesForHabit({
    required String habitId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/habit/$habitId/entries'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => HabitEntries.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch habit entries');
    }
  }
}