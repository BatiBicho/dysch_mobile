import 'package:dysch_mobile/core/api/dio_client.dart';
import 'package:dysch_mobile/core/services/storage_service.dart';
import 'package:dysch_mobile/data/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String userId;
  AuthSuccess(this.userId);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final UserRepository userRepository;
  final StorageService storageService;

  AuthCubit(this.userRepository, this.storageService) : super(AuthInitial());

  void login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError("Por favor, llena todos los campos"));
      return;
    }

    emit(AuthLoading());

    try {
      final user = await userRepository.loginUser(email, password);

      final String token = user.token;
      final String userId = user.id;

      await storageService.saveToken(token);
      await storageService.saveUserId(userId);

      DioClient.setAuthToken(user.token);
      emit(AuthSuccess(userId));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  void logout() async {
    await storageService.clearAll();
    emit(AuthInitial());
  }
}
