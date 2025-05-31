import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartStats extends StatelessWidget {
  final List<PieChartSectionData> sections;

  const PieChartStats({Key? key, required this.sections}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 0,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}
