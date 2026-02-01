import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PayrollRepository {
  final Dio _dio = Dio();

  Future<String?> downloadPayroll(
    String periodId, {
    bool openAfterDownload = true,
  }) async {
    try {
      // 1. Obtener ruta
      final dir = await getApplicationDocumentsDirectory();
      final String savePath = "${dir.path}/nomina_$periodId.pdf";

      // 2. Verificar si ya existe
      File file = File(savePath);
      if (await file.exists()) {
        print("📄 Archivo ya existe en: $savePath");
        if (openAfterDownload) await OpenFile.open(savePath);
        return savePath;
      }

      // 3. Descargar (URL REAL aquí)
      await _dio.download(
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        savePath,
        onReceiveProgress: (received, total) {
          // Puedes usar un Stream o Callback para UI
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print("📥 Descargando: $progress%");
          }
        },
      );

      // 4. Verificar
      if (await file.exists()) {
        print("✅ Descarga completada: $savePath");
        print("📊 Tamaño: ${(await file.length()) ~/ 1024} KB");

        // 5. Abrir automáticamente si se solicita
        if (openAfterDownload) {
          await OpenFile.open(savePath);
        }

        return savePath;
      } else {
        print("❌ Error: Archivo no creado después de descarga");
        return null;
      }
    } catch (e) {
      print("🚨 Error descargando nómina: $e");
      return null;
    }
  }

  // Método adicional: Eliminar nómina descargada
  Future<bool> deletePayroll(String periodId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final String filePath = "${dir.path}/nomina_$periodId.pdf";
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print("🗑️ Nómina eliminada: $periodId");
        return true;
      }
      return false;
    } catch (e) {
      print("Error eliminando nómina: $e");
      return false;
    }
  }

  // Método adicional: Listar nóminas descargadas
  Future<List<String>> listDownloadedPayrolls() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final directory = Directory(dir.path);
      final files = await directory.list().toList();

      return files
          .where(
            (file) =>
                file.path.endsWith('.pdf') && file.path.contains('nomina_'),
          )
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print("Error listando nóminas: $e");
      return [];
    }
  }
}
