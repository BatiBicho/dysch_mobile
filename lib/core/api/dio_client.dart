import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= Dio(
      BaseOptions(
        baseUrl: dotenv.get(
          'API_BASE_URL',
          fallback: 'http://localhost:8000/api',
        ),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    if (_instance!.interceptors.isEmpty) {
      _instance!.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }

    return _instance!;
  }

  static void setAuthToken(String token) {
    _instance!.options.headers['Authorization'] = 'Bearer $token';
  }
}
