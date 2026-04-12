import 'package:dio/dio.dart';
import 'package:dysch_mobile/core/api/dio_client.dart';
import 'package:dysch_mobile/data/models/attendance_model.dart';
import 'package:dysch_mobile/data/models/weekly_summary_model.dart';

class AttendanceException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  AttendanceException(this.message, [this.errors = const {}]);
}

class AttendanceRepository {
  final Dio _dio;

  AttendanceRepository([Dio? dio]) : _dio = dio ?? DioClient.instance;

  Future<AttendanceResponseModel> checkIn({
    required String qrCode,
    required double latitude,
    required double longitude,
    required DateTime clientTimestamp,
  }) async {
    try {
      final response = await _dio.post(
        '/attendance/check-in/',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 'QR',
          'qr_code': qrCode,
          //'client_timestamp': clientTimestamp.toUtc().toIso8601String(),
        },
      );
      return AttendanceResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw AttendanceException(_extractMessage(e), _parseErrors(e));
    }
  }

  Future<AttendanceResponseModel> checkOut({
    required String qrCode,
    required double latitude,
    required double longitude,
    required DateTime clientTimestamp,
  }) async {
    try {
      final response = await _dio.post(
        '/attendance/check-out/',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 'QR',
          'qr_code': qrCode,
          //'client_timestamp': clientTimestamp.toUtc().toIso8601String(),
        },
      );
      return AttendanceResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw AttendanceException(_extractMessage(e), _parseErrors(e));
    }
  }

  String _extractMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['non_field_errors'] is List<dynamic>) {
        return (data['non_field_errors'] as List<dynamic>)
            .map((item) => item.toString())
            .join(' ');
      }
      final errors = _parseErrors(exception);
      if (errors.isNotEmpty) {
        return errors.values.expand((list) => list).join(' | ').trim();
      }
    }
    return exception.message ?? 'Error de conexión con el servidor.';
  }

  Map<String, List<String>> _parseErrors(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final map = <String, List<String>>{};
      data.forEach((key, value) {
        if (value is List) {
          map[key] = value.map((item) => item.toString()).toList();
        } else if (value != null) {
          map[key] = [value.toString()];
        }
      });
      return map;
    }
    return {};
  }

  Future<WeeklySummaryModel> getWeeklySummary() async {
    try {
      final response = await _dio.get('/attendance/records/weekly-summary/');
      return WeeklySummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AttendanceException(_extractMessage(e), _parseErrors(e));
    }
  }
}
