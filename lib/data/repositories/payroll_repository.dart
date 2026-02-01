import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PayrollRepository {
  final Dio _dio = Dio();

  // ✅ Cambio clave: Quitamos el openAfterDownload
  Future<String?> downloadPayroll(String periodId) async {
    try {
      // 1. Obtener ruta de almacenamiento
      final dir = await getApplicationDocumentsDirectory();
      final String savePath = "${dir.path}/nomina_$periodId.pdf";

      // 2. Verificar si ya existe
      File file = File(savePath);
      if (await file.exists()) {
        print("📄 Archivo ya existe en: $savePath");
        return savePath; // Solo retornamos la ruta, NO abrimos
      }

      // 3. Descargar
      await _dio.download(
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", // Tu URL real
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("Progreso: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      // 4. Verificar que se descargó
      if (await file.exists()) {
        print("✅ Descarga completada: $savePath");
        print("📊 Tamaño: ${(await file.length()) ~/ 1024} KB");
        return savePath; // Solo retornamos la ruta
      }

      return null;
    } catch (e) {
      print("🚨 Error descargando: $e");
      return null;
    }
  }

  // Método separado para abrir archivo
  Future<void> openPayrollFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final result = await OpenFile.open(filePath);
        print("📂 Resultado al abrir: ${result.message}");
      } else {
        throw Exception('El archivo no existe');
      }
    } catch (e) {
      print("❌ Error abriendo archivo: $e");
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
