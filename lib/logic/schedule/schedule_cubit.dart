import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/repositories/schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Estados ──────────────────────────────────────────────────────────────────

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleSuccess extends ScheduleState {
  final ScheduleModel? schedule;
  ScheduleSuccess(this.schedule);

  /// Alias de compatibilidad — attendance_card.dart usa `state.schedules`.
  ScheduleModel? get schedules => schedule;
}

/// Estado que contiene tanto la semana actual como la siguiente.
class WeekScheduleSuccess extends ScheduleState {
  final WeekScheduleModel currentWeek;
  final WeekScheduleModel nextWeek;

  WeekScheduleSuccess({
    required this.currentWeek,
    required this.nextWeek,
  });
}

class WeekScheduleEmpty extends ScheduleState {}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;

  ScheduleCubit(this.repository) : super(ScheduleInitial());

  Future<void> getSchedule(String shiftDate, {String? employeeId}) async {
    if (state is ScheduleLoading) return;
    try {
      emit(ScheduleLoading());
      final data = await repository.getSchedule(shiftDate, employeeId: employeeId);
      emit(ScheduleSuccess(data));
    } catch (e) {
      emit(ScheduleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Carga en paralelo la semana actual y la siguiente para el empleado dado.
  Future<void> getWeekSchedule({required String employeeId}) async {
    if (state is ScheduleLoading) return;
    try {
      emit(ScheduleLoading());

      final results = await Future.wait([
        repository.getWeekSchedule(employeeId: employeeId),
        repository.getNextWeekSchedule(employeeId: employeeId),
      ]);

      final current = results[0];
      final next = results[1];

      if (current.schedules.isEmpty && next.schedules.isEmpty) {
        emit(WeekScheduleEmpty());
      } else {
        emit(WeekScheduleSuccess(currentWeek: current, nextWeek: next));
      }
    } catch (e) {
      emit(ScheduleError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}