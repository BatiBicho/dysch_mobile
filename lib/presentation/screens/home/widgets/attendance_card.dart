import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/logic/schedule/schedule_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return const _AttendanceLoading(); // Un placeholder bonito
        }

        if (state is ScheduleSuccess) {
          final schedule = state.schedules; // Asumiendo que es un objeto único

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
                // Badge de ubicación dinámico
                _buildLocationBadge('UBICACIÓN NO DETECTADA'),
                const SizedBox(height: 16),

                // Reloj o Tiempo Transcurrido
                const StreamClock(), // Un pequeño widget que se actualiza cada segundo

                Text(
                  'Tu turno: ${schedule.startTime} - ${schedule.endTime}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de Acción Principal
                _buildActionButton(context, schedule),
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

  Widget _buildLocationBadge(String location) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 14, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            location.toUpperCase(),
            style: const TextStyle(
              color: Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, dynamic schedule) {
    // Aquí podrías cambiar el color/texto si el usuario ya hizo Check-in
    bool alreadyCheckedIn = false;

    return ElevatedButton(
      onPressed: () => context.push('/qr'),
      style: ElevatedButton.styleFrom(
        backgroundColor: alreadyCheckedIn
            ? Colors.redAccent
            : AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(alreadyCheckedIn ? Icons.logout : Icons.fingerprint),
          const SizedBox(width: 12),
          Text(
            alreadyCheckedIn ? 'REGISTRAR SALIDA' : 'REGISTRAR ENTRADA',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
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
          onPressed: () {
            // Volvemos a intentar la carga
            context.read<ScheduleCubit>().getSchedule();
          },
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
        final timeString =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
          ),
        );
      },
    );
  }
}
