import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/user_model.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<UserModel> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        '/users/auth/login/',
        data: {'email': email, 'password': password},
      );

      return UserModel.fromLoginJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['non_field_errors'] ?? 'Error al iniciar sesión';
      throw Exception(errorMessage);
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/');

      return UserModel.fromLoginJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['non_field_errors'] ?? 'Error al obtener usuario';
      throw Exception(errorMessage);
    }
  }

  Future<UserModel> getEmployeeProfile() async {
    try {
      final response = await _dio.get('/organization/employees/');

      final results = response.data as List;
      if (results.isEmpty) {
        throw Exception('No se encontró información del empleado');
      }

      return UserModel.fromEmployeeJson(results.first as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['detail'] ?? 'Error al obtener perfil del empleado';
      throw Exception(errorMessage);
    }
  }
}
