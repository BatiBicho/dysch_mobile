import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.tu-dominio.com/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  static Dio get instance {
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        responseBody: true,
      ));
    }
    return _dio;
  }

  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}