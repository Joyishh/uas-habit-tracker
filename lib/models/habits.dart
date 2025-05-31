class Habits {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String colorHex;
  final String frequencyType;
  final String daysOfWeek;
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
    return Habits(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      colorHex: json['color_hex'] as String,
      frequencyType: json['frequency_type'] as String,
      daysOfWeek: json['days_of_week'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'color_hex': colorHex,
      'frequency_type': frequencyType,
      'days_of_week': daysOfWeek,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}