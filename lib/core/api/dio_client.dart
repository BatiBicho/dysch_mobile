import 'package:dio/dio.dart';
import '../../core/services/storage_service.dart';

class DioClient {
  final Dio _dio;
  final StorageService _storage = StorageService();

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.tu-dominio.com/api/v1', // Tu URL base
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        ),
      ) {
    // Agregamos Interceptores (El "filtro" de seguridad)
    // _dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) async {
    //       // 1. Buscamos el token en SharedPreferences
    //       final token = await _storage.getToken();

    //       // 2. Si existe, lo inyectamos automáticamente en el Header
    //       if (token != null) {
    //         options.headers['Authorization'] = 'Bearer $token';
    //       }

    //       print("HACIENDO PETICIÓN A: ${options.path}");
    //       return handler.next(options);
    //     },
    //     onError: (DioException e, handler) {
    //       print("ERROR DE API: ${e.message}");
    //       return handler.next(e);
    //     },
    //   ),
    // );
  }

  // Getter para usar la instancia
  Dio get instance => _dio;
}
