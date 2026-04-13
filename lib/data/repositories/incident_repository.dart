import 'dart:io';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/incident_model.dart';
import 'package:dysch_mobile/data/models/evidence_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncidentRepository {
  final Dio _dio;
  final supabase = Supabase.instance.client;
  final logger = Logger();

  // Nombre del bucket en Supabase (cambiar según tu configuración)
  static const String _bucketName = 'dysch_bucket';

  IncidentRepository(this._dio);

  /// Sube un archivo a Supabase Storage y retorna la URL pública
  ///
  /// [incidentId] - ID del incidente para organizar los archivos
  /// [filePath] - Ruta local del archivo a subir
  /// [fileType] - Tipo de archivo (imagen, pdf, video, etc)
  ///
  /// Retorna: URL pública del archivo subido
  /// Lanza excepciones si hay error en la subida
  Future<String> uploadFileToSupabase({
    required String incidentId,
    required String filePath,
    required String fileType,
  }) async {
    try {
      // Validar que el archivo existe
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe en la ruta: $filePath');
      }

      // Generar nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          '${incidentId}_${timestamp}_${file.path.split('/').last}';
      final storagePath = 'incidents/$incidentId/$fileName';

      logger.i('Subiendo archivo: $storagePath');

      // Subir archivo a Supabase
      await supabase.storage.from(_bucketName).upload(storagePath, file);

      // Obtener URL pública
      final publicUrl = supabase.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      logger.i('Archivo subido exitosamente: $publicUrl');
      return publicUrl;
    } on FileStat catch (e) {
      final errorMsg = 'Error al acceder al archivo: ${e.toString()}';
      logger.e(errorMsg);
      throw Exception(errorMsg);
    } catch (e) {
      final errorMsg = 'Error subiendo archivo a Supabase: ${e.toString()}';
      logger.e(errorMsg);
      throw Exception(errorMsg);
    }
  }

  /// Sube múltiples archivos a Supabase Storage para un incidente
  ///
  /// [incidentId] - ID del incidente
  /// [filePaths] - Lista de rutas de archivos a subir
  /// [fileTypes] - Lista de tipos de archivo (debe coincidir con filePaths)
  ///
  /// Retorna: Lista de URLs públicas de los archivos subidos
  /// Si un archivo falla, se detiene el proceso y lanza excepción
  Future<List<String>> uploadMultipleFilesToSupabase({
    required String incidentId,
    required List<String> filePaths,
    required List<String> fileTypes,
  }) async {
    if (filePaths.isEmpty) {
      throw Exception('La lista de archivos no puede estar vacía');
    }

    if (filePaths.length != fileTypes.length) {
      throw Exception('La cantidad de archivos y tipos debe ser igual');
    }

    final uploadedUrls = <String>[];

    try {
      for (int i = 0; i < filePaths.length; i++) {
        try {
          final url = await uploadFileToSupabase(
            incidentId: incidentId,
            filePath: filePaths[i],
            fileType: fileTypes[i],
          );
          uploadedUrls.add(url);
        } catch (e) {
          logger.e('Error subiendo archivo ${i + 1}: ${e.toString()}');
          throw Exception(
            'Error al subir archivo ${i + 1} de ${filePaths.length}: ${e.toString()}',
          );
        }
      }
      logger.i('Todos los archivos se subieron exitosamente');
      return uploadedUrls;
    } catch (e) {
      logger.e('Error en carga múltiple: ${e.toString()}');
      rethrow;
    }
  }

  /// Elimina un archivo del bucket de Supabase
  ///
  /// [storagePath] - Ruta del archivo en Supabase (ej: incidents/123/file.jpg)
  ///
  /// Lanza excepciones si hay error en la eliminación
  Future<void> deleteFileFromSupabase({required String storagePath}) async {
    try {
      logger.i('Eliminando archivo: $storagePath');
      await supabase.storage.from(_bucketName).remove([storagePath]);
      logger.i('Archivo eliminado exitosamente');
    } catch (e) {
      final errorMsg = 'Error eliminando archivo de Supabase: ${e.toString()}';
      logger.e(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // POST: Crear un incidente
  Future<IncidentModel> createIncident({
    required String incidentType,
    required String startDate,
    required String endDate,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/incidents/incidents/',
        data: {
          'incident_type': incidentType,
          'start_date': startDate,
          'end_date': endDate,
          'description': description,
        },
      );

      return IncidentModel.fromJson(response.data['incident']);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al crear el incidente';
      logger.e('Error creando incidente: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMsg = 'Error inesperado al crear incidente: ${e.toString()}';
      logger.e(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // GET: Obtener todos los incidentes
  Future<IncidentsListModel> getIncidents() async {
    try {
      final response = await _dio.get('/incidents/incidents/');

      return IncidentsListModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener incidentes';
      logger.e('Error obteniendo incidentes: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMsg =
          'Error inesperado al obtener incidentes: ${e.toString()}';
      logger.e(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // GET: Obtener un incidente por ID
  Future<IncidentModel> getIncidentById(String incidentId) async {
    try {
      final response = await _dio.get('/incidents/incidents/$incidentId/');

      return IncidentModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener el incidente';
      logger.e('Error obteniendo incidente $incidentId: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMsg = 'Error inesperado al obtener incidente: ${e.toString()}';
      logger.e(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // POST: Subir evidencia de un incidente (con archivo en Supabase)
  ///
  /// Este método:
  /// 1. Sube el archivo a Supabase Storage
  /// 2. Obtiene la URL pública
  /// 3. Registra la evidencia en el backend con la URL de Supabase
  Future<EvidenceModel> uploadEvidence({
    required String incidentId,
    required String filePath,
    required String fileType,
    required bool isSensitiveData,
  }) async {
    try {
      // Paso 1: Subir archivo a Supabase
      logger.i('Paso 1: Subiendo archivo a Supabase...');
      final publicUrl = await uploadFileToSupabase(
        incidentId: incidentId,
        filePath: filePath,
        fileType: fileType,
      );

      // Paso 2: Registrar evidencia en backend con URL de Supabase
      logger.i('Paso 2: Registrando evidencia en backend...');
      final response = await _dio.post(
        '/incidents/upload-evidence/',
        data: {
          'incident_id': incidentId,
          'file_path': publicUrl, // Guardar la URL pública de Supabase
          'file_type': fileType,
          'is_sensitive_data': isSensitiveData,
        },
      );

      logger.i('Evidencia subida y registrada correctamente');
      return EvidenceModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al subir la evidencia';
      logger.e('Error en uploadEvidence (Dio): $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMsg = 'Error al subir evidencia: ${e.toString()}';
      logger.e(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // POST: Subir múltiples evidencias de un incidente
  ///
  /// Este método sube múltiples archivos y registra cada uno como evidencia.
  /// Si uno falla, detiene el proceso.
  Future<List<EvidenceModel>> uploadMultipleEvidences({
    required String incidentId,
    required List<String> filePaths,
    required List<String> fileTypes,
    required List<bool> isSensitiveDataList,
  }) async {
    if (filePaths.isEmpty) {
      throw Exception('Debe proporcionar al menos un archivo');
    }

    if (filePaths.length != fileTypes.length ||
        filePaths.length != isSensitiveDataList.length) {
      throw Exception(
        'La cantidad de archivos, tipos y flags de sensibilidad debe coincidir',
      );
    }

    final uploadedEvidences = <EvidenceModel>[];

    try {
      for (int i = 0; i < filePaths.length; i++) {
        try {
          logger.i('Subiendo archivo ${i + 1}/${filePaths.length}...');
          final evidence = await uploadEvidence(
            incidentId: incidentId,
            filePath: filePaths[i],
            fileType: fileTypes[i],
            isSensitiveData: isSensitiveDataList[i],
          );
          uploadedEvidences.add(evidence);
        } catch (e) {
          logger.e('Error subiendo archivo ${i + 1}: ${e.toString()}');
          throw Exception(
            'Error al subir archivo ${i + 1} de ${filePaths.length}: ${e.toString()}',
          );
        }
      }
      logger.i(
        'Todas las evidencias se subieron correctamente (${uploadedEvidences.length} archivos)',
      );
      return uploadedEvidences;
    } catch (e) {
      logger.e('Error en carga múltiple de evidencias: ${e.toString()}');
      rethrow;
    }
  }
}
