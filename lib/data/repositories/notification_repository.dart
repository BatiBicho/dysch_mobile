import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<void> registerToken({
    required String token,
    required String platform,
    required String deviceName,
  }) async {
    await _dio.post(
      '/notifications/device-tokens/register_token/',
      data: {
        'token': token,
        'platform': platform, // 'ANDROID' o 'IOS'
        'device_name': deviceName,
      },
    );
  }

  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String body,
    String notificationType = 'SCHEDULE_PUBLISHED',
    String data = '',
  }) async {
    final response = await _dio.post(
      '/notifications/notifications/send_notification/',
      data: {
        'title': title,
        'body': body,
        'notification_type': notificationType,
        'data': data,
      },
    );
    return response.data;
  }

  Future<List<NotificationModel>> getListNotifications() async {
    try {
      final response = await _dio.get('/notifications/notifications/');
      final rawList = response.data['results'] as List<dynamic>?;
      if (rawList == null) return [];
      return rawList
          .map(
            (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['detail'] ?? 'Error al obtener notificaciones';
      throw Exception(message);
    }
  }

  Future<NotificationModel> markOneNotification({
    required String idNotification,
  }) async {
    try {
      final response = await _dio.patch(
        '/notifications/notifications/$idNotification/mark_as_read/',
      );
      return NotificationModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message =
          e.response?.data['detail'] ?? 'Error al marcar notificación';
      throw Exception(message);
    }
  }

  Future<String> markAllNotifications() async {
    try {
      final response = await _dio.post(
        '/notifications/notifications/mark_all_as_read/',
      );
      final body = response.data as Map<String, dynamic>;
      return body['message']?.toString() ??
          'Notificaciones marcadas como leÃ­das';
    } on DioException catch (e) {
      final message =
          e.response?.data['detail'] ??
          'Error al marcar todas las notificaciones';
      throw Exception(message);
    }
  }
}
