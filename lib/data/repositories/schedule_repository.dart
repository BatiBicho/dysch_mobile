import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(this._dio);

  Future<ScheduleModel?> getSchedule(String shiftDate) async {
    try {
      final response = await _dio.get(
        '/schedules/schedules/',
        queryParameters: {'shift_date': shiftDate},
      );

      // La respuesta es un objeto paginado con estructura: {count, next, previous, results}
      final results = response.data['results'] as List?;

      if (results == null || results.isEmpty) {
        return null; // Sin schedule para este día
      }

      return ScheduleModel.fromJson(results.first as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener el horario';
      throw Exception(errorMessage);
    }
  }

  Future<WeekScheduleModel> getWeekSchedule() async {
    try {
      final response = await _dio.get('/schedules/schedules/current-week/');

      return WeekScheduleModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ??
          'Error al obtener el horario de la semana';
      throw Exception(errorMessage);
    }
  }
}
