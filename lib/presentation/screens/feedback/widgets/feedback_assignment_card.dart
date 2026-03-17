import 'package:dysch_mobile/data/models/feedback_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _kOrange = Color(0xFFFF6B35);

class FeedbackAssignmentCard extends StatelessWidget {
  final FeedbackAssignmentModel assignment;
  final VoidCallback? onReload;

  const FeedbackAssignmentCard({
    super.key,
    required this.assignment,
    this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final bool expired = assignment.isExpired;
    final campaign = assignment.campaign;

    return GestureDetector(
      onTap: expired ? null : () async {
        final campaign = assignment.campaign;
        if (campaign == null) return;

        await context.push('/take-feedback', extra: {
          'campaignId': assignment.campaignId,
          'campaignName': assignment.campaignName,
          'topicId': campaign.topicId,
          'topicTitle': campaign.topicTitle,
          'resultsVisibleToEmployees': campaign.resultsVisibleToEmployees,
          'isAnonymous': campaign.isAnonymous,
          'employeeCode': assignment.employeeCode,
        });

        onReload?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: expired ? const Color(0xFFF9F9F9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: expired
              ? []
              : [
                  BoxShadow(
                    color: _kOrange.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: expired
                ? Colors.grey.shade200
                : _kOrange.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  color: expired ? Colors.grey.shade300 : _kOrange,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatusBadge(expired: expired),
                            if (campaign != null && campaign.isAnonymous)
                              Tooltip(
                                message: 'Respuestas anónimas',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility_off_outlined,
                                      size: 13,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Anónima',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          assignment.campaignName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: expired
                                ? Colors.grey.shade400
                                : const Color(0xFF1A1A2E),
                            height: 1.3,
                          ),
                        ),

                        if (campaign != null) ...[
                          const SizedBox(height: 10),

                          _TopicPill(
                            label: campaign.topicTitle,
                            expired: expired,
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: expired
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${_fmt(campaign.startDate)} – ${_fmt(campaign.endDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: expired
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        if (!expired)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toca para responder',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _kOrange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Contestar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 13,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Período de respuesta finalizado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime date) => DateFormat('dd MMM yyyy', 'es').format(date);
}

// Auxiliares:
class _StatusBadge extends StatelessWidget {
  final bool expired;
  const _StatusBadge({required this.expired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: expired
            ? Colors.grey.shade100
            : _kOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: expired ? Colors.grey.shade400 : _kOrange,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            expired ? 'Expirada' : 'Pendiente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: expired ? Colors.grey.shade500 : _kOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  final String label;
  final bool expired;

  const _TopicPill({required this.label, required this.expired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: expired
            ? Colors.grey.shade100
            : const Color(0xFFFFF3EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_rounded,
            size: 12,
            color: expired ? Colors.grey.shade400 : _kOrange,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: expired ? Colors.grey.shade400 : _kOrange,
            ),
          ),
        ],
      ),
    );
  }
}