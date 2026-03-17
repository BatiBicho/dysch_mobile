import 'package:dysch_mobile/data/models/feedback_model.dart';
import 'package:dysch_mobile/data/repositories/feedback_repository.dart';
import 'package:dysch_mobile/logic/feedback/feedback_cubit.dart';
import 'package:dysch_mobile/logic/feedback/take_feedback_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const _kOrange = Color(0xFFFF6B35);


class TakeFeedbackScreen extends StatelessWidget {
  final String campaignId;
  final String campaignName;
  final String topicId;
  final String topicTitle;
  final bool resultsVisibleToEmployees;
  final bool isAnonymous;
  final String employeeCode;

  const TakeFeedbackScreen({
    super.key,
    required this.campaignId,
    required this.campaignName,
    required this.topicId,
    required this.topicTitle,
    required this.resultsVisibleToEmployees,
    required this.isAnonymous,
    required this.employeeCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TakeFeedbackCubit(
        repo: context.read<FeedbackRepository>(),
        campaignId: campaignId,
        topicId: topicId,
        resultsVisibleToEmployees: resultsVisibleToEmployees,
        isAnonymous: isAnonymous,
        employeeCode: employeeCode,
      )..loadQuestions(),
      child: _TakeFeedbackView(
        campaignName: campaignName,
        topicTitle: topicTitle,
      ),
    );
  }
}


// Vista principal:
class _TakeFeedbackView extends StatelessWidget {
  final String campaignName;
  final String topicTitle;

  const _TakeFeedbackView({
    required this.campaignName,
    required this.topicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TakeFeedbackCubit, TakeFeedbackState>(
      listener: (context, state) {
        if (state is TakeFeedbackSubmitted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _SuccessDialog(
              campaignId: state.campaignId,
              canViewResults: state.resultsVisibleToEmployees && !state.isAnonymous,
              onViewResults: () {
                Navigator.of(context).pop();
                context.push('/feedback-results', extra: {
                  'campaignId': state.campaignId,
                  'employeeCode': state.employeeCode,
                });
              },
              onDone: () {
                // Recargar la lista global ANTES de navegar.
                context.read<FeedbackCubit>().loadPendingAssignments();
                Navigator.of(context).pop();
                context.pop();
              },
            ),
          );
        } else if (state is TakeFeedbackError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: SafeArea(
            child: switch (state) {
              TakeFeedbackLoading() => const _LoadingView(),
              TakeFeedbackReady() => _QuestionFlow(
                  state: state,
                  topicTitle: topicTitle,
                ),
              TakeFeedbackError() => _ErrorView(
                  message: (state as TakeFeedbackError).message,
                  onRetry: () =>
                      context.read<TakeFeedbackCubit>().loadQuestions(),
                ),
              TakeFeedbackSubmitted() => _SubmittedView(
                  onBack: () {
                    context.read<FeedbackCubit>().loadPendingAssignments();
                    context.pop();
                  },
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}


// Flujo de preguntas:
class _QuestionFlow extends StatelessWidget {
  final TakeFeedbackReady state;
  final String topicTitle;

  const _QuestionFlow({required this.state, required this.topicTitle});

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    final total = state.questions.length;
    final current = state.currentIndex + 1;
    final progress = current / total;

    return Column(
      children: [
        _Header(
          topicTitle: topicTitle,
          current: current,
          total: total,
          progress: progress,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'PREGUNTA $current DE $total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black26,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  q.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),

                if (q.isMandatory) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '* Obligatoria',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(q.id),
                    child: switch (q.responseType) {
                      ResponseType.stars => _StarsInput(
                          value: state.currentAnswer as int?,
                          onChanged: (v) =>
                              context.read<TakeFeedbackCubit>().answer(v),
                        ),
                      ResponseType.yesNo => _YesNoInput(
                          value: state.currentAnswer as bool?,
                          onChanged: (v) =>
                              context.read<TakeFeedbackCubit>().answer(v),
                        ),
                      ResponseType.text => _TextInput(
                          value: state.currentAnswer as String?,
                          onChanged: (v) =>
                              context.read<TakeFeedbackCubit>().answer(v),
                        ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        _Footer(state: state),
      ],
    );
  }
}


class _Header extends StatelessWidget {
  final String topicTitle;
  final int current;
  final int total;
  final double progress;

  const _Header({
    required this.topicTitle,
    required this.current,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_outlined,
                    size: 16, color: _kOrange),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topicTitle,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$current/$total',
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _confirmExit(context),
                child: const Icon(Icons.close_rounded,
                    color: Colors.black45, size: 22),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (_, value, __) => LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(_kOrange),
            minHeight: 3,
          ),
        ),
      ],
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Salir?',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
        content: const Text(
          'Si sales ahora perderás tus respuestas.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.black45)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Salir',
                style: TextStyle(
                    color: _kOrange, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}


// Footer:
class _Footer extends StatelessWidget {
  final TakeFeedbackReady state;
  const _Footer({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TakeFeedbackCubit>();
    final canProceed = !state.currentQuestion.isMandatory || state.currentAnswered;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          if (!state.isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: cubit.previous,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Atrás',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),

          if (!state.isFirst) const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: canProceed
                  ? () {
                      if (state.isLast) {
                        cubit.submit();
                      } else {
                        cubit.next();
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: _kOrange,
                disabledBackgroundColor: _kOrange.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      state.isLast ? 'Finalizar' : 'Siguiente',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}


// Inputs de respuesta:
class _StarsInput extends StatelessWidget {
  final int? value;
  final void Function(int) onChanged;

  const _StarsInput({required this.value, required this.onChanged});

  static const _labels = ['', 'Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            final filled = value != null && star <= value!;
            return GestureDetector(
              onTap: () => onChanged(star),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 48,
                  color: filled ? const Color(0xFFFFC107) : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            value != null ? _labels[value!] : '',
            key: ValueKey(value),
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _YesNoInput extends StatelessWidget {
  final bool? value;
  final void Function(bool) onChanged;

  const _YesNoInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _YesNoCard(
          label: 'Sí',
          icon: Icons.check_circle_outline_rounded,
          selected: value == true,
          selectedColor: Colors.green,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 16),
        _YesNoCard(
          label: 'No',
          icon: Icons.cancel_outlined,
          selected: value == false,
          selectedColor: Colors.red,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _YesNoCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _YesNoCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withOpacity(0.12)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? selectedColor : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: selected ? selectedColor : Colors.grey.shade400,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: selected ? selectedColor : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextInput extends StatefulWidget {
  final String? value;
  final void Function(String) onChanged;

  const _TextInput({required this.value, required this.onChanged});

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            maxLines: 5,
            minLines: 5,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Escribe tu respuesta aquí...',
              hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 12, top: 14),
                child: Icon(Icons.edit_note_rounded,
                    color: Colors.black26, size: 20),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder(
          valueListenable: _ctrl,
          builder: (_, val, __) => Text(
            '${val.text.length} caracteres',
            style: const TextStyle(fontSize: 11, color: Colors.black26),
          ),
        ),
      ],
    );
  }
}


class _SuccessDialog extends StatelessWidget {
  final String campaignId;
  final bool canViewResults;
  final VoidCallback onViewResults;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.campaignId,
    required this.canViewResults,
    required this.onViewResults,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              '¡Evaluación enviada!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Gracias por completar la evaluación. Tus respuestas han sido registradas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            if (canViewResults) ...[
              OutlinedButton.icon(
                onPressed: onViewResults,
                icon: const Icon(Icons.bar_chart_rounded, size: 18),
                label: const Text('Ver respuestas',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kOrange,
                  side: const BorderSide(color: _kOrange),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
            ],
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: _kOrange,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Volver a evaluaciones',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}


class _SubmittedView extends StatelessWidget {
  final VoidCallback onBack;
  const _SubmittedView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Evaluación completada!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus respuestas ya fueron registradas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade500, height: 1.5),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver a evaluaciones',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: _kOrange,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: _kOrange),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black45)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(backgroundColor: _kOrange),
            ),
          ],
        ),
      ),
    );
  }
}