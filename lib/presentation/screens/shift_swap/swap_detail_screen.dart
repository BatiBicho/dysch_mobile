import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/models/shift_swap_model.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:dysch_mobile/logic/shift_swap/shift_swap_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwapDetailScreen extends StatelessWidget {
  final ShiftSwapModel swap;

  const SwapDetailScreen({super.key, required this.swap});

  void _showResponseDialog(BuildContext context, bool isAccept) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (isAccept ? Colors.green : AppColors.error).withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAccept ? Icons.check_rounded : Icons.close_rounded,
                  color: isAccept ? Colors.green : AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAccept ? '¿Aceptar solicitud?' : '¿Rechazar solicitud?',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              Text(
                isAccept
                    ? 'Al aceptar, pasará a revisión del supervisor para su aprobación final.'
                    : 'Al rechazar, se cancelará la solicitud. Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<ShiftSwapCubit>().respondAsPeer(
                              swapId: swap.id,
                              action: isAccept ? 'accept' : 'reject',
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAccept ? Colors.green : AppColors.error,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isAccept ? 'Aceptar' : 'Rechazar',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentEmployeeCode = authState is AuthSuccess ? authState.user.employeeCode : '';
    final canRespond = swap.canRespondAsPeer(currentEmployeeCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocListener<ShiftSwapCubit, ShiftSwapState>(
        listener: (context, state) {
          if (state is ShiftSwapResponseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          }
          if (state is ShiftSwapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildTimeline(),
                    const SizedBox(height: 20),
                    _buildParticipantsSection(),
                    const SizedBox(height: 20),
                    _buildSchedulesSection(
                      title: 'Turnos de ${swap.requestingEmployeeName.split(' ').first}',
                      schedules: swap.requestingSchedulesDetail,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildSchedulesSection(
                      title: 'Turnos de ${swap.targetEmployeeName.split(' ').first}',
                      schedules: swap.targetSchedulesDetail,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 20),
                    _buildDatesInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: canRespond && swap.status == 'PENDING_PEER'
          ? _buildActionBar(context)
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF1A1A1A)),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Detalle de solicitud',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final config = _getStatusConfig();
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(config['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config['label'] as String,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  config['description'] as String,
                  style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.75), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      _TimelineStep(
        label: 'Solicitud enviada',
        description: 'Por ${swap.requestingEmployeeName.split(' ').first}',
        isDone: true,
        icon: Icons.send_rounded,
      ),
      _TimelineStep(
        label: 'Aceptación del compañero',
        description: swap.status == 'PENDING_PEER'
            ? 'Esperando respuesta…'
            : swap.peerRespondedAt != null
                ? 'Aceptado · ${_formatDateTime(swap.peerRespondedAt!)}'
                : swap.status == 'REJECTED'
                    ? 'Rechazado'
                    : 'Pendiente',
        isDone: swap.status != 'PENDING_PEER',
        isRejected: swap.status == 'REJECTED' && swap.peerRespondedAt != null,
        icon: Icons.person_outline_rounded,
      ),
      _TimelineStep(
        label: 'Aprobación del supervisor',
        description: swap.status == 'PENDING_SUPERVISOR'
            ? 'En revisión…'
            : swap.supervisorRespondedAt != null
                ? swap.status == 'APPROVED'
                    ? 'Aprobado · ${_formatDateTime(swap.supervisorRespondedAt!)}'
                    : 'Rechazado · ${_formatDateTime(swap.supervisorRespondedAt!)}'
                : 'Pendiente',
        isDone: swap.status == 'APPROVED',
        isRejected: swap.status == 'REJECTED' && swap.supervisorRespondedAt != null,
        isPending: swap.status == 'PENDING_SUPERVISOR',
        icon: Icons.supervisor_account_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9E9E9E), letterSpacing: 0.3),
          ),
          const SizedBox(height: 14),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return _buildTimelineItem(step, isLast: isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_TimelineStep step, {required bool isLast}) {
    Color dotColor;
    IconData dotIcon;
    if (step.isRejected) {
      dotColor = AppColors.error;
      dotIcon = Icons.close_rounded;
    } else if (step.isDone) {
      dotColor = const Color(0xFF10B981);
      dotIcon = Icons.check_rounded;
    } else if (step.isPending) {
      dotColor = const Color(0xFF6366F1);
      dotIcon = Icons.hourglass_empty_rounded;
    } else {
      dotColor = const Color(0xFFE0E0E0);
      dotIcon = Icons.circle;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              child: Icon(dotIcon, color: Colors.white, size: 15),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 36,
                color: step.isDone || step.isRejected
                    ? dotColor.withValues(alpha: 0.3)
                    : const Color(0xFFEEEEEE),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text(step.description,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Participantes'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildParticipantCard(
                name: swap.requestingEmployeeName,
                code: swap.requestingEmployeeCode,
                role: 'Solicitante',
                color: AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.swap_horiz_rounded, color: Colors.grey[300], size: 22),
            ),
            Expanded(
              child: _buildParticipantCard(
                name: swap.targetEmployeeName,
                code: swap.targetEmployeeCode,
                role: 'Compañero',
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantCard({
    required String name,
    required String code,
    required String role,
    required Color color,
  }) {
    final firstName = name.split(' ').first;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            firstName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
          Text(
            'ID: $code',
            style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesSection({
    required String title,
    required List<ScheduleModel> schedules,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: title),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(schedules.length, (i) {
              final s = schedules[i];
              final isLast = i == schedules.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(s.shiftDate),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                            ),
                            Text(
                              '${_formatTime(s.startTime)} – ${_formatTime(s.endTime)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(height: 1, color: Color(0xFFF3F3F3), indent: 16),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDatesInfo() {
    final rows = <Map<String, String>>[
      {'label': 'Solicitado el', 'value': _formatDateTime(swap.requestedAt)},
      if (swap.peerRespondedAt != null)
        {'label': 'Compañero respondió', 'value': _formatDateTime(swap.peerRespondedAt!)},
      if (swap.supervisorRespondedAt != null)
        {'label': 'Supervisor respondió', 'value': _formatDateTime(swap.supervisorRespondedAt!)},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, color: Color(0xFFF3F3F3)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row['label']!, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                    Text(row['value']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tu compañero está esperando tu respuesta.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showResponseDialog(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Rechazar',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showResponseDialog(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Aceptar',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          'description': '${swap.targetEmployeeName.split(' ').first} aún no ha respondido la solicitud.',
        };
      case 'PENDING_SUPERVISOR':
        return {
          'icon': Icons.supervisor_account_outlined,
          'label': 'En revisión del supervisor',
          'description': '${swap.targetEmployeeName.split(' ').first} aceptó. Esperando aprobación final.',
        };
      case 'APPROVED':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'label': 'Intercambio aprobado',
          'description': 'El supervisor confirmó el intercambio de turnos.',
        };
      case 'REJECTED':
        return {
          'icon': Icons.cancel_outlined,
          'label': 'Solicitud rechazada',
          'description': 'El intercambio no fue autorizado.',
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

  String _formatDateTime(String dateTimeString) {
    try {
      final dt = DateTime.parse(dateTimeString);
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTimeString;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9E9E9E), letterSpacing: 0.3),
    );
  }
}

class _TimelineStep {
  final String label;
  final String description;
  final bool isDone;
  final bool isRejected;
  final bool isPending;
  final IconData icon;

  const _TimelineStep({
    required this.label,
    required this.description,
    this.isDone = false,
    this.isRejected = false,
    this.isPending = false,
    required this.icon,
  });
}