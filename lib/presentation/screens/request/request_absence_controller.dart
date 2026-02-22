import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:dysch_mobile/presentation/screens/request/helpers/request_absence_helpers.dart';
import 'package:dysch_mobile/logic/incident/incident_cubit.dart';

/// Controlador que gestiona toda la lógica de la pantalla de solicitud de ausencia
class RequestAbsenceController {
  final List<Map<String, dynamic>> selectedFiles;
  int evidencesUploaded = 0;
  int totalEvidencesToUpload = 0;

  RequestAbsenceController({required this.selectedFiles});

  /// Seleccionar archivos del dispositivo
  Future<bool> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: RequestAbsenceHelpers.allowedExtensions,
        dialogTitle: 'Seleccionar archivos de soporte',
      );

      if (result != null) {
        int currentTotalSize = selectedFiles.fold(
          0,
          (sum, file) => sum + (file['size'] as int),
        );

        for (var platformFile in result.files) {
          if (platformFile.size >
              RequestAbsenceHelpers.getMaxSizeForExtension(
                platformFile.path!,
              )) {
            return false; // Archivo muy grande
          }

          if (currentTotalSize + platformFile.size >
              RequestAbsenceHelpers.maxTotalSize) {
            return false; // Total excedido
          }

          if (selectedFiles.length >= RequestAbsenceHelpers.maxFiles) {
            return false; // Máximo de archivos alcanzado
          }

          currentTotalSize += platformFile.size;
          selectedFiles.add({
            'path': platformFile.path!,
            'name': platformFile.name,
            'size': platformFile.size,
            'extension': platformFile.path!.split('.').last.toLowerCase(),
          });
        }

        return result.files.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Remover un archivo de la lista
  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
    }
  }

  /// Limpiar todos los archivos
  void clearAllFiles() {
    selectedFiles.clear();
  }

  /// Validar que la solicitud sea válida
  String? validateRequest({
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (description.trim().isEmpty) {
      return 'Por favor ingresa una descripción';
    }

    if (startDate.isAfter(endDate)) {
      return 'Fecha inicio no puede ser posterior a fecha fin';
    }

    final totalSize = selectedFiles.fold<int>(
      0,
      (sum, file) => sum + (file['size'] as int),
    );

    if (totalSize > RequestAbsenceHelpers.maxTotalSize) {
      return 'Tamaño total excede 20MB';
    }

    return null; // Sin errores
  }

  /// Enviar la solicitud de incidente
  Future<void> submitRequest({
    required BuildContext context,
    required String incidentType,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
    required String extraFields,
  }) async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    context.read<IncidentCubit>().createIncident(
      incidentType: incidentType,
      startDate: startDateStr,
      endDate: endDateStr,
      description: description.trim(),
      isActive: true,
      extraFields: extraFields.trim(),
    );
  }

  /// Preparar la carga de evidencias
  void prepareEvidenceUpload() {
    if (selectedFiles.isEmpty) {
      totalEvidencesToUpload = 0;
      evidencesUploaded = 0;
      return;
    }

    totalEvidencesToUpload = selectedFiles.length;
    evidencesUploaded = 0;
  }

  /// Subir evidencias uno por uno
  Future<void> uploadEvidences({
    required BuildContext context,
    required String incidentId,
  }) async {
    if (selectedFiles.isEmpty) {
      return;
    }

    prepareEvidenceUpload();

    for (var file in selectedFiles) {
      final fileExtension = (file['extension'] as String).toUpperCase();

      if (context.mounted) {
        context.read<IncidentCubit>().uploadEvidence(
          incidentId: incidentId,
          filePath:
              'https://storage.googleapis.com/mi-bucket/evidencias/${file['name']}',
          fileType: fileExtension,
          isSensitiveData: false,
        );
      }
    }
  }

  /// Incrementar contador de evidencias subidas
  void incrementEvidencesUploaded() {
    evidencesUploaded++;
  }

  /// Verificar si todas las evidencias se subieron
  bool allEvidencesUploaded() {
    return evidencesUploaded >= totalEvidencesToUpload;
  }

  /// Resetear el controlador
  void reset() {
    selectedFiles.clear();
    evidencesUploaded = 0;
    totalEvidencesToUpload = 0;
  }
}
