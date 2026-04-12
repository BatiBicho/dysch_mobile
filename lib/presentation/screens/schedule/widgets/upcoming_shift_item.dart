import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:flutter/material.dart';

class UpcomingShiftItem extends StatelessWidget {
  final ScheduleModel schedule;
  final DateTime dateTime;
  final bool isToday;

  const UpcomingShiftItem({
    super.key,
    required this.schedule,
    required this.dateTime,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isToday ? 0.06 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : const Color(0xFFEEEEEE),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              children: [
                Text(
                  _getDayLabel(dateTime.weekday),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isToday ? AppColors.primary : const Color(0xFF9E9E9E),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dateTime.day}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isToday ? AppColors.primary : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          Container(width: 1, height: 40, color: const Color(0xFFF0F0F0)),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatTime(schedule.startTime)} – ${_formatTime(schedule.endTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isToday ? AppColors.primary : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.companyName ?? 'Sin empresa',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: isToday
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Hoy',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  )
                : Text(
                    _duration(schedule.startTime, schedule.endTime),
                    style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB), fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int weekday) {
    const labels = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return labels[weekday - 1];
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final display = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$display:$minute $period';
    } catch (_) {
      return time;
    }
  }

  String _duration(String start, String end) {
    try {
      final sParts = start.split(':');
      final eParts = end.split(':');
      final startMins = int.parse(sParts[0]) * 60 + int.parse(sParts[1]);
      final endMins = int.parse(eParts[0]) * 60 + int.parse(eParts[1]);
      final diff = endMins - startMins;
      if (diff <= 0) return '';
      final h = diff ~/ 60;
      final m = diff % 60;
      return m == 0 ? '${h}h' : '${h}h ${m}m';
    } catch (_) {
      return '';
    }
  }
}