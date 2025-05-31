import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  const ColorPicker({
    Key? key,
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(colors.length, (i) => GestureDetector(
        onTap: () => onColorSelected(i),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors[i],
            shape: BoxShape.circle,
            border: Border.all(
              color: selectedIndex == i ? const Color(0xFF163B4D) : Colors.transparent,
              width: 2,
            ),
          ),
          child: selectedIndex == i
              ? const Icon(Icons.check, color: Color(0xFF183B4E), size: 20)
              : null,
        ),
      )),
    );
  }
}
