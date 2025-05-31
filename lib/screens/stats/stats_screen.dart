import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../widgets/pie_chart_stats.dart';
import '../../widgets/progres_bar_stats.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final habits = [
      {
        'title': 'Lari Mingguan',
        'percent': 0.2,
        'color': const Color(0xFF27548A),
        'dotColor': Colors.blue,
        'value': 149.0,
      },
      {
        'title': 'Ngoding Project',
        'percent': 0.5,
        'color': const Color(0xFF27548A),
        'dotColor': Colors.green,
        'value': 119.92,
      },
    ];

    final pieSections = [
      PieChartSectionData(
        color: Colors.blue,
        value: 149,
        title: 'Lari Mingguan\n149',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        radius: 120, // diperbesar
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 119.92,
        title: 'Ngoding Project\n119.92',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        radius: 120, // diperbesar
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE6FFF7),
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: PieChartStats(sections: pieSections),
                ),
              ),
              const SizedBox(height: 24),
              ...habits.map((habit) => ProgressBarStats(
                    title: habit['title'] as String,
                    percent: habit['percent'] as double,
                    color: habit['color'] as Color,
                    dotColor: habit['dotColor'] as Color,
                  )),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
