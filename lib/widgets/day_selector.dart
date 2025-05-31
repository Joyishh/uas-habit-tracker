import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final List<String> days;
  final Set<String> selectedDays;
  final ValueChanged<String> onDayToggled;

  const DaySelector({
    Key? key,
    required this.days,
    required this.selectedDays,
    required this.onDayToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) => ChoiceChip(
        label: Text(day),
        selected: selectedDays.contains(day),
        onSelected: (selected) => onDayToggled(day),
        selectedColor: const Color(0xFF163B4D),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selectedDays.contains(day) ? Colors.white : const Color(0XFF183B4E),
        ),
        backgroundColor: Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      )).toList(),
    );
  }
}
