import 'package:dio/dio.dart';

class AbsenceRepository {
  final Dio _dio;

  AbsenceRepository(this._dio);

  Future<bool> sendAbsenceRequest({
    required String type,
    required String description,
    required List<String> filePaths,
  }) async {
    try {
      // 1. Preparamos el FormData (Igual que un formulario HTML)
      final formData = FormData.fromMap({
        'type': type,
        'reason': description,
        'date': DateTime.now().toIso8601String(),
        // Agregamos los archivos si existen
        'files': filePaths.isNotEmpty
            ? await Future.wait(
                filePaths.map((path) => MultipartFile.fromFile(path)),
              )
            : null,
      });

      // 2. Cuando tengas la API:
      // final response = await _dio.post('/absences', data: formData);
      // return response.statusCode == 200;

      await Future.delayed(const Duration(seconds: 2)); // Simulación
      return true;
    } catch (e) {
      return false;
    }
  }
}
