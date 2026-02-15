import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/repositories/schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Estados
abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleSuccess extends ScheduleState {
  final ScheduleModel schedules;
  ScheduleSuccess(this.schedules);
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}

// Cubit (Lógica)
class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;

  ScheduleCubit(this.repository) : super(ScheduleInitial());

  void getSchedule() async {
    if (state is ScheduleLoading) return;

    try {
      emit(ScheduleLoading());
      final data = await repository.getSchedule();
      emit(ScheduleSuccess(data));
    } catch (e) {
      emit(ScheduleError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
