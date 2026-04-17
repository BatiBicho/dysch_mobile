import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/logic/attendance/attendance_cubit.dart';
import 'package:dysch_mobile/logic/schedule/schedule_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';

class AttendanceCard extends StatefulWidget {
  const AttendanceCard({super.key});

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {

  @override
  void initState() {
    super.initState();

    String? employeeId;
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthSuccess) {
      employeeId = authState.user.employeeId;
    }

    final today = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(today);

    context.read<ScheduleCubit>().getSchedule(
      dateString,
      employeeId: employeeId,
    );
  }

  String _formatTime(String time) {
    try {
      final DateTime tempDate = DateFormat("HH:mm:ss").parse(time);
      return DateFormat('hh:mma').format(tempDate).toLowerCase();
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      buildWhen: (previous, current) =>
        current is ScheduleLoading ||
        current is ScheduleSuccess ||
        current is ScheduleError,
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return const _AttendanceLoading();
        }

        if (state is ScheduleSuccess) {
          final schedule = state.schedules;

          if (schedule == null) {
            return _buildRestCard();
          }

          // Inicializar el cubit de asistencia con el estado del turno
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<AttendanceCubit>().initFromSchedule(
                  isCompleted: schedule.isCompleted,
                  startTime: schedule.startTime,
                  endTime: schedule.endTime,
                );
          });

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const StreamClock(),
                Text(
                  'Tu turno: ${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _ActionButton(
                  startTime: schedule.startTime,
                  endTime: schedule.endTime,
                ),
              ],
            ),
          );
        }

        if (state is ScheduleError) {
          return _buildErrorState(context, state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRestCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.beach_access, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            '¡Descansa hoy!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes turno programado',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Widget separado para el botón de acción, reactivo al AttendanceCubit.
class _ActionButton extends StatelessWidget {
  final String startTime;
  final String endTime;

  const _ActionButton({required this.startTime, required this.endTime});

  /// Retorna true si ahora mismo está dentro de la ventana de ±15 min.
  bool _isWithinWindow(AttendanceAction action) {
    final now = DateTime.now();

    DateTime? parseTime(String t) {
      final p = t.split(':');
      if (p.length < 2) return null;
      return DateTime(now.year, now.month, now.day,
          int.tryParse(p[0]) ?? 0, int.tryParse(p[1]) ?? 0);
    }

    if (action == AttendanceAction.checkIn) {
      final start = parseTime(startTime);
      final end = parseTime(endTime);
      // Bloqueado si el turno ya terminó o si falta más de 15 min para empezar
      if (end != null && now.difference(end).inMinutes > 15) return false;
      if (start != null && start.difference(now).inMinutes > 15) return false;
      return true;
    } else {
      final end = parseTime(endTime);
      if (end == null) return true;
      final diff = now.difference(end).inMinutes;
      return diff >= -15 && diff <= 15;
    }
  }

  String _windowHint(AttendanceAction action) {
    final now = DateTime.now();
    DateTime? parseTime(String t) {
      final p = t.split(':');
      if (p.length < 2) return null;
      return DateTime(now.year, now.month, now.day,
          int.tryParse(p[0]) ?? 0, int.tryParse(p[1]) ?? 0);
    }

    if (action == AttendanceAction.checkIn) {
      final end = parseTime(endTime);
      if (end != null && now.difference(end).inMinutes > 15) {
        return 'Tu turno ya finalizó';
      }
      final start = parseTime(startTime);
      if (start != null && start.difference(now).inMinutes > 15) {
        final mins = start.difference(now).inMinutes;
        return 'Disponible en $mins min';
      }
    } else {
      final end = parseTime(endTime);
      if (end != null) {
        final diff = now.difference(end).inMinutes;
        if (diff < -15) {
          return 'Disponible en ${end.difference(now).inMinutes} min';
        }
        if (diff > 15) return 'Ventana de salida expirada';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        final hasCheckedIn =
            state is AttendanceReady ? state.hasCheckedIn : false;
        final hasCheckedOut =
            state is AttendanceReady ? state.hasCheckedOut : false;

        // Turno completamente registrado
        if (hasCheckedIn && hasCheckedOut) {
          return _buildCompletedBadge();
        }

        // Ya hizo check-in → mostrar botón de check-out
        if (hasCheckedIn) {
          final action = AttendanceAction.checkOut;
          final enabled = _isWithinWindow(action);
          return _buildButton(
            context,
            label: 'REGISTRAR SALIDA',
            icon: Icons.logout,
            color: Colors.orange,
            action: action,
            enabled: enabled,
            hint: enabled ? null : _windowHint(action),
          );
        }

        // Sin check-in → mostrar botón de entrada
        final action = AttendanceAction.checkIn;
        final enabled = _isWithinWindow(action);
        return _buildButton(
          context,
          label: 'REGISTRAR ENTRADA',
          icon: Icons.fingerprint,
          color: AppColors.primary,
          action: action,
          enabled: enabled,
          hint: enabled ? null : _windowHint(action),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required AttendanceAction action,
    required bool enabled,
    String? hint,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: enabled
              ? () => context.push(
                    '/qr',
                    extra: {
                      'action': action,
                      'startTime': startTime,
                      'endTime': endTime,
                    },
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
            minimumSize: const Size(double.infinity, 64),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text(
            hint,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turno Completado',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green),
                ),
                Text(
                  'Tu turno de hoy ya ha sido registrado',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildErrorState(BuildContext context, String message) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
        const SizedBox(height: 16),
        const Text(
          '¡Ups! Algo salió mal',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => context.read<ScheduleCubit>().getSchedule(
                "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
              ),
          icon: const Icon(Icons.refresh),
          label: const Text('REINTENTAR'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

class _AttendanceLoading extends StatelessWidget {
  const _AttendanceLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class StreamClock extends StatelessWidget {
  const StreamClock({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final timeString = DateFormat('hh:mm a').format(now).toUpperCase();
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        );
      },
    );
  }
}