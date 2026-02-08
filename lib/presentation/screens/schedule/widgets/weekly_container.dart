import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class WeeklyCalendarStrip extends StatelessWidget {
  const WeeklyCalendarStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDayItem('Mon', '23', false),
          _buildDayItem('Tue', '24', false),
          _buildDayItem('Wed', '25', true), // Día seleccionado
          _buildDayItem('Thu', '26', false),
          _buildDayItem('Fri', '27', false),
        ],
      ),
    );
  }

  Widget _buildDayItem(String day, String number, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryOrange
            : AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white70 : Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            number,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isSelected)
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
