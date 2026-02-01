class AbsenceRequestModel {
  String type; // Permiso personal, Cita médica, etc.
  DateTime startDate;
  DateTime endDate;
  String justification;
  bool isFullDay;
  List<String> evidencePaths;

  AbsenceRequestModel({
    this.type = 'Permiso personal',
    required this.startDate,
    required this.endDate,
    this.justification = '',
    this.isFullDay = true,
    this.evidencePaths = const [],
  });
}
