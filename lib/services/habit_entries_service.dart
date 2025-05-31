import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
}