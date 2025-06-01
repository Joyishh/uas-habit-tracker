class Habits {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String colorHex;
  final String frequencyType;
  final dynamic daysOfWeek;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habits({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.colorHex,
    required this.frequencyType,
    required this.daysOfWeek,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habits.fromJson(Map<String, dynamic> json) {
    // Debug print untuk days_of_week
    print('[DEBUG][Habits.fromJson] raw days_of_week: \\${json['days_of_week']}');
    // Pastikan daysOfWeek selalu List<int> atau []
    List<int> parsedDays = [];
    if (json['days_of_week'] is List) {
      parsedDays = (json['days_of_week'] as List)
          .where((e) => e != null)
          .map((e) => int.tryParse(e.toString()) ?? -1)
          .where((e) => e >= 0 && e <= 6)
          .toList();
    }
    print('[DEBUG][Habits.fromJson] parsed daysOfWeek: \\${parsedDays}');
    return Habits(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      colorHex: json['color_hex']?.toString() ?? '#2196F3',
      frequencyType: json['frequency_type']?.toString() ?? '',
      daysOfWeek: parsedDays,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId.isEmpty ? null : userId,
      'name': name,
      'description': description,
      'color_hex': colorHex,
      'frequency_type': frequencyType == 'Weekly' ? 'specific_days_of_week' : frequencyType.toLowerCase(),
      'days_of_week': daysOfWeek is List ? daysOfWeek : [],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}