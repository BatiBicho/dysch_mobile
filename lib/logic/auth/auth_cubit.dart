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
  AuthCubit() : super(AuthInitial());

  void login(String email, String password) async {
    emit(AuthLoading());

    // Simulación de validación (Mock)
    await Future.delayed(const Duration(seconds: 2));

    if (email == "admin@dysch.com" && password == "123456") {
      emit(AuthSuccess("ID-999"));
    } else {
      emit(
        AuthError(
          "Credenciales incorrectas. Intenta con admin@dysch.com / 123456",
        ),
      );
    }
  }

  void logout() {
    emit(AuthInitial());
  }
}
