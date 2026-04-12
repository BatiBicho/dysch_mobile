import 'package:dysch_mobile/data/models/weekly_summary_model.dart';
import 'package:dysch_mobile/data/repositories/attendance_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Estados
abstract class WeeklySummaryState {}

class WeeklySummaryInitial extends WeeklySummaryState {}

class WeeklySummaryLoading extends WeeklySummaryState {}

class WeeklySummarySuccess extends WeeklySummaryState {
  final WeeklySummaryModel summary;
  WeeklySummarySuccess(this.summary);
}

class WeeklySummaryError extends WeeklySummaryState {
  final String message;
  WeeklySummaryError(this.message);
}

// Cubit (Lógica)
class WeeklySummaryCubit extends Cubit<WeeklySummaryState> {
  final AttendanceRepository repository;

  WeeklySummaryCubit(this.repository) : super(WeeklySummaryInitial());

  Future<void> getWeeklySummary() async {
    if (state is WeeklySummaryLoading) return;

    try {
      emit(WeeklySummaryLoading());
      final data = await repository.getWeeklySummary();
      emit(WeeklySummarySuccess(data));
    } catch (e) {
      emit(WeeklySummaryError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
