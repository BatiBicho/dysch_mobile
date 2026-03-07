import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(this._dio);

  Future<ScheduleModel> getSchedule() async {
    try {
      final response = await _dio.get('/schedules/schedules/');

      return ScheduleModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al iniciar sesión';
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
