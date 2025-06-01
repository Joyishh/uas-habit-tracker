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
    print('[DEBUG][HabitEntries.fromJson] raw json: $json');
    return HabitEntries(
      id: json['id']?.toString() ?? '',
      habitId: json['habit_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      entryDate: json['entry_date'] != null ? DateTime.parse(json['entry_date'].toString()) : DateTime.now(),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
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