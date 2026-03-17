import 'package:dysch_mobile/data/models/feedback_model.dart';
import 'package:dysch_mobile/data/repositories/feedback_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _kOrange = Color(0xFFFF6B35);


abstract class _ResultsState {}
class _ResultsLoading extends _ResultsState {}
class _ResultsLoaded extends _ResultsState {
  final CampaignResultsModel data;
  _ResultsLoaded(this.data);
}
class _ResultsError extends _ResultsState {
  final String message;
  _ResultsError(this.message);
}

class _ResultsCubit extends Cubit<_ResultsState> {
  final FeedbackRepository _repo;
  final String campaignId;

  _ResultsCubit(this._repo, this.campaignId) : super(_ResultsLoading());

  Future<void> load() async {
    emit(_ResultsLoading());
    try {
      final data = await _repo.getEmployeeResponses(campaignId);
      emit(_ResultsLoaded(data));
    } on Exception catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      // ignore: avoid_print
      print('[FeedbackResults] Error cargando respuestas ($campaignId): $msg');
      emit(_ResultsError(msg));
    }
  }
}


class FeedbackResultsScreen extends StatelessWidget {
  final String campaignId;
  final String employeeCode;
  const FeedbackResultsScreen({
    super.key,
    required this.campaignId,
    required this.employeeCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          _ResultsCubit(context.read<FeedbackRepository>(), campaignId)..load(),
      child: _ResultsView(employeeCode: employeeCode),
    );
  }
}


class _ResultsView extends StatelessWidget {
  final String employeeCode;
  const _ResultsView({required this.employeeCode});

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
          'Mis respuestas',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<_ResultsCubit, _ResultsState>(
        builder: (context, state) {
          if (state is _ResultsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _kOrange),
            );
          }
          if (state is _ResultsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<_ResultsCubit>().load(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                      style: FilledButton.styleFrom(
                          backgroundColor: _kOrange),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = (state as _ResultsLoaded).data;
          final employee = data.employees.firstWhere(
            (e) => e.employeeCode == employeeCode,
            orElse: () => data.employees.isNotEmpty
                ? data.employees.first
                : EmployeeResultModel(
                    employeeCode: '',
                    employeeName: '',
                    completedAt: DateTime.now(),
                    responses: [],
                  ),
          );

          if (employee.responses.isEmpty) {
            return Center(
              child: Text('No se encontraron respuestas.',
                  style: TextStyle(color: Colors.grey.shade500)),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _CampaignHeader(data: data, employee: employee),
              const SizedBox(height: 20),
              ...employee.responses.asMap().entries.map((entry) {
                final index = entry.key;
                final response = entry.value;
                return _ResponseCard(
                  index: index + 1,
                  total: employee.responses.length,
                  response: response,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}


class _CampaignHeader extends StatelessWidget {
  final CampaignResultsModel data;
  final EmployeeResultModel employee;

  const _CampaignHeader({required this.data, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOrange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 20, color: _kOrange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.campaignName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _MetaRow(
            icon: Icons.person_outline_rounded,
            label: employee.employeeName,
          ),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.check_circle_outline_rounded,
            label:
                'Completada el ${_fmtDate(employee.completedAt)}',
            color: Colors.green,
          ),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.quiz_outlined,
            label: '${employee.responses.length} respuestas',
          ),
          if (data.isAnonymous) ...[
            const SizedBox(height: 6),
            _MetaRow(
              icon: Icons.visibility_off_outlined,
              label: 'Evaluación anónima',
              color: Colors.grey.shade500,
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MetaRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade600;
    return Row(
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w500)),
      ],
    );
  }
}


class _ResponseCard extends StatelessWidget {
  final int index;
  final int total;
  final EmployeeResponseModel response;

  const _ResponseCard({
    required this.index,
    required this.total,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index / $total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kOrange,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  response.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          _ResponseValue(response: response),
        ],
      ),
    );
  }
}

class _ResponseValue extends StatelessWidget {
  final EmployeeResponseModel response;
  const _ResponseValue({required this.response});

  @override
  Widget build(BuildContext context) {
    switch (response.responseType) {
      case ResponseType.stars:
        final score = response.numericScore ?? 0;
        const labels = ['', 'Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (i) {
                final filled = i < score;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 30,
                  color: filled
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              score > 0 ? labels[score] : '',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case ResponseType.yesNo:
        final isYes = (response.numericScore ?? 0) == 1;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isYes
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isYes ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isYes
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 20,
                    color: isYes ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isYes ? 'Sí' : 'No',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isYes ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case ResponseType.text:
        final text = response.textComment ?? '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            text.isEmpty ? '(Sin respuesta)' : text,
            style: TextStyle(
              fontSize: 14,
              color: text.isEmpty
                  ? Colors.grey.shade400
                  : Colors.black87,
              height: 1.5,
              fontStyle:
                  text.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        );
    }
  }
}