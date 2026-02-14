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

      //return response.data;
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['non_field_errors'] ?? 'Error al iniciar sesión';
      throw Exception(errorMessage);
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/');

      return response.data;
      //return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['non_field_errors'] ?? 'Error al iniciar sesión';
      throw Exception(errorMessage);
    }
  }
}
