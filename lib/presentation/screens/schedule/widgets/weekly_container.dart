import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:flutter/material.dart';

class WeeklyCalendarStrip extends StatefulWidget {
  final List<ScheduleModel> schedules;

  const WeeklyCalendarStrip({super.key, required this.schedules});

  @override
  State<WeeklyCalendarStrip> createState() => _WeeklyCalendarStripState();
}

class _WeeklyCalendarStripState extends State<WeeklyCalendarStrip> {
  late DateTime today;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = _generateWeekDays();
    final scheduleDates = widget.schedules
        .map((s) => DateTime.parse(s.shiftDate))
        .toSet();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: daysOfWeek.map((day) {
            final isToday =
                day.year == today.year &&
                day.month == today.month &&
                day.day == today.day;
            final hasSchedule = scheduleDates.contains(day);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildDayItem(
                _getDayName(day.weekday),
                day.day.toString().padLeft(2, '0'),
                isToday,
                hasSchedule,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<DateTime> _generateWeekDays() {
    final currentDay = today;
    final startOfWeek = currentDay.subtract(
      Duration(days: currentDay.weekday - 1),
    );
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _buildDayItem(
    String day,
    String number,
    bool isToday,
    bool hasSchedule,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
        border: hasSchedule && !isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isToday ? Colors.white70 : Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            number,
            style: TextStyle(
              color: isToday ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
