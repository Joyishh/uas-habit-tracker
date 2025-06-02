import 'package:flutter/material.dart';

class FrequencySelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const FrequencySelector({
    Key? key,
    required this.selected,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: options.map((option) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: option,
            groupValue: selected,
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
            activeColor: const Color(0xFF163B4D),
          ),
          Text(
            option,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
        ],
      )).toList(),
    );
  }
}
