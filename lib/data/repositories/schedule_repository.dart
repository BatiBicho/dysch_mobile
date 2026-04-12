import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(this._dio);

  Future<ScheduleModel?> getSchedule(String shiftDate, {String? employeeId}) async {
    try {
      final response = await _dio.get(
        '/schedules/schedules/',
        queryParameters: {
          'shift_date': shiftDate,
          if (employeeId != null) 'employee_id': employeeId,
        },
      );

      final results = response.data as List?;
      if (results == null || results.isEmpty) return null;
      return ScheduleModel.fromJson(results.first as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener el horario';
      throw Exception(errorMessage);
    }
  }

  /// Obtiene los horarios de la semana actual filtrando por empleado.
  Future<WeekScheduleModel> getWeekSchedule({required String employeeId}) async {
    try {
      final response = await _dio.get(
        '/schedules/schedules/',
        queryParameters: {
          'employee_id': employeeId,
          'shift_date_after': _mondayOf(DateTime.now()),
          'shift_date_before': _sundayOf(DateTime.now()),
        },
      );

      return WeekScheduleModel.fromJson(response.data as List);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ??
          'Error al obtener el horario de la semana';
      throw Exception(errorMessage);
    }
  }

  /// Obtiene los horarios de la siguiente semana filtrando por empleado.
  Future<WeekScheduleModel> getNextWeekSchedule({required String employeeId}) async {
    try {
      final nextWeek = DateTime.now().add(const Duration(days: 7));
      final response = await _dio.get(
        '/schedules/schedules/',
        queryParameters: {
          'employee_id': employeeId,
          'shift_date_after': _mondayOf(nextWeek),
          'shift_date_before': _sundayOf(nextWeek),
        },
      );

      return WeekScheduleModel.fromJson(response.data as List);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ??
          'Error al obtener el horario de la siguiente semana';
      throw Exception(errorMessage);
    }
  }

  // ─── Date helpers ─────────────────────────────────────────────────────────

  String _mondayOf(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return _toDateString(monday);
  }

  String _sundayOf(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return _toDateString(sunday);
  }

  String _toDateString(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}