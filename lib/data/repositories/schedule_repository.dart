import 'package:dysch_mobile/data/models/schedule_model.dart';

class ScheduleRepository {
  Future<List<ScheduleModel>> getSchedules() async {
    // Simulamos latencia de red
    await Future.delayed(const Duration(seconds: 2));

    // Datos de prueba (Hardcoded)
    return [
      ScheduleModel(
        id: '1',
        date: DateTime.now(),
        startTime: '08:00 AM',
        endTime: '04:00 PM',
        position: 'Supervisor de Turno',
        isConfirmed: true,
      ),
      ScheduleModel(
        id: '2',
        date: DateTime.now().add(const Duration(days: 1)),
        startTime: '09:00 AM',
        endTime: '05:00 PM',
        position: 'Supervisor de Turno',
      ),
    ];
  }
}
