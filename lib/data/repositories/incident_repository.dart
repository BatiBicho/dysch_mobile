import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/incident_model.dart';
import 'package:dysch_mobile/data/models/evidence_model.dart';

class IncidentRepository {
  final Dio _dio;

  IncidentRepository(this._dio);

  // POST: Crear un incidente
  Future<IncidentModel> createIncident({
    required String incidentType,
    required String startDate,
    required String endDate,
    required String description,
    required bool isActive,
    required String extraFields,
  }) async {
    try {
      final response = await _dio.post(
        '/incidents/incidents/',
        data: {
          'incident_type': incidentType,
          'start_date': startDate,
          'end_date': endDate,
          'description': description,
          'is_active': isActive,
          'extra_fields': extraFields,
        },
      );

      // El servidor responde con { "message": "...", "incident": { ... } }
      // Extraer el objeto incident del response
      if (response.data is Map && response.data['incident'] != null) {
        return IncidentModel.fromJson(response.data['incident']);
      } else {
        // Fallback si la estructura es diferente
        return IncidentModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al crear el incidente';
      throw Exception(errorMessage);
    }
  }

  // GET: Obtener todos los incidentes
  Future<List<IncidentModel>> getIncidents() async {
    try {
      final response = await _dio.get('/incidents/incidents/');

      if (response.data is List) {
        return (response.data as List)
            .map((incident) => IncidentModel.fromJson(incident))
            .toList();
      } else if (response.data is Map && response.data['results'] != null) {
        return (response.data['results'] as List)
            .map((incident) => IncidentModel.fromJson(incident))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener incidentes';
      throw Exception(errorMessage);
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
      throw Exception(errorMessage);
    }
  }

  // POST: Subir evidencia de un incidente
  Future<EvidenceModel> uploadEvidence({
    required String incidentId,
    required String filePath,
    required String fileType,
    required bool isSensitiveData,
  }) async {
    try {
      final response = await _dio.post(
        '/incidents/upload-evidence/',
        data: {
          'incident_id': incidentId,
          'file_path': filePath,
          'file_type': fileType,
          'is_sensitive_data': isSensitiveData,
        },
      );

      return EvidenceModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al subir la evidencia';
      throw Exception(errorMessage);
    }
  }
}
