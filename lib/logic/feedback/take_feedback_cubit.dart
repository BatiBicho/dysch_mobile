import 'package:dysch_mobile/data/models/feedback_model.dart';
import 'package:dysch_mobile/data/repositories/feedback_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class TakeFeedbackState {}

class TakeFeedbackLoading extends TakeFeedbackState {}

class TakeFeedbackReady extends TakeFeedbackState {
  final List<FeedbackQuestionModel> questions;
  final int currentIndex;
  final Map<String, dynamic> answers; // questionId → int | bool | String
  final bool isSubmitting;

  TakeFeedbackReady({
    required this.questions,
    required this.currentIndex,
    this.answers = const {},
    this.isSubmitting = false,
  });

  FeedbackQuestionModel get currentQuestion => questions[currentIndex];
  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == questions.length - 1;
  dynamic get currentAnswer => answers[currentQuestion.id];
  bool get currentAnswered => currentAnswer != null;

  TakeFeedbackReady copyWith({
    int? currentIndex,
    Map<String, dynamic>? answers,
    bool? isSubmitting,
  }) {
    return TakeFeedbackReady(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class TakeFeedbackSubmitted extends TakeFeedbackState {
  final String campaignId;
  final bool resultsVisibleToEmployees;
  final bool isAnonymous;
  final String employeeCode;
  TakeFeedbackSubmitted({
    required this.campaignId,
    required this.resultsVisibleToEmployees,
    required this.isAnonymous,
    required this.employeeCode,
  });
}

class TakeFeedbackError extends TakeFeedbackState {
  final String message;
  TakeFeedbackError(this.message);
}


class TakeFeedbackCubit extends Cubit<TakeFeedbackState> {
  final FeedbackRepository _repo;
  final String campaignId;
  final String topicId;
  final bool resultsVisibleToEmployees;
  final bool isAnonymous;
  final String employeeCode;

  TakeFeedbackCubit({
    required FeedbackRepository repo,
    required this.campaignId,
    required this.topicId,
    required this.resultsVisibleToEmployees,
    required this.isAnonymous,
    required this.employeeCode,
  })  : _repo = repo,
        super(TakeFeedbackLoading());

  Future<void> loadQuestions() async {
    emit(TakeFeedbackLoading());
    try {
      final questions = await _repo.getQuestions(topicId);
      emit(TakeFeedbackReady(questions: questions, currentIndex: 0));
    } catch (e) {
      emit(TakeFeedbackError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void answer(dynamic value) {
    final s = state;
    if (s is! TakeFeedbackReady) return;
    final updated = Map<String, dynamic>.from(s.answers);
    updated[s.currentQuestion.id] = value;
    emit(s.copyWith(answers: updated));
  }

  void next() {
    final s = state;
    if (s is! TakeFeedbackReady || s.isLast) return;
    emit(s.copyWith(currentIndex: s.currentIndex + 1));
  }

  void previous() {
    final s = state;
    if (s is! TakeFeedbackReady || s.isFirst) return;
    emit(s.copyWith(currentIndex: s.currentIndex - 1));
  }

  Future<void> submit() async {
    final s = state;
    if (s is! TakeFeedbackReady) return;

    emit(s.copyWith(isSubmitting: true));

    try {
      final responses = s.questions.map((q) {
        final ans = s.answers[q.id];
        switch (q.responseType) {
          case ResponseType.stars:
            return FeedbackResponseModel.stars(q.id, ans as int);
          case ResponseType.yesNo:
            return FeedbackResponseModel.yesNo(q.id, ans as bool);
          case ResponseType.text:
            return FeedbackResponseModel.text(q.id, ans as String? ?? '');
        }
      }).toList();

      await _repo.submitFeedback(
        campaignId: campaignId,
        responses: responses,
      );

      emit(TakeFeedbackSubmitted(
        campaignId: campaignId,
        resultsVisibleToEmployees: resultsVisibleToEmployees,
        isAnonymous: isAnonymous,
        employeeCode: employeeCode,
      ));
    } catch (e) {
      final s2 = state;
      if (s2 is TakeFeedbackReady) emit(s2.copyWith(isSubmitting: false));
      emit(TakeFeedbackError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}