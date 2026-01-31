import 'package:dysch_mobile/data/models/schedule_model.dart';
import 'package:dysch_mobile/data/repositories/schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Estados
abstract class ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;
  ScheduleLoaded(this.schedules);
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}

// Cubit (Lógica)
class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;

  ScheduleCubit(this.repository) : super(ScheduleLoading());

  void loadSchedules() async {
    try {
      emit(ScheduleLoading());
      final data = await repository.getSchedules();
      emit(ScheduleLoaded(data));
    } catch (e) {
      emit(ScheduleError("No se pudieron cargar los horarios"));
    }
  }
}
