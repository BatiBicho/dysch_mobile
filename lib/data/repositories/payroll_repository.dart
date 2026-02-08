import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dysch_mobile/core/api/dio_client.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PayrollRepository {
  final Dio _dio;
  final logger = Logger();

  PayrollRepository([Dio? dio]) : _dio = dio ?? DioClient.instance;

  Future<String?> downloadPayroll(String periodId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String savePath = "${dir.path}/nomina_$periodId.pdf";

      File file = File(savePath);
      if (await file.exists()) {
        logger.d("📄 Archivo ya existe en: $savePath");
        return savePath; // Solo retornamos la ruta, NO abrimos
      }

      // 3. Descargar
      await _dio.download(
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", // Tu URL real
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            logger.d("Progreso: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      // 4. Verificar que se descargó
      if (await file.exists()) {
        logger.d("✅ Descarga completada: $savePath");
        logger.d("📊 Tamaño: ${(await file.length()) ~/ 1024} KB");
        return savePath; // Solo retornamos la ruta
      }

      return null;
    } catch (e) {
      logger.d("🚨 Error descargando: $e");
      return null;
    }
  }

  // Método separado para abrir archivo
  Future<void> openPayrollFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final result = await OpenFile.open(filePath);
        logger.d("📂 Resultado al abrir: ${result.message}");
      } else {
        throw Exception('El archivo no existe');
      }
    } catch (e) {
      logger.d("❌ Error abriendo archivo: $e");
      rethrow;
    }
  }

  // Método para verificar si un archivo ya existe
  Future<bool> payrollExists(String periodId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String savePath = "${dir.path}/nomina_$periodId.pdf";
      final file = File(savePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
