import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Chip(
            label: const Text(
              'OFICINA CDMX',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green.shade50,
            side: BorderSide.none,
            avatar: const Icon(
              Icons.location_on,
              size: 14,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '08:58 AM',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Turno Matutino • Entrada 9:00 AM',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/qr'),
            icon: const Icon(Icons.fingerprint),
            label: const Text('REGISTRAR ENTRADA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 60),
            ),
          ),
        ],
      ),
    );
  }
}
