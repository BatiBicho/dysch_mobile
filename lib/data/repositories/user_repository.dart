import 'package:dio/dio.dart';
import 'package:dysch_mobile/data/models/user_model.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<UserModel> getUser(String id) async {
    final response = await _dio.get('https://api.dysch.com/users/$id');
    return UserModel.fromJson(response.data);
  }

  Future<void> updateUser(UserModel user) async {
    await _dio.patch(
      'https://api.dysch.com/users/${user.id}',
      data: user.toJson(),
    );
  }
}
