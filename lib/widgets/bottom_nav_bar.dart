import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({Key? key, required this.currentIndex, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFDDA853),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarIcon(
                icon: Icons.check_circle_outline,
                label: 'Habit',
                selected: currentIndex == 0,
                onTap: () => onTap?.call(0),
              ),
              _NavBarIcon(
                icon: Icons.bar_chart,
                label: 'Stats',
                selected: currentIndex == 1,
                onTap: () => onTap?.call(1),
              ),
              _NavBarIcon(
                icon: Icons.calendar_today,
                label: 'Calendar',
                selected: currentIndex == 2,
                onTap: () => onTap?.call(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : const Color(0xff183B4E),
            size: 28,
          ),
        ],
      ),
    );
  }
}
