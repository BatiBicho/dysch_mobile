class EvidenceFile {
  final String id;
  final String filePath;
  final String fileType;
  final bool isSensitiveData;

  EvidenceFile({
    required this.id,
    required this.filePath,
    required this.fileType,
    required this.isSensitiveData,
  });

  factory EvidenceFile.fromJson(Map<String, dynamic> json) {
    return EvidenceFile(
      id: json['id'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? '',
      isSensitiveData: json['is_sensitive_data'] ?? false,
    );
  }
}

class IncidentModel {
  final String id;
  final String companyName;
  final String employeeCode;
  final String employeeName;
  // final DateTime submittedAt;
  final String incidentType;
  final String startDate;
  final String endDate;
  final String description;
  final String status;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final List<EvidenceFile> evidenceFiles;

  IncidentModel({
    required this.id,
    required this.companyName,
    required this.employeeCode,
    required this.employeeName,
    // required this.submittedAt,
    required this.incidentType,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.status,
    required this.evidenceFiles,
    this.reviewedByName,
    this.reviewedAt,
    this.rejectionReason,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] ?? '',
      companyName: json['company_name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      employeeName: json['employee_name'] ?? '',
      // submittedAt: DateTime.parse(json['submitted_at'] as String),
      incidentType: json['incident_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      reviewedByName: json['reviewed_by_name'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'],
      evidenceFiles:
          (json['evidence_files'] as List<dynamic>?)
              ?.map((e) => EvidenceFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get displayType {
    switch (incidentType) {
      case 'SICK_LEAVE':
        return 'Incapacidad Médica';
      case 'VACATION':
        return 'Vacaciones';
      case 'PERMIT':
        return 'Permiso Personal';
      case 'UNEXCUSED':
        return 'Ausencia Injustificada';
      case 'WORK_ACCIDENT':
        return 'Accidente Laboral';
      default:
        return incidentType;
    }
  }

  String get displayStatus {
    switch (status) {
      case 'PENDING':
        return 'Pendiente';
      case 'APPROVED':
        return 'Aprobada';
      case 'REJECTED':
        return 'Rechazada';
      default:
        return status;
    }
  }

  Map<String, dynamic> toJson() => {
    'incident_type': incidentType,
    'start_date': startDate,
    'end_date': endDate,
    'description': description,
  };
}

class IncidentsListModel {
  final List<IncidentModel> incidents;
  final int count;

  IncidentsListModel({required this.incidents, required this.count});

  factory IncidentsListModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return IncidentsListModel(
      incidents: results
          .map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] ?? 0,
    );
  }
}
