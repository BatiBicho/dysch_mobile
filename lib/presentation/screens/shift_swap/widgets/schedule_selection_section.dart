import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:flutter/material.dart';

class ScheduleSelectionSection extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final Set<String> selectedSchedules;
  final Function(String) onScheduleToggle;
  final String emptyMessage;

  const ScheduleSelectionSection({
    super.key,
    required this.schedules,
    required this.selectedSchedules,
    required this.onScheduleToggle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 36, color: Colors.grey[200]),
              const SizedBox(height: 10),
              Text(
                emptyMessage,
                style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F3F3)),
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            final isSelected = selectedSchedules.contains(schedule.id);
            return _buildItem(schedule, isSelected);
          },
        ),
      ),
    );
  }

  Widget _buildItem(ScheduleModel schedule, bool isSelected) {
    return InkWell(
      onTap: () => onScheduleToggle(schedule.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
        child: Row(
          children: [

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFDDDDDD),
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),

            // Left accent
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 3,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Schedule info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(schedule.shiftDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatTime(schedule.startTime)} – ${_formatTime(schedule.endTime)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return timeString;
    } catch (_) {
      return timeString;
    }
  }
}