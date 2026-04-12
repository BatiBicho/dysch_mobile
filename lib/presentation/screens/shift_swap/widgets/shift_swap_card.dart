import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/shift_swap_model.dart';
import 'package:dysch_mobile/presentation/screens/shift_swap/swap_detail_screen.dart';
import 'package:flutter/material.dart';

class ShiftSwapCard extends StatelessWidget {
  final ShiftSwapModel swap;

  const ShiftSwapCard({super.key, required this.swap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SwapDetailScreen(swap: swap)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatusStrip(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildParticipants()),
                      const SizedBox(width: 12),
                      _buildDate(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildShiftCountRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStrip() {
    final color = _getStatusColor();
    final config = _getStatusConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Icon(config['icon'] as IconData, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            config['label'] as String,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
          const Spacer(),
          Text(
            config['description'] as String,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonRow(
          swap.requestingEmployeeName,
          swap.requestingEmployeeCode,
          label: 'Solicitante',
          isRequester: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(Icons.swap_vert_rounded, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
        _buildPersonRow(
          swap.targetEmployeeName,
          swap.targetEmployeeCode,
          label: 'Compañero',
          isRequester: false,
        ),
      ],
    );
  }

  Widget _buildPersonRow(String name, String code, {required String label, required bool isRequester}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isRequester
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.info.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isRequester ? AppColors.primary : AppColors.info,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'ID: $code',
                style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatDate(swap.requestedAt),
          style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 18),
      ],
    );
  }

  Widget _buildShiftCountRow() {
    return Row(
      children: [
        _buildShiftBadge(
          count: swap.requestingSchedulesDetail.length,
          label: 'turnos',
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.grey[300]),
        const SizedBox(width: 8),
        _buildShiftBadge(
          count: swap.targetSchedulesDetail.length,
          label: 'turnos',
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildShiftBadge({required int count, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.85), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (swap.status) {
      case 'PENDING_PEER':
        return const Color(0xFFF59E0B);
      case 'PENDING_SUPERVISOR':
        return const Color(0xFF6366F1);
      case 'APPROVED':
        return const Color(0xFF10B981);
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (swap.status) {
      case 'PENDING_PEER':
        return {
          'icon': Icons.person_outline_rounded,
          'label': 'Esperando al compañero',
          'description': 'Pendiente de aceptación',
        };
      case 'PENDING_SUPERVISOR':
        return {
          'icon': Icons.supervisor_account_outlined,
          'label': 'En revisión del supervisor',
          'description': 'El compañero ha aceptado',
        };
      case 'APPROVED':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'label': 'Aprobado',
          'description': 'Intercambio confirmado',
        };
      case 'REJECTED':
        return {
          'icon': Icons.cancel_outlined,
          'label': 'Rechazado',
          'description': 'Solicitud rechazada',
        };
      default:
        return {
          'icon': Icons.info_outline_rounded,
          'label': swap.displayStatus,
          'description': '',
        };
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}