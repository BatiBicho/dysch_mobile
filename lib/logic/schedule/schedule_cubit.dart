import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/repositories/schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Estados
abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleSuccess extends ScheduleState {
  final ScheduleModel? schedules; // Ahora puede ser null si no hay schedule
  ScheduleSuccess(this.schedules);
}

class WeekScheduleSuccess extends ScheduleState {
  final WeekScheduleModel schedules;
  WeekScheduleSuccess(this.schedules);
}

class WeekScheduleEmpty extends ScheduleState {}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}

// Cubit (Lógica)
class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;

  ScheduleCubit(this.repository) : super(ScheduleInitial());

  void getSchedule(String shiftDate) async {
    if (state is ScheduleLoading) return;

    try {
      emit(ScheduleLoading());
      final data = await repository.getSchedule(shiftDate);
      emit(ScheduleSuccess(data));
    } catch (e) {
      emit(ScheduleError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  void getWeekSchedule() async {
    if (state is ScheduleLoading) return;

    try {
      emit(ScheduleLoading());
      final data = await repository.getWeekSchedule();
      if (data.schedules.isEmpty) {
        emit(WeekScheduleEmpty());
      } else {
        emit(WeekScheduleSuccess(data));
      }
    } catch (e) {
      emit(ScheduleError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
