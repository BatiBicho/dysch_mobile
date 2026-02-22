class IncidentModel {
  final String id;
  final String incidentType;
  final String startDate;
  final String endDate;
  final String description;
  final bool isActive;
  final String extraFields;

  IncidentModel({
    required this.id,
    required this.incidentType,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.isActive,
    required this.extraFields,
  });

  // De JSON (API) a Objeto Dart
  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] ?? '',
      incidentType: json['incident_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      extraFields: json['extra_fields'] ?? '',
    );
  }

  // De Objeto Dart a JSON (Para mandar a la API)
  Map<String, dynamic> toJson() => {
    'incident_type': incidentType,
    'start_date': startDate,
    'end_date': endDate,
    'description': description,
    'is_active': isActive,
    'extra_fields': extraFields,
  };
}
