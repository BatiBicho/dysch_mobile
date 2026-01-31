class ScheduleModel {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String position; // Ej: "Cajero", "Seguridad"
  final bool isConfirmed;

  ScheduleModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.position,
    this.isConfirmed = false,
  });
}
