import 'package:dysch_mobile/presentation/screens/schedule/widgets/weekly_container.dart';
import 'package:flutter/material.dart';
import 'widgets/current_shift_card.dart';
import 'widgets/upcoming_shift_item.dart';

class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Schedules',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: () {}),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyCalendarStrip(),

            // Sección: Turno de hoy
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Today's Shift",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            CurrentShiftCard(),

            // Sección: Próximos
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                "Upcoming",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            UpcomingShiftItem(
              day: 'THU',
              date: '26',
              title: '08:00 AM - 05:00 PM',
              subtitle: 'Sucursal Norte',
            ),
            UpcomingShiftItem(
              day: 'FRI',
              date: '27',
              title: '09:00 AM - 06:00 PM',
              subtitle: 'Sucursal Centro',
            ),
            UpcomingShiftItem(
              day: 'SAT',
              date: '28',
              title: 'Descanso',
              subtitle: 'Rest Day',
              isRestDay: true,
            ),
          ],
        ),
      ),
    );
  }
}
