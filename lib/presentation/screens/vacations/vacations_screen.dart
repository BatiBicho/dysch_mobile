import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'widgets/vacation_summary_card.dart';
import 'widgets/vacation_calendar_view.dart';

class VacationsScreen extends StatelessWidget {
  const VacationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Gestión de Vacaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VacationSummaryCard(available: 12, total: 14),
            const SizedBox(height: 24),
            const VacationCalendarView(),
            const SizedBox(height: 24),
            const Text(
              'HISTORIAL RECIENTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              '15 Nov - 18 Nov',
              'Solicitud aprobada',
              Icons.check_circle,
              Colors.green,
            ),
            _buildHistoryItem(
              '10 Ago - 12 Ago',
              'Disfrutadas',
              Icons.history,
              Colors.grey,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildHistoryItem(
    String date,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: color.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
