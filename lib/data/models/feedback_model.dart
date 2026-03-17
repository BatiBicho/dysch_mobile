class FeedbackAssignmentModel {
  final String id;
  final String campaignId;
  final String campaignName;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final bool isActive;

  // Datos de la campaña:
  final FeedbackCampaignModel? campaign;

  FeedbackAssignmentModel({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.isActive,
    this.campaign,
  });

  bool get isExpired {
    if (campaign == null) return false;
    final d = campaign!.endDate;
    final endOfDay = DateTime(d.year, d.month, d.day, 23, 59, 59);
    return DateTime.now().isAfter(endOfDay);
  }

  FeedbackAssignmentModel copyWith({FeedbackCampaignModel? campaign}) {
    return FeedbackAssignmentModel(
      id: id,
      campaignId: campaignId,
      campaignName: campaignName,
      employeeId: employeeId,
      employeeCode: employeeCode,
      employeeName: employeeName,
      status: status,
      completedAt: completedAt,
      createdAt: createdAt,
      isActive: isActive,
      campaign: campaign ?? this.campaign,
    );
  }

  factory FeedbackAssignmentModel.fromJson(Map<String, dynamic> json) {
    return FeedbackAssignmentModel(
      id: json['id'] ?? '',
      campaignId: json['campaign_id'] ?? '',
      campaignName: json['campaign_name'] ?? '',
      employeeId: json['employee_id'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      employeeName: json['employee_name'] ?? '',
      status: json['status'] ?? 'PENDING',
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }
}

// Preguntas:
enum ResponseType { stars, yesNo, text }

class FeedbackQuestionModel {
  final String id;
  final String topicId;
  final String topicTitle;
  final String questionText;
  final bool isMandatory;
  final ResponseType responseType;
  final int orderIndex;

  FeedbackQuestionModel({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.questionText,
    required this.isMandatory,
    required this.responseType,
    required this.orderIndex,
  });

  factory FeedbackQuestionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['response_type'] ?? 'TEXT';
    final type = typeStr == 'STARS'
        ? ResponseType.stars
        : typeStr == 'YES_NO'
            ? ResponseType.yesNo
            : ResponseType.text;

    return FeedbackQuestionModel(
      id: json['id'] ?? '',
      topicId: json['topic_id'] ?? '',
      topicTitle: json['topic_title'] ?? '',
      questionText: json['question_text'] ?? '',
      isMandatory: json['is_mandatory'] ?? false,
      responseType: type,
      orderIndex: json['order_index'] ?? 0,
    );
  }
}

// Respuestas para enviar:
class FeedbackResponseModel {
  final String questionId;
  final int? numericScore;   // STARS (1-5) o YES_NO (1=Sí, 0=No)
  final String? textComment; // TEXT (comentario)

  FeedbackResponseModel.stars(this.questionId, int score)
      : numericScore = score,
        textComment = null;

  FeedbackResponseModel.yesNo(this.questionId, bool yes)
      : numericScore = yes ? 1 : 0,
        textComment = null;

  FeedbackResponseModel.text(this.questionId, String comment)
      : numericScore = null,
        textComment = comment;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'question_id': questionId};
    if (numericScore != null) map['numeric_score'] = numericScore;
    if (textComment != null) map['text_comment'] = textComment;
    return map;
  }
}

// Resultados para mostrar:
class EmployeeResponseModel {
  final String questionText;
  final ResponseType responseType;
  final int? numericScore;
  final String? textComment;

  EmployeeResponseModel({
    required this.questionText,
    required this.responseType,
    this.numericScore,
    this.textComment,
  });

  factory EmployeeResponseModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['response_type'] ?? 'TEXT';
    final type = typeStr == 'STARS'
        ? ResponseType.stars
        : typeStr == 'YES_NO'
            ? ResponseType.yesNo
            : ResponseType.text;
    return EmployeeResponseModel(
      questionText: json['question_text'] ?? '',
      responseType: type,
      numericScore: json['numeric_score'],
      textComment: json['text_comment'],
    );
  }
}

class EmployeeResultModel {
  final String employeeCode;
  final String employeeName;
  final DateTime completedAt;
  final List<EmployeeResponseModel> responses;

  EmployeeResultModel({
    required this.employeeCode,
    required this.employeeName,
    required this.completedAt,
    required this.responses,
  });

  factory EmployeeResultModel.fromJson(Map<String, dynamic> json) {
    return EmployeeResultModel(
      employeeCode: json['employee_code'] ?? '',
      employeeName: json['employee_name'] ?? '',
      completedAt:
          DateTime.tryParse(json['completed_at'] ?? '') ?? DateTime.now(),
      responses: (json['responses'] as List? ?? [])
          .map((r) => EmployeeResponseModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CampaignResultsModel {
  final String campaignName;
  final bool isAnonymous;
  final int totalRespondents;
  final List<EmployeeResultModel> employees;

  CampaignResultsModel({
    required this.campaignName,
    required this.isAnonymous,
    required this.totalRespondents,
    required this.employees,
  });

  factory CampaignResultsModel.fromJson(Map<String, dynamic> json) {
    return CampaignResultsModel(
      campaignName: json['campaign_name'] ?? '',
      isAnonymous: json['is_anonymous'] ?? false,
      totalRespondents: json['total_respondents'] ?? 0,
      employees: (json['employees'] as List? ?? [])
          .map((e) => EmployeeResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Campañas:
class FeedbackCampaignModel {
  final String id;
  final String topicId;
  final String topicTitle;
  final String companyName;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAnonymous;
  final bool resultsVisibleToEmployees;
  final int assignmentsCount;
  final int completedCount;

  FeedbackCampaignModel({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.companyName,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isAnonymous,
    required this.resultsVisibleToEmployees,
    required this.assignmentsCount,
    required this.completedCount,
  });

  factory FeedbackCampaignModel.fromJson(Map<String, dynamic> json) {
    return FeedbackCampaignModel(
      id: json['id'] ?? '',
      topicId: json['topic_id'] ?? '',
      topicTitle: json['topic_title'] ?? '',
      companyName: json['company_name'] ?? '',
      name: json['name'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      isAnonymous: json['is_anonymous'] ?? false,
      resultsVisibleToEmployees: json['results_visible_to_employees'] ?? false,
      assignmentsCount: json['assignments_count'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
    );
  }
}