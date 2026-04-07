
import 'package:flutter/material.dart';
import '../../habits/models/habit_model.dart';

class HeatmapWidget extends StatelessWidget {
  final List<HabitModel> habits;

  const HeatmapWidget({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final heatmapData = _buildHeatmapData();
    final maxVal =
        heatmapData.values.isEmpty ? 1 : heatmapData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Heatmap',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Last 12 weeks',
            style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildHeatmap(heatmapData, maxVal),
          const SizedBox(height: 12),
          _buildLegend(maxVal),
        ],
      ),
    );
  }

  Widget _buildHeatmap(Map<String, int> data, int maxVal) {
    final now = DateTime.now();
    final weeks = 12;
    final days = weeks * 7;
    final startDate = now.subtract(Duration(days: days - 1));

    final dateList = List.generate(
        days, (i) => startDate.add(Duration(days: i)));

    // Pad to start on Monday
    final firstWeekday = dateList.first.weekday - 1;
    final paddedList = [
      ...List.generate(firstWeekday, (_) => null),
      ...dateList.map<DateTime?>((d) => d),
    ];

    final totalCols = (paddedList.length / 7).ceil();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(totalCols, (col) {
          return Column(
            children: List.generate(7, (row) {
              final idx = col * 7 + row;
              if (idx >= paddedList.length || paddedList[idx] == null) {
                return const SizedBox(width: 14, height: 14);
              }
              final date = paddedList[idx]!;
              final dateStr = _dateStr(date);
              final count = data[dateStr] ?? 0;
              final intensity = maxVal == 0 ? 0.0 : count / maxVal;
              final isToday = _isToday(date);

              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: count == 0
                      ? const Color(0xFF27272A)
                      : Color.lerp(
                          const Color(0xFF3B1F8C),
                          const Color(0xFF7C3AED),
                          intensity,
                        ),
                  borderRadius: BorderRadius.circular(3),
                  border: isToday
                      ? Border.all(
                          color: const Color(0xFF7C3AED), width: 1)
                      : null,
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildLegend(int maxVal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Less',
            style: TextStyle(color: Color(0xFF71717A), fontSize: 11)),
        const SizedBox(width: 6),
        ...List.generate(5, (i) {
          final intensity = i / 4;
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: i == 0
                  ? const Color(0xFF27272A)
                  : Color.lerp(
                      const Color(0xFF3B1F8C),
                      const Color(0xFF7C3AED),
                      intensity,
                    ),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
        const SizedBox(width: 4),
        const Text('More',
            style: TextStyle(color: Color(0xFF71717A), fontSize: 11)),
      ],
    );
  }

  Map<String, int> _buildHeatmapData() {
    final Map<String, int> data = {};
    for (final habit in habits) {
      for (final dateStr in habit.completedDates) {
        data[dateStr] = (data[dateStr] ?? 0) + 1;
      }
    }
    return data;
  }

  String _dateStr(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}