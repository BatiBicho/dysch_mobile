import 'package:dysch_mobile/data/models/feedback_model.dart';
import 'package:dysch_mobile/data/repositories/feedback_repository.dart';
import 'package:dysch_mobile/logic/feedback/feedback_cubit.dart';
import 'package:dysch_mobile/presentation/screens/feedback/widgets/feedback_assignment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _kOrange = Color(0xFFFF6B35);

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FeedbackCubit>().loadPendingAssignments();
    return _FeedbackView(
      onReload: () => context.read<FeedbackCubit>().loadPendingAssignments(),
    );
  }
}

class _FeedbackView extends StatelessWidget {
  final VoidCallback onReload;
  const _FeedbackView({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Evaluaciones',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<FeedbackCubit, FeedbackState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: _kOrange,
            onRefresh: () =>
                context.read<FeedbackCubit>().loadPendingAssignments(),
            child: CustomScrollView(
              slivers: [
                if (state is FeedbackLoading)
                  const SliverFillRemaining(child: _LoadingView())
                else if (state is FeedbackError)
                  SliverFillRemaining(
                    child: _ErrorView(
                      message: state.message,
                      onRetry: (ctx) =>
                          ctx.read<FeedbackCubit>().loadPendingAssignments(),
                    ),
                  )
                else if (state is FeedbackLoaded) ...[
                  SliverToBoxAdapter(
                    child: _SummaryStrip(assignments: state.assignments),
                  ),
                  if (state.assignments.isEmpty)
                    const SliverFillRemaining(child: _EmptyView())
                  else
                    _AssignmentList(
                      assignments: state.assignments,
                      onReload: onReload,
                    ),
                ] else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _SummaryStrip extends StatelessWidget {
  final List<FeedbackAssignmentModel> assignments;
  const _SummaryStrip({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final activeCount = assignments.where((a) => !a.isExpired).length;
    final expiredCount = assignments.where((a) => a.isExpired).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          _CountChip(
            icon: Icons.pending_actions_rounded,
            label: 'Por contestar',
            count: activeCount,
            color: _kOrange,
          ),
          const SizedBox(width: 12),
          _CountChip(
            icon: Icons.lock_clock_outlined,
            label: 'Expiradas',
            count: expiredCount,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _CountChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _AssignmentList extends StatelessWidget {
  final List<FeedbackAssignmentModel> assignments;
  final VoidCallback onReload;
  const _AssignmentList({required this.assignments, required this.onReload});

  List<FeedbackAssignmentModel> _sorted(List<FeedbackAssignmentModel> list) {
    final copy = [...list];
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final active = _sorted(assignments.where((a) => !a.isExpired).toList());
    final expired = _sorted(assignments.where((a) => a.isExpired).toList());

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 32),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (active.isNotEmpty) ...[
            _SectionHeader(
              label: 'Por contestar',
              count: active.length,
              color: _kOrange,
              icon: Icons.pending_actions_rounded,
            ),
            ...active.map((a) => FeedbackAssignmentCard(
                  assignment: a,
                  onReload: onReload,
                )),
          ],
          if (expired.isNotEmpty) ...[
            _SectionHeader(
              label: 'Expiradas',
              count: expired.length,
              color: Colors.grey.shade500,
              icon: Icons.lock_clock_outlined,
            ),
            ...expired.map((a) => FeedbackAssignmentCard(
                  assignment: a,
                  onReload: onReload,
                )),
          ],
        ]),
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: color.withOpacity(0.2), thickness: 1),
          ),
        ],
      ),
    );
  }
}


class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _kOrange),
          const SizedBox(height: 16),
          Text(
            'Cargando evaluaciones...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kOrange.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: _kOrange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Todo al día!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'No tienes evaluaciones pendientes\npor el momento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final void Function(BuildContext) onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Algo salió mal',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => onRetry(context),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: _kOrange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}