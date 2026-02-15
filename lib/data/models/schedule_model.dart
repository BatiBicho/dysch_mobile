class ScheduleModel {
  final String id;
  final String startTime;
  final String endTime;
  final String periodStatus;
  final String shiftDate;
  final bool isPublished;

  ScheduleModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.periodStatus,
    required this.shiftDate,
    required this.isPublished,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List<dynamic>;

    if (resultsList.isEmpty) {
      throw Exception('No hay horarios disponibles');
    }

    final scheduleData = resultsList.first as Map<String, dynamic>;

    return ScheduleModel(
      id: scheduleData['id'] ?? '',
      shiftDate: scheduleData['shift_date'] ?? '',
      startTime: scheduleData['start_time'] ?? '',
      endTime: scheduleData['end_time'] ?? '',
      periodStatus: scheduleData['period_status'] ?? '',
      isPublished: scheduleData['is_published'] ?? false,
    );
  }
}
