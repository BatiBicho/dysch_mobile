import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/payroll_period_model.dart';
import 'package:dysch_mobile/data/models/prenomina_model.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class PrenominaRepository {
  final Dio _dio;
  final logger = Logger();

  PrenominaRepository(this._dio);

  /// Obtener la prenómina para un período específico
  Future<PrenominaResponse> getPrenomina({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final String startStr = _formatDate(periodStart);
      final String endStr = _formatDate(periodEnd);

      final response = await _dio.get(
        '/payroll/prenomina/my-prenomina/detail/',
        queryParameters: {'period_start': startStr, 'period_end': endStr},
      );

      logger.d('✅ Prenómina obtenida: ${response.statusCode}');
      return PrenominaResponse.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ Error obteniendo prenómina: ${e.message}');
      if (e.response?.statusCode == 404) {
        return PrenominaResponse(
          detail:
              'Prenómina no encontrada o aún no confirmada para este período.',
        );
      }
      return PrenominaResponse(detail: 'Error al obtener la prenómina');
    } catch (e) {
      logger.e('🚨 Error inesperado: $e');
      return PrenominaResponse(detail: 'Error al obtener la prenómina');
    }
  }

  /// Obtener los períodos disponibles de prenómina
  Future<PayrollPeriodResponse?> getAvailablePeriods() async {
    try {
      final response = await _dio.get(
        '/payroll/prenomina/my-prenomina/history',
      );

      logger.d('✅ Períodos obtenidos: ${response.statusCode}');
      return PayrollPeriodResponse.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ Error obteniendo períodos: ${e.message}');
      return null;
    } catch (e) {
      logger.e('🚨 Error inesperado: $e');
      return null;
    }
  }

  /// Descargar PDF de la prenómina
  Future<String?> downloadPrenominaPdf({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final String startStr = _formatDate(periodStart);
      final String endStr = _formatDate(periodEnd);

      final dir = await getApplicationDocumentsDirectory();
      final String fileName = 'prenomina_${startStr}_$endStr.pdf';
      final String savePath = "${dir.path}/$fileName";

      File file = File(savePath);

      // Descargar el PDF
      await _dio.download(
        '/payroll/prenomina/my-prenomina/pdf/',
        savePath,
        queryParameters: {'period_start': startStr, 'period_end': endStr},
        onReceiveProgress: (received, total) {
          if (total != -1) {
            logger.d(
              'Progreso descarga: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      if (await file.exists()) {
        logger.d('✅ PDF descargado: $savePath');
        return savePath;
      }

      return null;
    } on DioException catch (e) {
      logger.e('❌ Error descargando PDF: ${e.message}');
      if (e.response?.statusCode == 404) {
        return null;
      }
      return null;
    } catch (e) {
      logger.e('🚨 Error descargando PDF: $e');
      return null;
    }
  }

  /// Abrir el archivo PDF descargado
  Future<void> openPrenominaPdf(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe');
      }

      // Usar intent de Android para abrir PDF
      if (Platform.isAndroid) {
        // ignore: prefer_adjacent_string_concatenation
        await _dio.get('file://$filePath');
      } else if (Platform.isIOS) {
        // En iOS se podría usar un servicio específico
        logger.d('Abriendo PDF en iOS: $filePath');
      }
    } catch (e) {
      logger.e('Error abriendo PDF: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
  }

  String _pad(int value) {
    return value.toString().padLeft(2, '0');
  }
}
