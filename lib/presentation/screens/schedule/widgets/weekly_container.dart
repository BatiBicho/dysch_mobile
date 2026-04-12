import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:flutter/material.dart';

class WeeklyCalendarStrip extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final bool isCurrentWeek;

  const WeeklyCalendarStrip({
    super.key,
    required this.schedules,
    this.isCurrentWeek = true,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final referenceDay = isCurrentWeek ? today : today.add(const Duration(days: 7));
    final weekDays = _generateWeekDays(referenceDay);
    final scheduleDates = schedules.map((s) => _dateOnly(DateTime.parse(s.shiftDate))).toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.map((day) {
          final isToday = isCurrentWeek && _isSameDay(day, today);
          final hasSchedule = scheduleDates.contains(_dateOnly(day));
          return _buildDayCell(day, isToday: isToday, hasSchedule: hasSchedule);
        }).toList(),
      ),
    );
  }

  List<DateTime> _generateWeekDays(DateTime reference) {
    final monday = reference.subtract(Duration(days: reference.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Widget _buildDayCell(DateTime day, {required bool isToday, required bool hasSchedule}) {
    final dayLabel = _getDayLabel(day.weekday);

    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Text(
            dayLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isToday ? AppColors.primary : const Color(0xFFBBBBBB),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: hasSchedule && !isToday
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isToday
                      ? Colors.white
                      : hasSchedule
                          ? AppColors.primary
                          : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: hasSchedule
                  ? (isToday ? Colors.white : AppColors.primary)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int weekday) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return labels[weekday - 1];
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}