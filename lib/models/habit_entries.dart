class HabitEntries {
  final String id;
  final String habitId;
  final String userId;
  final DateTime entryDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitEntries({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.entryDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitEntries.fromJson(Map<String, dynamic> json) {
    return HabitEntries(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      entryDate: DateTime.parse(json['entry_date'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'entry_date': entryDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}