import 'package:dysch_mobile/data/models/incident_model.dart';
import 'package:dysch_mobile/data/models/evidence_model.dart';
import 'package:dysch_mobile/data/repositories/incident_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== ESTADOS ====================

abstract class IncidentState {}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {}

class IncidentSuccess extends IncidentState {
  final IncidentModel incident;
  IncidentSuccess(this.incident);
}

class IncidentsLoaded extends IncidentState {
  final List<IncidentModel> incidents;
  IncidentsLoaded(this.incidents);
}

class EvidenceUploadSuccess extends IncidentState {
  final EvidenceModel evidence;
  EvidenceUploadSuccess(this.evidence);
}

class MultipleEvidencesUploadSuccess extends IncidentState {
  final List<EvidenceModel> evidences;
  final int totalCount;

  MultipleEvidencesUploadSuccess({
    required this.evidences,
    required this.totalCount,
  });
}

class IncidentError extends IncidentState {
  final String message;
  IncidentError(this.message);
}

// ==================== CUBIT ====================

class IncidentCubit extends Cubit<IncidentState> {
  final IncidentRepository repository;

  IncidentCubit(this.repository) : super(IncidentInitial());

  // Crear un nuevo incidente
  Future<void> createIncident({
    required String incidentType,
    required String startDate,
    required String endDate,
    required String description,
    // required bool isActive,
    // required String extraFields,
  }) async {
    try {
      emit(IncidentLoading());
      final incident = await repository.createIncident(
        incidentType: incidentType,
        startDate: startDate,
        endDate: endDate,
        description: description,
        // isActive: isActive,
        // extraFields: extraFields,
      );
      emit(IncidentSuccess(incident));
    } catch (e) {
      emit(IncidentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Obtener todos los incidentes
  Future<void> getIncidents() async {
    if (state is IncidentLoading) return;

    try {
      emit(IncidentLoading());
      final data = await repository.getIncidents();
      emit(IncidentsLoaded(data.incidents));
    } catch (e) {
      emit(IncidentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Obtener un incidente por ID
  Future<void> getIncidentById(String incidentId) async {
    try {
      emit(IncidentLoading());
      final incident = await repository.getIncidentById(incidentId);
      emit(IncidentSuccess(incident));
    } catch (e) {
      emit(IncidentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Subir evidencia de un incidente
  Future<void> uploadEvidence({
    required String incidentId,
    required String filePath,
    required String fileType,
    required bool isSensitiveData,
  }) async {
    try {
      emit(IncidentLoading());
      final evidence = await repository.uploadEvidence(
        incidentId: incidentId,
        filePath: filePath,
        fileType: fileType,
        isSensitiveData: isSensitiveData,
      );
      emit(EvidenceUploadSuccess(evidence));
    } catch (e) {
      emit(IncidentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Subir múltiples evidencias a Supabase Storage
  ///
  /// Este método sube múltiples archivos a Supabase y registra cada uno
  /// como evidencia en el backend.
  ///
  /// [incidentId] - ID del incidente
  /// [filePaths] - Lista de rutas locales de archivos
  /// [fileTypes] - Lista de tipos de archivo (image, pdf, video, etc)
  /// [isSensitiveDataList] - Lista booleana indicando si cada archivo es sensible
  Future<void> uploadMultipleEvidences({
    required String incidentId,
    required List<String> filePaths,
    required List<String> fileTypes,
    required List<bool> isSensitiveDataList,
  }) async {
    try {
      emit(IncidentLoading());

      final evidences = await repository.uploadMultipleEvidences(
        incidentId: incidentId,
        filePaths: filePaths,
        fileTypes: fileTypes,
        isSensitiveDataList: isSensitiveDataList,
      );

      emit(
        MultipleEvidencesUploadSuccess(
          evidences: evidences,
          totalCount: filePaths.length,
        ),
      );
    } catch (e) {
      emit(IncidentError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
