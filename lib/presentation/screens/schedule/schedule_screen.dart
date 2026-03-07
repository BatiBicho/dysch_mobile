import 'package:dysch_mobile/logic/schedule/schedule_cubit.dart';
import 'package:dysch_mobile/presentation/screens/schedule/widgets/weekly_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/upcoming_shift_item.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleCubit>().getWeekSchedule();
  }

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
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WeekScheduleSuccess) {
            final schedules = state.schedules.schedules;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeeklyCalendarStrip(schedules: schedules),

                  // Sección: Próximos
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      "Upcoming",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...schedules.map((schedule) {
                    final dateTime = DateTime.parse(schedule.shiftDate);
                    final dayName = _getDayName(dateTime.weekday);
                    final dayNumber = dateTime.day.toString();
                    final timeRange = _formatTimeRange(
                      schedule.startTime,
                      schedule.endTime,
                    );

                    return UpcomingShiftItem(
                      day: dayName,
                      date: dayNumber,
                      title: timeRange,
                      subtitle: schedule.companyName ?? 'Sin empresa',
                    );
                  }).toList(),
                ],
              ),
            );
          }

          if (state is ScheduleError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  String _formatTimeRange(String startTime, String endTime) {
    try {
      final start = _formatTime(startTime);
      final end = _formatTime(endTime);
      return '$start - $end';
    } catch (e) {
      return '$startTime - $endTime';
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }
}
