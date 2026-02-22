class EvidenceModel {
  final String incidentId;
  final String filePath;
  final String fileType;
  final bool isSensitiveData;

  EvidenceModel({
    required this.incidentId,
    required this.filePath,
    required this.fileType,
    required this.isSensitiveData,
  });

  // De JSON (API) a Objeto Dart
  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      incidentId: json['incident_id'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? '',
      isSensitiveData: json['is_sensitive_data'] ?? false,
    );
  }

  // De Objeto Dart a JSON (Para mandar a la API)
  Map<String, dynamic> toJson() => {
    'incident_id': incidentId,
    'file_path': filePath,
    'file_type': fileType,
    'is_sensitive_data': isSensitiveData,
  };
}
