import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/feedback_model.dart';

class FeedbackRepository {
  final Dio _dio;

  FeedbackRepository(this._dio);

  Future<List<FeedbackAssignmentModel>> getPendingAssignments() async {
    try {
      final response = await _dio.get('/feedback/assignments/my-pending/');
      final List data = response.data as List;
      return data
          .map((e) => FeedbackAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener evaluaciones pendientes';
      throw Exception(errorMessage);
    }
  }

  Future<FeedbackCampaignModel> getCampaignDetail(String campaignId) async {
    try {
      final response = await _dio.get('/feedback/campaigns/$campaignId/');
      return FeedbackCampaignModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener detalle de la campaña';
      throw Exception(errorMessage);
    }
  }

  Future<List<FeedbackQuestionModel>> getQuestions(String topicId) async {
    try {
      final response = await _dio.get(
        '/feedback/questions/',
        queryParameters: {'topic_id': topicId},
      );
      final List results = response.data['results'] as List;
      final questions = results
          .map((e) => FeedbackQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      // Ordenar por order_index por si la API no los devuelve ordenados
      questions.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return questions;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener preguntas';
      throw Exception(errorMessage);
    }
  }

  Future<void> submitFeedback({
    required String campaignId,
    required List<FeedbackResponseModel> responses,
  }) async {
    try {
      await _dio.post(
        '/feedback/submit/',
        data: {
          'campaign_id': campaignId,
          'responses': responses.map((r) => r.toJson()).toList(),
        },
      );
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al enviar la evaluación';
      throw Exception(errorMessage);
    }
  }

  Future<CampaignResultsModel> getEmployeeResponses(String campaignId) async {
    try {
      final response = await _dio.get(
        '/feedback/campaigns/$campaignId/employee-responses/',
      );
      return CampaignResultsModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener respuestas';
      throw Exception(errorMessage);
    }
  }
}