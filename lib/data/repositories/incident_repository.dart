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
      throw Exception(errorMessage);
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
