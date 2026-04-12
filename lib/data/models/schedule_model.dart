class ScheduleModel {
  final String id;
  final String startTime;
  final String endTime;
  final String periodStatus;
  final String shiftDate;
  final bool isPublished;
  final bool isCompleted;
  final String? employeeName;
  final String? companyName;

  ScheduleModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.periodStatus,
    required this.shiftDate,
    required this.isPublished,
    this.isCompleted = false,
    this.employeeName,
    this.companyName,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      shiftDate: json['shift_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      periodStatus: json['period_status'] ?? '',
      isPublished: json['is_published'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      employeeName: json['employee_name'],
      companyName: json['company_name'],
    );
  }
}

class WeekScheduleModel {
  final List<ScheduleModel> schedules;

  WeekScheduleModel(this.schedules);

  factory WeekScheduleModel.fromJson(List<dynamic> json) {
    final schedules = json
        .map((item) => ScheduleModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return WeekScheduleModel(schedules);
  }
}
