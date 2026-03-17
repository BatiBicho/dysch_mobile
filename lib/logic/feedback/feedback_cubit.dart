import 'package:dysch_mobile/data/models/feedback_model.dart';
import 'package:dysch_mobile/data/repositories/feedback_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class FeedbackState {}

class FeedbackInitial extends FeedbackState {}
class FeedbackLoading extends FeedbackState {}

class FeedbackLoaded extends FeedbackState {
  final List<FeedbackAssignmentModel> assignments;
  FeedbackLoaded(this.assignments);
}

class FeedbackError extends FeedbackState {
  final String message;
  FeedbackError(this.message);
}



class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepository feedbackRepository;

  FeedbackCubit(this.feedbackRepository) : super(FeedbackInitial());

  Future<void> loadPendingAssignments() async {
    emit(FeedbackLoading());
    try {
      final assignments = await feedbackRepository.getPendingAssignments();

      final enriched = await Future.wait(
        assignments.map((assignment) async {
          try {
            final campaign = await feedbackRepository
                .getCampaignDetail(assignment.campaignId);
            return assignment.copyWith(campaign: campaign);
          } on Exception catch (e) {
            assert(() {
              print('[FeedbackCubit] Error cargando campaign '
                  '${assignment.campaignId}: $e');
              return true;
            }());
            return assignment;
          }
        }),
      );

      emit(FeedbackLoaded(enriched));
    } catch (e) {
      emit(FeedbackError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}